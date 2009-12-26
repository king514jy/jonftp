package org.gainloss.asftp.process
{
	import org.gainloss.asftp.events.GLFTPEvent;
	import org.gainloss.asftp.request.*;
	import org.gainloss.asftp.response.*;
	
	
	/**
	 * change dictionary
	 */
	public class GLChangeDictionary extends GLProcess
	{
		/**
		 * @param remoteDictionary		remote dictionary, or [PARENT_DIC]
		 */ 
		public function GLChangeDictionary(remoteDictionary:String)
		{
			//TODO: implement function
			super();
			
			_dic = remoteDictionary;
		}
		
		private var _dic:String = "";	//remote dictionary
		
		public static const PARENT_DIC:String = "parent_dic";
		
		//******************************
		//	implement
		//******************************
		
		protected override function responseHandler(res:GLResponse):void
		{
			switch(res.code)
			{
				case GLResponseType.FILE_ACTION_OK:
					this.callHandler(new GLFTPEvent(GLFTPEvent.PROCESS_FINISH));
					break;
				/*case GLResponseType.NOT_FOUND:
					this.callHandler(new GLFTPEvent(GLFTPEvent.PROCESS_FAIL));
					break;*/
				default:
					this.callHandler(new GLFTPEvent(GLFTPEvent.PROCESS_FAIL));
			}
		}
		
		protected override function sendRequest():void
		{
			//do nothing
			if(PARENT_DIC==_dic)
			{
				this.sendCmd(GLRequest.parse(GLRequestType.CDUP));
			}
			else
			{
				this.sendCmd(GLRequest.parse(GLRequestType.CWD, _dic));
			}
		}
	}
}