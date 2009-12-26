package org.gainloss.asftp.process.group.utils
{
	import flash.filesystem.File;
	
	/**
	 * local file
	 */ 
	public class GLUpFilePack
	{
		public var file:File;
		public var downloadedBytes:Number = 0;
		
		
		public static function getInstance(_f:File):GLUpFilePack
		{
			var glu:GLUpFilePack = new GLUpFilePack();
			glu.file = _f;
			return glu;
		}
	}
}