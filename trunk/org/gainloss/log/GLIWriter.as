package org.gainloss.log
{
	/**
	 * GLIWriter is used to record and format messages, but has no business with ouput target
	 */ 
	public interface GLIWriter
	{
		/**
		 * build rich expression
		 */ 
		function pushMsg(msg:String):void;
		
		/**
		 * get all messages
		 * 
		 * @return 		it should depends on subclass. usually it's string
		 */ 
		function get wholeMsgs():Object;
	}
}