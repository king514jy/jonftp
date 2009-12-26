package org.gainloss.utils.events
{
	import flash.events.Event;
	import flash.filesystem.File;

	public class LListEvent extends Event
	{
		public function LListEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			//TODO: implement function
			super(type, bubbles, cancelable);
		}
		
		
		public static const UPLOAD:String = "Upload_file";
		
		public var data:File;
	}
}