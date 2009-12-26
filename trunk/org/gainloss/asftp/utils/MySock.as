package org.gainloss.asftp.utils
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;

	public class MySock extends Socket
	{
		public function MySock(host:String, port:int)
		{
			//TODO: implement function
			super(host, port);
			
			_host = host;
			_port = port;
			
			this.addEventListener(IOErrorEvent.IO_ERROR, onErrorNothingHandler);
			this.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorNothingHandler);
		}
		
		
		private var _host:String;
		private var _port:int = 0;
		
		
		public function get host():String
		{
			return _host;
		}
		
		public function get port():int
		{
			return _port;
		}
		
		public function connectAgain():void
		{
			this.connect(_host, _port);
		}
		
		
		private function onErrorNothingHandler(event:Event):void
		{
			trace(event.toString());
		}
		
		
		/////////////////////////////////////////
		
		/**
		 * create pasv socket
		 */ 
		public static function parsePASVSock(responseStr:String):MySock
		{
			var match:Array = responseStr.match(/(\d{1,3},){5}\d{1,3}/);
			if(match == null)
				throw new Error("response is invalid");
				
			var data:Array = match[0].split(",");
			var host:String = data.slice(0,4).join(".");
			var port:int = parseInt(data[4])*256+parseInt(data[5]);
			
			return new MySock(host, port);
		}
		
	}
}