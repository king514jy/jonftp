package org.gainloss.asftp.process
{
	import org.gainloss.asftp.events.GLFTPEvent;
	import org.gainloss.asftp.request.*;
	import org.gainloss.asftp.response.*;
	import org.gainloss.asftp.utils.GLRemoteFile;
	
	
	/**
	 * delete file, not dictionary
	 */ 
	public class GLDeleteFile extends GLProcess
	{
		public function GLDeleteFile(glr:GLRemoteFile)
		{
			//TODO: implement function
			super();
			
			_toDeleted = glr;
		}
		
		private var _toDeleted:GLRemoteFile;
		
		//******************************
		//	implement
		//******************************
		
		protected override function responseHandler(res:GLResponse):void
		{
			switch(res.code)
			{
				case GLResponseType.FILE_ACTION_OK:
					callHandler(new GLFTPEvent(GLFTPEvent.PROCESS_FINISH));
					break;
				default:
					callHandler(new GLFTPEvent(GLFTPEvent.PROCESS_FAIL));
			}
		}
		
		protected override function sendRequest():void
		{
			if(_toDeleted.type == "d")
			{
				//folder
				//delete empty folder
				this.sendCmd(GLRequest.parse(GLRequestType.RMD, _toDeleted.url));
				//throw new Error("GLDeleteFile can not delete dictionary, please use class [GLDeleteCommonFile]");
			}
			else
			{
				//file or link
				this.sendCmd(GLRequest.parse(GLRequestType.DELE, _toDeleted.url));
			}
		}
		
	}
}