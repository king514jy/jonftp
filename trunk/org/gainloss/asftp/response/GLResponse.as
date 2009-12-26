package org.gainloss.asftp.response
{
	/**
	 * The response of ftp
	 */ 
	public class GLResponse
	{
		public var code:int;			//code of response, check org.gainloss.asftp.response.GLResponseType
		public var message:String;		//body of response
		public var isMultiline:Boolean	//message may have multiple lines
		
		/**
		 * analysis response string
		 */ 
		public static function parse(_response_str:String):GLResponse
		{
			var glr:GLResponse = new GLResponse();
			glr.code = parseInt(_response_str.substr(0,3));
			glr.message = _response_str.substr(4).replace(/[\r\n]+$/gm, "");
			glr.isMultiline = (_response_str.charAt(3)=="-");
			return glr;
		}
	}
}