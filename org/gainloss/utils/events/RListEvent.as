package org.gainloss.utils.events
{
	import flash.events.Event;
	
	import org.gainloss.asftp.utils.GLRemoteFile;

	public class RListEvent extends Event
	{
		public function RListEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			//TODO: implement function
			super(type, bubbles, cancelable);
		}
		
		public static const DOUBLE_CLICK:String = "Remote_Item_Double_Click";
		public static const DEL:String = "Del_file";
		public static const RENAME:String = "Rename_file";
		public static const DOWNLOAD:String = "Download_file";
		
		
		public var data:GLRemoteFile;
	}
}