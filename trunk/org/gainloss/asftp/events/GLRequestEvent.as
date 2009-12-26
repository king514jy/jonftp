package org.gainloss.asftp.events
{
	import flash.events.Event;
	
	import org.gainloss.asftp.request.GLRequest;

	public class GLRequestEvent extends Event
	{
		public function GLRequestEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			//TODO: implement function
			super(type, bubbles, cancelable);
		}
		
		
		public static const PROCESS_SEND_COMMAND:String = "process_send_command";
		
		public var gl:GLRequest;
	}
}