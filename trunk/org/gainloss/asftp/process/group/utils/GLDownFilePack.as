package org.gainloss.asftp.process.group.utils
{
	import org.gainloss.asftp.utils.GLRemoteFile;
	
	/**
	 * remoteFile and bytes
	 */ 
	public class GLDownFilePack
	{
		public var file:GLRemoteFile;
		public var downloadedBytes:Number;	//total bytes == file.size
		
		public static function getInstance(gl:GLRemoteFile):GLDownFilePack
		{
			var gld:GLDownFilePack = new GLDownFilePack();
			gld.file = gl;
			gld.downloadedBytes = 0;
			return gld;
		}
	}
}