package org.gainloss.asftp.process
{
	import flash.events.EventDispatcher;
	
	import org.gainloss.asftp.events.GLFTPEvent;
	import org.gainloss.asftp.events.GLRequestEvent;
	import org.gainloss.asftp.request.GLRequest;
	import org.gainloss.asftp.response.GLResponse;
	import org.gainloss.log.*;
	
	/**
	 * process of request and response
	 */ 
	public class GLProcess extends EventDispatcher
	{
		public function GLProcess()
		{
			//TODO: implement function
		}
		
		//private var _innerSock:MySock;	//the socket
		//private var _handler:Function;
		
		/**
		 * send command to server
		 */ 
		public final function request():void
		{
			//_innerSock = sock;
			//_innerSock.addEventListener(ProgressEvent.SOCKET_DATA, response);
			sendRequest();
		}
		
		/**
		 * handle response from server
		 * 
		 * @param _response 	string
		 */ 
		public final function response(_response:GLResponse):void
		{
			//var _response:String = _innerSock.readUTFBytes(_innerSock.bytesAvailable);
			//trace(_response.replace(/[\r\n]/g, ""));
			//GLLog.getInstance().pushCommonMsg(_response.replace(/[\r\n]/g, "").replace(/PASS\s.*/g, "PASS ******"));
			responseHandler(_response);
		}
		
		/**
		 * cancel current process
		 */ 
		public final function cancel():void
		{
			//_innerSock.removeEventListener(ProgressEvent.SOCKET_DATA, response);
			//_innerSock = null;
		}
		
		/**
		 * add process handler
		 * 
		 * @param handler 	function with one parameter "GLFTPEvent"
		 */ 
		/*public final function processHandler(handler:Function=null):void
		{
			_handler = handler;
		}*/
		
		/*
		private function waitForConnectBeforeInvoke(event:Event):void
		{
			_innerSock.removeEventListener(Event.CONNECT, waitForConnectBeforeInvoke);
			//_currentProcess.request();
			sendCmd(_tempCmd);
		}*/
		
		/*
		private function sendSingleCommand(cmd:GLRequest):void
		{
			//trace(cmd.toCmdStr())
			GLLog.getInstance().pushCommonMsg(cmd.toCmdStr());
			_innerSock.writeUTFBytes(cmd.toCmdStr()+"\n");
			_innerSock.flush();
		}
		*/
		
		////////////////////////////////
		
		//private var _tempCmd:GLRequest;
		
		protected final function sendCmd(cmd:GLRequest):void
		{
			/*
			if(_innerSock.connected)
			{
				//run it
				sendSingleCommand(cmd);
			}
			else
			{
				//try to connect before run process
				_innerSock.addEventListener(Event.CONNECT, waitForConnectBeforeInvoke);
				_tempCmd = cmd;
				_innerSock.connectAgain();
			}*/
			
			//send
			var eve:GLRequestEvent = new GLRequestEvent(GLRequestEvent.PROCESS_SEND_COMMAND);
			eve.gl = cmd;
			dispatchEvent(eve);
		}
		
		/**
		 * generally speaking, event may represent process is end or got error
		 * 
		 * @param event
		 */
		protected final function callHandler(event:GLFTPEvent):void
		{
			/*if(_handler)
			{
				_handler(event);
			}*/
			dispatchEvent(event);		//send event
		}
		
		
		//******************************
		//	must be override
		//******************************
		
		protected function responseHandler(res:GLResponse):void
		{
			throw new Error("have not implemented");
		}
		
		protected function sendRequest():void
		{
			throw new Error("have not implemented");
		}

	}
}