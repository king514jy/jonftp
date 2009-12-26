package org.gainloss.asftp.process.group
{
	import flash.events.Event;
	import flash.filesystem.*;
	
	import org.gainloss.asftp.events.*;
	import org.gainloss.asftp.process.*;
	import org.gainloss.asftp.process.group.utils.GLDownFilePack;
	import org.gainloss.asftp.request.*;
	import org.gainloss.asftp.response.*;
	import org.gainloss.asftp.utils.GLRemoteFile;
	
	[Bindable]
	/**
	 * download folder or file.
	 */ 
	public class GLGroupDownload extends GLGroup
	{
		public function GLGroupDownload(gl:GLRemoteFile, localPath:File)
		{
			//TODO: implement function
			super();
			
			if(gl == null)
			{
				throw new Error("Please select one file/folder before downloading");
			}
			
			_toDLoad = gl;
			_localFolder = localPath;
			_localFolder.createDirectory();
		}
		
		
		private var _toDLoad:GLRemoteFile;
		private var _localFolder:File;
		
		/***
		 * file list
		 */ 
		private var _downList:Array = new Array();
		
		private var _currentDownloadingRFile:GLDownFilePack;
		private var _currentDLocalFileStream:FileStream;
		
		//******************************
		//	implement
		//******************************
		
		protected override function sendRequest():void
		{
			_downList.push(GLDownFilePack.getInstance(_toDLoad));
			runList();
		}
		
		[Bindable("list_update")]
		public function get downloadingList():Array
		{
			return _downList;
		}
		
		
		private function runList():void
		{
			dispatchEvent(new Event("list_update"));
			var _gl:GLDownFilePack = _downList[0] as GLDownFilePack;	//the last one
			if(_gl)
			{
				if(_gl.file.type == "d")
				{
					//folder
					//try to get subfiles
					buildSubProcess(new GLChangeDictionary(_gl.file.url), function(event:GLFTPEvent):void{
						var glist:GLList = new GLList();
						buildSubProcess(glist, function(event:GLFTPEvent):void{
							//subfolder
							for(var i:int=0 ; i<glist.dicInfos.length ; i++)
							{
								_downList.push(GLDownFilePack.getInstance(glist.dicInfos[i] as GLRemoteFile));
							}
							//remove the folder and continue
							_downList.shift();
							runList();
						});
					});
				}
				else
				{
					//file, try donwload
					_currentDownloadingRFile = _gl;
					_currentDLocalFileStream = new FileStream();
					if(_toDLoad == _currentDownloadingRFile.file)
					{
						//only download single file
						_currentDLocalFileStream.open(_localFolder.resolvePath(_toDLoad.name), FileMode.WRITE);
					}
					else
					{
						var rfileStr:String = _currentDownloadingRFile.file.url.substr(_toDLoad.url.lastIndexOf("/")+1);
						var thefile:File = _localFolder.resolvePath(rfileStr);
						thefile.parent.createDirectory();
						_currentDLocalFileStream.open(thefile, FileMode.WRITE);
					}
					var _down:GLDownload = new GLDownload(_currentDownloadingRFile.file, onProgressHandler);
					buildSubProcess(_down, onProgressFinishedHandler);
				}
			}
			else
			{
				this.callHandler(new GLFTPEvent(GLFTPEvent.PROCESS_FINISH));
			}
		}
		
		/**
		 * reading bytes
		 * 
		 */ 
		private function onProgressHandler(event:GLProgressEvent):void
		{
			_currentDLocalFileStream.writeBytes(event.bytes);
			_currentDownloadingRFile.downloadedBytes += event.bytes.bytesAvailable;
			
			dispatchEvent(new Event("list_update"));
		}
		
		
		private function onProgressFinishedHandler(event:GLFTPEvent):void
		{
			_currentDLocalFileStream.close();
			
			//dispatchEvent(new Event("list_update"));
			//remove the first one and continue
			_downList.shift();
			runList();
		}
		
	}
}