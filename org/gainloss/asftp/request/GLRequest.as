package org.gainloss.asftp.request
{
	/**
	 * The request of ftp
	 */ 
	public class GLRequest
	{
		public var command:String;		//one of GLRequestType
		public var args:String;
		
		/**
		 * @param cmd 	one of GLRequestType
		 * @param _args
		 */ 
		public static function parse(cmd:String, _args:String=""):GLRequest
		{
			var glr:GLRequest = new GLRequest();
			glr.command = cmd;
			glr.args = _args;
			return glr;
		}
		
		/**
		 * get the final command
		 * 
		 * @param	type	one type of GLRequestType
		 * @param	args	context
		 * @return
		 */
		public function toCmdStr():String
		{
			return command+" "+args;
		}
	}
}