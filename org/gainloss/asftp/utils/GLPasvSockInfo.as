package org.gainloss.asftp.utils
{
	import org.gainloss.asftp.response.GLResponse;
	
	/**
	 * passive socket
	 */ 
	public class GLPasvSockInfo
	{
		
		/**
		 * @param response	std GLResponse
		 */ 
		public function GLPasvSockInfo(response:GLResponse)
		{
			//TODO: implement function
			try
			{
				parse(response.message);
			}
			catch(e:Error)
			{
				//nothing
			}
		}
		
		
		private var mysock:MySock;
		
		private function parse(responseStr:String):void
		{
			var match:Array = responseStr.match(/(\d{1,3},){5}\d{1,3}/);
			if(match == null)
				throw new Error("response is invalid");
				
			var data:String = match[0].split(",");
			var host:String = data.slice(0,4).join(".");
			var port:int = parseInt(data[4])*256+parseInt(data[5]);
			
			mysock = new MySock(host, port);
		}

	}
}