package org.gainloss.asftp.events
{
	import flash.events.Event;
	import flash.utils.ByteArray;

	public class GLProgressEvent extends Event
	{
		public function GLProgressEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			//TODO: implement function
			super(type, bubbles, cancelable);
		}
		
		public static const PROCESS_PROGRESS:String = "PROCESS_PROGRESS";
		
		public var bytes:ByteArray = new ByteArray();
		//public var totalBytes:int = 0;
		
		public var new_processed_bytes_length:Number = 0;
	}
}