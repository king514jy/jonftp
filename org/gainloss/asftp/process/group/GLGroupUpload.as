package org.gainloss.asftp.process.group
{
	import flash.filesystem.File;
	
	import org.gainloss.asftp.GLFTPClient;
	import org.gainloss.asftp.events.GLFTPEvent;
	import org.gainloss.asftp.events.GLProgressEvent;
	import org.gainloss.asftp.process.GLMakeNewFolder;
	import org.gainloss.asftp.process.GLUpload;
	import org.gainloss.asftp.process.group.utils.GLUpFilePack;
	
	[Bindable]
	/**
	 * might upload multiple files or dictionaries
	 */ 
	public class GLGroupUpload extends GLGroup
	{
		/**
		 * @param localFile 					file or dictionary
		 * @param currentRemoteFolderStr		remote path
		 */ 
		public function GLGroupUpload(localFile:File, currentRemoteFolderStr:String)
		{
			//TODO: implement function
			super();
			
			if(localFile == null)
			{
				throw new Error("Please select one file/folder before uploading");
			}
			
			_currentRemoteFolderStr = currentRemoteFolderStr;
			_localFile = localFile;
			_parentFolder = _localFile.parent;
		}
		
		
		private var _localFile:File;
		private var _parentFolder:File;
		private var _currentRemoteFolderStr:String;
		
		private var _currentUploadingPack:GLUpFilePack;
		
		/**
		 * queue of upload files
		 */ 
		private var _upList:Array = new Array();
		
		[Bindable("list_update")]
		public function get uploadingList():Array
		{
			return _upList;
		}
		
		//******************************
		//	implement
		//******************************
		
		protected override function sendRequest():void
		{
			_upList.push(GLUpFilePack.getInstance(_localFile));
			runList();
		}
		
		
		private function runList():void
		{
			dispatchEvent(new Event("list_update"));
			var _glu:GLUpFilePack = _upList[0] as GLUpFilePack;
			if(_glu)
			{
				if(_glu.file.isDirectory)
				{
					//folder
					var farr:Array = _glu.file.getDirectoryListing();
					for(var i:int=0 ; i<farr.length ; i++)
					{
						_upList.push(GLUpFilePack.getInstance(farr[i] as File));
					}
					
					//try to create remote folder, corresponding to local path
					var _remoteFolderToMake:String = _currentRemoteFolderStr + GLFTPClient.REMOTE_SEPERATOR + _parentFolder.getRelativePath(_glu.file);
					buildSubProcess(new GLMakeNewFolder(_remoteFolderToMake), onFinishedHandler);
				}
				else
				{
					//file
					_currentUploadingPack = _glu;
					var _remoteFileToUp:String = _currentRemoteFolderStr + GLFTPClient.REMOTE_SEPERATOR + _parentFolder.getRelativePath(_currentUploadingPack.file);
					var _upload:GLUpload = new GLUpload(_currentUploadingPack.file, _remoteFileToUp, onProgressHandler);
					buildSubProcess(_upload, onFinishedHandler);
				}
			}
			else
			{
				//queue is empty
				this.callHandler(new GLFTPEvent(GLFTPEvent.PROCESS_FINISH));
			}
		}
		
		private function onProgressHandler(event:GLProgressEvent):void
		{
			_currentUploadingPack.downloadedBytes += event.new_processed_bytes_length;
			dispatchEvent(new Event("list_update"));
		}
		
		/**
		 * after uploading
		 */ 
		private function onFinishedHandler(event:GLFTPEvent):void
		{
			//remove the first one and continue
			_upList.shift();
			runList();
		}
		
	}
}