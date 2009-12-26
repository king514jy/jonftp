package org.gainloss.asftp
{
	import flash.events.*;
	
	import mx.controls.Alert;
	import mx.managers.CursorManager;
	
	import org.gainloss.asftp.events.*;
	import org.gainloss.asftp.process.*;
	import org.gainloss.asftp.response.*;
	import org.gainloss.asftp.utils.MySock;
	import org.gainloss.log.*;
	
	/**
	 * manage socket
	 */ 
	public class GLFTPClient extends EventDispatcher
	{
		public function GLFTPClient(username:String, pass:String, host:String, port:int=21)
		{
			//TODO: implement function
			super();
			
			_innerSock = new MySock(host, port);
			_innerSock.addEventListener(Event.CLOSE, onCloseSock);
			_innerSock.addEventListener(IOErrorEvent.IO_ERROR, onErrorSock);
			_innerSock.addEventListener(Event.CONNECT, onConnectSock);
			_innerSock.addEventListener(ProgressEvent.SOCKET_DATA, onGetSockData);
			
			_loginProcess = new GLLogin(username, pass);
		}
		
		private var _innerSock:MySock;
		private var _currentProcess:GLProcess;	//current process. if no process is running, the value is null
		private var _paused_process:GLProcess;
		private var _paused_handler:Function;
		private var _onProcessHandler:Function;
		//private var _processQueue:Array = new Array();
		
		private var _loginProcess:GLLogin;
		
		private var _state:String = GLClientStateEvent.UNCONNECTED;
		
		public static const REMOTE_SEPERATOR:String = "/";
		public static var remoteSysType:String = TYPE_UNIX;		//TYPE_UNIX or TYPE_WIN_NT
		
		public static const TYPE_UNIX:String	= "UNIX";
		public static const TYPE_WIN_NT:String 	= "Windows_NT";
		
		
		
		//////////////////////////////////////////////////////
		
		/**
		 * state of client
		 */ 
		public function get state():String
		{
			return _state;
		}
		
		public function cleanUp():void
		{
			try
			{
				_innerSock.close();
				onCloseSock();
				cleanProviousProcess();
			}
			catch(e:Error)
			{
				//io error
			}
		}
		
		private function startToConnect():void
		{
			tryInvoke(_loginProcess, function(eve:GLFTPEvent):void{
				if(eve.type == GLFTPEvent.PROCESS_FINISH)
				{
					//login ok
					//afterLogin();
					tryInvoke(new GLSysInfo(), function(eve:GLFTPEvent):void{
						afterLogin();
					})
				}
				else
				{
					//login fail
					Alert.show("User name or password is wrong. Please try again", "ERROR");
				}
			});
			
			_innerSock.connectAgain();
		}
		
		private function afterLogin():void
		{
			if(_paused_process)
			{
				tryInvoke(_paused_process, _paused_handler);
				
				//clear
				_paused_process = null;
				_paused_handler = null;
			}
		}
		
		/**
		 * try to execute one process
		 * 
		 * @param process 				GLProcess
		 * @param onProcessHandler		function with one parameter "GLFTPEvent"
		 */ 
		public function tryInvoke(process:GLProcess, onProcessHandler:Function=null):void
		{
			cleanProviousProcess();
			
			//new process
			_currentProcess = process;
			_onProcessHandler = onProcessHandler;
			/*if(_currentProcess is GLGroup)
			{
				(_currentProcess as GLGroup).client = this;
			}*/
			
			buildListeners(true);
			
			/*
			_currentProcess.processHandler(function(event:GLFTPEvent):void{
				changeState(GLClientStateEvent.IDLE);
				if(onProcessHandler)
				{
					onProcessHandler(event);
				}
			});*/
			
			
			CursorManager.setBusyCursor();
			changeState(GLClientStateEvent.INVOKING);
			_currentProcess.request();			//begin to invoke
			
		}
		
		private function cleanProviousProcess():void
		{
			if(_currentProcess)
			{
				_currentProcess.cancel();
				buildListeners(false);
			}
			
			_currentProcess = null;
			_onProcessHandler = null;
		}
		
		/**
		 * add or remove listeners to [_currentProcess]
		 */ 
		private function buildListeners(_b:Boolean):void
		{
			if(_b)
			{
				_currentProcess.addEventListener(GLRequestEvent.PROCESS_SEND_COMMAND, onTryToSendCMDHandler);
				_currentProcess.addEventListener(GLFTPEvent.PROCESS_FINISH, myProcessHandler);
				_currentProcess.addEventListener(GLFTPEvent.PROCESS_FAIL, myProcessHandler);
			}
			else
			{
				_currentProcess.removeEventListener(GLRequestEvent.PROCESS_SEND_COMMAND, onTryToSendCMDHandler);
				_currentProcess.removeEventListener(GLFTPEvent.PROCESS_FINISH, myProcessHandler);
				_currentProcess.removeEventListener(GLFTPEvent.PROCESS_FAIL, myProcessHandler);
			}
		}
		
		/**
		 * before telling user what happened to process, try to change state
		 */ 
		private function myProcessHandler(event:GLFTPEvent):void
		{
			event.preventDefault();
			CursorManager.removeBusyCursor();
			changeState(GLClientStateEvent.IDLE);
			if(_onProcessHandler)
			{
				_onProcessHandler(event);
			}
		}
		
		/**
		 * send command to socket
		 */ 
		private function onTryToSendCMDHandler(event:GLRequestEvent):void
		{
			//log
			GLLog.getInstance().pushCommonMsg(event.gl.toCmdStr().replace(/^PASS.+/, "PASS ******"));
			//
			if(_innerSock.connected)
			{
				_innerSock.writeUTFBytes(event.gl.toCmdStr()+"\n");
				_innerSock.flush();
			}
			else
			{
				CursorManager.removeBusyCursor();
				GLLog.getInstance().pushStateMsg("Socket kept disconnected. Try to connect now...");
				//keep current process and its handler
				//after login, try to call it from the beginning
				_paused_process = _currentProcess;
				_paused_handler = _onProcessHandler;
				//try reconnect
				startToConnect();
			}
		}
		
		/**
		 * change state
		 * 
		 * @param _s  	one of 3 states
		 */ 
		private function changeState(_s:String):void
		{
			_state = _s;
			dispatchEvent(new GLClientStateEvent(GLClientStateEvent.STATE));
		}
		
		
		/////////////////////////////////////////////////////
		//
		// socket listeners
		//
		/////////////////////////////////////////////////////
		
		/**
		 * sock listener
		 * 
		 * @param	event
		 */
		private function onGetSockData(event:ProgressEvent):void
		{
			if(_currentProcess)
			{
				var _response:String = _innerSock.readUTFBytes(_innerSock.bytesAvailable);
				var _responses:Array = _response.match(/\d{3}[\s-]?.*/g);
				for(var i:int=0 ; i<_responses.length ; i++)
				{
					GLLog.getInstance().pushCommonMsg(_responses[i].replace(/[\r\n]/g, ""));
					_currentProcess.response(GLResponse.parse(_responses[i]));
				}
			}
		}
		
		/**
		 * sock listener
		 * 
		 * @param	event
		 */
		private function onCloseSock(event:Event=null):void
		{
			//trace("innerSock closed!");
			GLLog.getInstance().pushStateMsg("Socket closed!");
			changeState(GLClientStateEvent.UNCONNECTED);
			
			CursorManager.removeBusyCursor();
		}
		
		/**
		 * sock listener
		 * 
		 * @param	event
		 */
		private function onErrorSock(event:IOErrorEvent):void
		{
			//trace(event.text);
			GLLog.getInstance().pushStateMsg("Socket got ERROR!");
			changeState(GLClientStateEvent.UNCONNECTED);
			
			CursorManager.removeBusyCursor();
			Alert.show(event.text, "ERROR");
		}
		
		/**
		 * sock listener
		 * 
		 * @param	event
		 */
		private function onConnectSock(event:Event):void
		{
			//welcome
			//trace("Welcome")
			changeState(GLClientStateEvent.IDLE);
		}
		
	}
}


import org.gainloss.asftp.events.GLFTPEvent;
import org.gainloss.asftp.request.*;
import org.gainloss.asftp.response.*;
import org.gainloss.asftp.process.*;
import org.gainloss.asftp.GLFTPClient;


/**
 * get welcome words
 */ 
/* 
class GLWelcome extends GLProcess
{
	public function GLWelcome()
	{
		//TODO: implement function
		super();
	}
	
	
	//******************************
	//	implement
	//******************************
	
	protected override function responseHandler(res:GLResponse):void
	{
		switch(res.code)
		{
			case GLResponseType.SERVICE_READY:
				//trace("TYPE: welcome");
				//GLLog.getInstance().pushStateMsg("Welcome");
				if(!res.isMultiline)
				{
					callHandler(new GLFTPEvent(GLFTPEvent.PROCESS_FINISH));
				}
				break;
			default:
				callHandler(new GLFTPEvent(GLFTPEvent.PROCESS_FAIL));
		}
	}
	
	protected override function sendRequest():void
	{
		//do nothing
	}
	
}*/


class GLSysInfo extends GLProcess
{
	public function GLSysInfo()
	{
		//TODO: implement function
		super();
	}
	
	
	//******************************
	//	implement
	//******************************
	
	protected override function responseHandler(res:GLResponse):void
	{
		switch(res.code)
		{
			case GLResponseType.SYS_TYPE:
				//trace("logged in");
				if(res.message.indexOf(GLFTPClient.TYPE_UNIX) != -1)
				{
					GLFTPClient.remoteSysType = GLFTPClient.TYPE_UNIX;
				}
				else if(res.message.indexOf(GLFTPClient.TYPE_WIN_NT) != -1)
				{
					GLFTPClient.remoteSysType = GLFTPClient.TYPE_WIN_NT;
				}
				callHandler(new GLFTPEvent(GLFTPEvent.PROCESS_FINISH));
				break;
			default:
				callHandler(new GLFTPEvent(GLFTPEvent.PROCESS_FAIL));
		}
	}
	
	protected override function sendRequest():void
	{
		sendCmd(GLRequest.parse(GLRequestType.SYST));
	}
}


/**
 * login process
 */ 
class GLLogin extends GLProcess
{
	public function GLLogin(username:String, pwd:String)
	{
		//TODO: implement function
		super();
		
		_usr = username;
		_pwd = pwd;
	}
	
	
	private var _usr:String;
	private var _pwd:String;
	
	
	//******************************
	//	implement
	//******************************
	
	protected override function responseHandler(res:GLResponse):void
	{
		switch(res.code)
		{
			case GLResponseType.SERVICE_READY:
				//get welcome sentences 
				if(!res.isMultiline)
				{
					//send username first
					sendCmd(GLRequest.parse(GLRequestType.USER, _usr));
				}
				break;
			case GLResponseType.USER_OK:
				this.sendCmd(GLRequest.parse(GLRequestType.PASS, _pwd));
				break;
			case GLResponseType.LOGGED_IN:
				//trace("logged in");
				this.callHandler(new GLFTPEvent(GLFTPEvent.PROCESS_FINISH));
				break;
			default:
				this.callHandler(new GLFTPEvent(GLFTPEvent.PROCESS_FAIL));
		}
	}
	
	protected override function sendRequest():void
	{
		//do nothing but wait for the welcome sentence
	}
	
}