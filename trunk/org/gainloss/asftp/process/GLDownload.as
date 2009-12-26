package org.gainloss.asftp.process
{
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	import org.gainloss.asftp.events.GLFTPEvent;
	import org.gainloss.asftp.events.GLProgressEvent;
	import org.gainloss.asftp.request.*;
	import org.gainloss.asftp.response.*;
	import org.gainloss.asftp.utils.GLRemoteFile;
	import org.gainloss.asftp.utils.MySock;
	
	/**
	 * download file
	 */ 
	public class GLDownload extends GLProcess
	{
		/**
		 * @param remoteFile
		 * @param onProgressHandler		function with one parameter 'GLProgressEvent'
		 */ 
		public function GLDownload(remoteFile:GLRemoteFile, onProgressHandler:Function)
		{
			//TODO: implement function
			super();
			
			_remoteFile = remoteFile;
			_onProgressHandler = onProgressHandler;
		}
		
		private var _remoteFile:GLRemoteFile;
		//private var _byteTotal:int = 0;
		private var _onProgressHandler:Function;
		
		private var _pasvSock:MySock;
		
		//******************************
		//	implement
		//******************************
		
		protected override function responseHandler(res:GLResponse):void
		{
			switch(res.code)
			{
				case GLResponseType.COMMAND_OK:
					this.sendCmd(GLRequest.parse(GLRequestType.PASV));
					break;
				case GLResponseType.ENTERING_PASV:
					_pasvSock = MySock.parsePASVSock(res.message);
					_pasvSock.addEventListener(Event.CONNECT, onPasvConnected);
					_pasvSock.addEventListener(ProgressEvent.SOCKET_DATA, onPasvData);
					break;
				case GLResponseType.DATA_CONN_CLOSE:
					this.callHandler(new GLFTPEvent(GLFTPEvent.PROCESS_FINISH));
					break;
				case GLResponseType.FILE_STATUS_OK:
					//var matchstr:String = res.message.match(/(\d+\sbytes)/g)[0].toString()
					//_byteTotal = parseInt(matchstr.substring(1,matchstr.length-7));
					break;
				default:
					//nothing
			}
		}
		
		protected override function sendRequest():void
		{
			this.sendCmd(GLRequest.parse(GLRequestType.BINARY));
		}
		
		///////////////////////////////////////////
		
		private function onPasvConnected(event:Event):void
		{
			//pasv connected. then call LIST cmd
			this.sendCmd(GLRequest.parse(GLRequestType.RETR, _remoteFile.url));
		}
		
		private function onPasvData(event:ProgressEvent):void
		{
			//send progress event
			var eve:GLProgressEvent = new GLProgressEvent(GLProgressEvent.PROCESS_PROGRESS);
			_pasvSock.readBytes(eve.bytes);
			//eve.totalBytes = _byteTotal;
			//this.dispatchEvent(eve);
			_onProgressHandler(eve);
		}
		
	}
}