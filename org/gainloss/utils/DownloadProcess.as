package org.gainloss.utils
{
	import flash.filesystem.File;
	
	import org.gainloss.asftp.process.GLProcess;
	import org.gainloss.asftp.utils.GLRemoteFile;
	
	[Bindable]
	public class DownloadProcess
	{
		public var process:GLProcess;		//default is null
		public var file:GLRemoteFile;
		public var lfile:File;
		public var progress:Number = 0; 	//0-100
	}
}