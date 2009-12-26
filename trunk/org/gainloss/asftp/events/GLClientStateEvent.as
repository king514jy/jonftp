package org.gainloss.asftp.events
{
	import flash.events.Event;

	public class GLClientStateEvent extends Event
	{
		public function GLClientStateEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			//TODO: implement function
			super(type, bubbles, cancelable);
		}
		
		
		public static const STATE:String = "client_state";
		
		//////////////////////////////////////////////
		// state
		//////////////////////////////////////////////
		
		public static const IDLE:String = "WaitForCmd";
		public static const INVOKING:String = "Invoking";
		public static const UNCONNECTED:String = "UnConnected";
	}
}