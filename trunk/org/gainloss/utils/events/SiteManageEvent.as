package org.gainloss.utils.events
{
	import flash.events.Event;
	
	import org.gainloss.asftp.GLFTPClient;

	public class SiteManageEvent extends Event
	{
		public function SiteManageEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		
		public static const LOGIN_OK:String = "LOGIN_OK";
		
		
		public var client:GLFTPClient;
		
	}
}