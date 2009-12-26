package org.gainloss.asftp.process
{
	import org.gainloss.asftp.events.GLFTPEvent;
	import org.gainloss.asftp.request.*;
	import org.gainloss.asftp.response.*;
	
	/**
	 * make new folder
	 */ 
	public class GLMakeNewFolder extends GLProcess
	{
		public function GLMakeNewFolder(folderName:String)
		{
			//TODO: implement function
			super();
			
			_folderName = folderName;
		}
		
		private var _folderName:String
		
		//******************************
		//	implement
		//******************************
		
		protected override function responseHandler(res:GLResponse):void
		{
			switch(res.code)
			{
				case GLResponseType.PATHNAME_CREATED:
					this.callHandler(new GLFTPEvent(GLFTPEvent.PROCESS_FINISH));
					break;
				default:
					this.callHandler(new GLFTPEvent(GLFTPEvent.PROCESS_FAIL));
			}
		}
		
		protected override function sendRequest():void
		{
			this.sendCmd(GLRequest.parse(GLRequestType.MKD, _folderName));
		}
		
	}
}