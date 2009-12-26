package org.gainloss.asftp.process
{
	import org.gainloss.asftp.events.GLFTPEvent;
	import org.gainloss.asftp.request.*;
	import org.gainloss.asftp.response.*;
	
	
	/**
	 * rename file or dictionary
	 */ 
	public class GLRename extends GLProcess
	{
		/**
		 * @param remoteFileName
		 * @param renamedName			the new name you wanna change to
		 */ 
		public function GLRename(remoteFileName:String, renamedName:String)
		{
			//TODO: implement function
			super();
			
			_remoteFileName = remoteFileName;
			_renamedName = renamedName;
		}
		
		private var _remoteFileName:String;
		private var _renamedName:String;
		
		
		//******************************
		//	implement
		//******************************
		
		protected override function responseHandler(res:GLResponse):void
		{
			switch(res.code)
			{
				case GLResponseType.MORE_INFO:
					this.sendCmd(GLRequest.parse(GLRequestType.RNTO, _renamedName));
					break;
				case GLResponseType.FILE_ACTION_OK:
					this.callHandler(new GLFTPEvent(GLFTPEvent.PROCESS_FINISH));
					break;
				default:
					this.callHandler(new GLFTPEvent(GLFTPEvent.PROCESS_FAIL));
			}
		}
		
		protected override function sendRequest():void
		{
			this.sendCmd(GLRequest.parse(GLRequestType.RNFR, _remoteFileName));
		}
		
	}
}