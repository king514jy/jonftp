package org.gainloss.log
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * only pure list
	 */ 
	public class GLPureWriter extends EventDispatcher implements GLIWriter
	{
		public function GLPureWriter()
		{
			//TODO: implement function
		}
		
		private var _list:String = "";

		public function pushMsg(msg:String):void
		{
			//TODO: implement function
			_list += msg+"\n"
			this.dispatchEvent(new Event("NEWLISTMSG"));
		}
		
		[Bindable(name="NEWLISTMSG")]
		public function get wholeMsgs():Object
		{
			//TODO: implement function
			return _list;
		}
	}
}