package org.gainloss.asftp.process.group.utils
{
	import org.gainloss.asftp.utils.GLRemoteFile;
	
	/**
	 * {file:[GLRemoteFile], subfiles:[Array], currentEIndex:[int, default=0, max=subfiles.length-1]}
	 * 
	 * [subfiles] might be 
	 * 		null							this object is a simple file or link file
	 * 		Array but length is 0			empty folder
	 * 		Array(element is object too)	files in subfolder
	 */ 
	public class GLRemoteFilePack
	{
		public var file:GLRemoteFile;
		public var subfiles:Array = null;	//element is [GLRemoteFilePack]
		public var currentEIndex:int = 0; 	//[int, default=0, max=subfiles.length-1]
		
		public static function getInstance(_gl:GLRemoteFile):GLRemoteFilePack
		{
			var glr:GLRemoteFilePack = new GLRemoteFilePack();
			glr.file = _gl;
			return glr;
		}
	}
}