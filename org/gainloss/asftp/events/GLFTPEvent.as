package org.gainloss.asftp.events
{
	import flash.events.Event;

	public class GLFTPEvent extends Event
	{
		public function GLFTPEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			//TODO: implement function
			super(type, bubbles, cancelable);
		}
		
		public static const PROCESS_FINISH:String = "process_finished";
		public static const PROCESS_FAIL:String = "process_failed";
		
		public var errMsg:String = "";		//available only when type is PROCESS_FAIL
	}
}