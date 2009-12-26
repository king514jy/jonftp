package org.gainloss.asftp.process
{
	import flash.events.*;
	import flash.filesystem.*;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import org.gainloss.asftp.events.GLFTPEvent;
	import org.gainloss.asftp.events.GLProgressEvent;
	import org.gainloss.asftp.request.*;
	import org.gainloss.asftp.response.*;
	import org.gainloss.asftp.utils.MySock;
	
	/**
	 * upload single file, not dictionary
	 */ 
	public class GLUpload extends GLProcess
	{
		public function GLUpload(localFile:File, remoteAbsoluteFileName:String, onUploadProgressHandler:Function)
		{
			//TODO: implement function
			super();
			
			_localFile = localFile;
			_remoteAbsoluteFileName = remoteAbsoluteFileName;
			_timer.addEventListener(TimerEvent.TIMER, onUploadTimerHandler);
			_onUploadProgressHandler = onUploadProgressHandler;
		}
		
		private var _localFile:File;
		private var _localFileStream:FileStream;
		
		private var _timer:Timer = new Timer(300);
		private var _bufferSize:int = 4069;
		private var _remoteAbsoluteFileName:String;		//remote path and filename
		private var _onUploadProgressHandler:Function;
		
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
					startSendingData();
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
		
		private function startSendingData():void
		{
			//open filestream
			_localFileStream = new FileStream();
			_localFileStream.open(_localFile, FileMode.READ);
			
			_timer.start();
		}
		
		/**
		 * continue sending bytes
		 */ 
		private function onUploadTimerHandler(event:TimerEvent):void
		{
			if(_localFileStream.bytesAvailable <= 0)
			{
				_timer.stop();			//timer close
				_pasvSock.close();		//pasv socket close
			}
			else
			{
				var by:ByteArray = new ByteArray();
				try
				{
					_localFileStream.readBytes(by, 0, _bufferSize);
				}
				catch(e:Error)
				{
					_localFileStream.readBytes(by);
				}
				//write into socket
				_pasvSock.writeBytes(by);
				_pasvSock.flush();
				
				var eve:GLProgressEvent = new GLProgressEvent(GLProgressEvent.PROCESS_PROGRESS);
				eve.new_processed_bytes_length = by.bytesAvailable;
				_onUploadProgressHandler(eve);
				
				//if(_bufferSize > _localFileStream.bytesAvailable)
				//	_bufferSize = _localFileStream.bytesAvailable;
			}
		}
		
		private function onPasvConnected(event:Event):void
		{
			//pasv connected. 
			this.sendCmd(GLRequest.parse(GLRequestType.STOR, _remoteAbsoluteFileName));
		}
		
		private function onPasvData(event:ProgressEvent):void
		{
			//send progress event
			//trace(event.bytesLoaded);
		}
		
	}
}