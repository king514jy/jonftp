package org.gainloss.asftp.process
{
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	import org.gainloss.asftp.events.GLFTPEvent;
	import org.gainloss.asftp.request.*;
	import org.gainloss.asftp.response.*;
	import org.gainloss.asftp.utils.*;
	import org.gainloss.log.*;
	
	/**
	 * get list information
	 * 
	 * steps:
	 * 		1	call PWD
	 * 		2	enter PASV mode
	 * 		3	call LIST
	 * 		4	parse response in PASV mode
	 * 		5 	transfer complete, close PASV connection
	 */ 
	public class GLList extends GLProcess
	{
		public function GLList()
		{
			//TODO: implement function
			super();
		}
		
		
		private var _directory:String = "/";
		private var _pasvSock:MySock;
		private var _dicInfoStr:String = "";		//path
		
		private var _dicInfos:Array = new Array();	//element is instance of GLRemoteFIle
		
		/**
		 * return Array 	remote file collection, each element is instance of GLRemoteFIle
		 */ 
		public function get dicInfos():Array
		{
			return _dicInfos;
		}
		
		public function get currentDicPath():String
		{
			return _directory;
		}
		
		/**
		 * parse dictionary string from the response of PWD command
		 * 
		 * @param stdMsg	message of response of PWD command
		 */ 
		private function parseDic(stdMsg:String):String
		{
			var match:Array = stdMsg.match(/".*"/g);
			if(match == null)
				throw new Error("response can not match");
				
			var data:String = match[0].toString();
			return data.substr(1, data.length-2);
		}
		
		//******************************
		//	implement
		//******************************
		
		protected override function responseHandler(res:GLResponse):void
		{
			switch(res.code)
			{
				case GLResponseType.PATHNAME_CREATED:
					try
					{
						_directory = parseDic(res.message);
						this.sendCmd(GLRequest.parse(GLRequestType.PASV));	//send PASV for list information
					}
					catch(e:Error)
					{
						this.callHandler(new GLFTPEvent(GLFTPEvent.PROCESS_FAIL));
					}
					break;
				case GLResponseType.ENTERING_PASV:
					_pasvSock = MySock.parsePASVSock(res.message);
					_pasvSock.addEventListener(Event.CONNECT, onPasvConnected);
					_pasvSock.addEventListener(ProgressEvent.SOCKET_DATA, onPasvData);
					break;
				/*case GLResponseType.COMMAND_OK:
					this.sendCmd(GLRequest.parse(GLRequestType.LIST, _directory));
					break;*/
				case GLResponseType.FILE_STATUS_OK:
					break;
				case GLResponseType.DATA_CONN_CLOSE:
					//finish
					var dics:Array = _dicInfoStr.split("\r\n")
					for(var i:int=0 ; i<dics.length ; i++)
					{
						if(dics[i].toString() != "")
						{
							var glr:GLRemoteFile = GLRemoteFile.parseFromItemOfList(dics[i].toString());
							if(glr.name != "." && glr.name != "..")
							{
								//glr.name = currentDicPath + "/" + glr.name;
								glr.url = (currentDicPath=="")?glr.name:(currentDicPath + "/" + glr.name)
								_dicInfos.push(glr);
							}
						}
					}
					//GLLog.getInstance().pushCommonMsg(dics[0]);
					this.callHandler(new GLFTPEvent(GLFTPEvent.PROCESS_FINISH));
					break;
				default:
					this.callHandler(new GLFTPEvent(GLFTPEvent.PROCESS_FAIL));
			}
		}
		
		protected override function sendRequest():void
		{
			//get current dictionary
			this.sendCmd(GLRequest.parse(GLRequestType.PWD));
		}
		
		
		///////////////////////////////////////////
		
		private function onPasvConnected(event:Event):void
		{
			//pasv connected. then call LIST cmd
			this.sendCmd(GLRequest.parse(GLRequestType.LIST, _directory));
		}
		
		private function onPasvData(event:ProgressEvent):void
		{
			//trace(_pasvSock.readUTFBytes(_pasvSock.bytesAvailable));
			//GLLog.getInstance().pushCommonMsg(_pasvSock.readUTFBytes(_pasvSock.bytesAvailable));
			_dicInfoStr += _pasvSock.readUTFBytes(_pasvSock.bytesAvailable);
		}
		
	}
}