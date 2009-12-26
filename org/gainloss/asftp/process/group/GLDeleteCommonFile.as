package org.gainloss.asftp.process.group
{
	import org.gainloss.asftp.events.*;
	import org.gainloss.asftp.process.*;
	import org.gainloss.asftp.process.group.utils.GLRemoteFilePack;
	import org.gainloss.asftp.request.*;
	import org.gainloss.asftp.response.*;
	import org.gainloss.asftp.utils.GLRemoteFile;
	
	/**
	 * can delete file or dictionary, not only simple file
	 */ 
	public class GLDeleteCommonFile extends GLGroup
	{
		public function GLDeleteCommonFile(glr:GLRemoteFile)
		{
			//TODO: implement function
			super();
			
			if(glr == null)
			{
				throw new Error("Please select one file/folder before deleting");
			}
			
			_toDeleted = glr;
			//_remoteTree = {name:glr.name, subfiles:null}	//assume it's simple file
		}
		
		private var _toDeleted:GLRemoteFile;
		
		/**
		 * {file:[GLRemoteFile], subfiles:[Array], currentEIndex:[int, default=0, max=subfiles.length-1]}
		 * 
		 * [subfiles] might be 
		 * 		null							this object is a simple file or link file
		 * 		Array but length is 0			empty folder
		 * 		Array(element is object too)	files in subfolder
		 */ 
		private var _delStack:Array = new Array();
		
		private var _errorDelFiles:Array = new Array();
		private var _deletingFile:GLRemoteFile;
		
		//******************************
		//	implement
		//******************************
		
		protected override function sendRequest():void
		{
			_delStack.push(GLRemoteFilePack.getInstance(_toDeleted));
			runStack();
		}
		
		////////////////////////////////////////////
		
		/**
		 * do it
		 */ 
		private function runStack():void
		{
			var lastEle:GLRemoteFilePack = _delStack[_delStack.length-1] as GLRemoteFilePack;	//get the last one
			if(lastEle)
			{
				_deletingFile = lastEle.file;
				if(lastEle.file.type == "d")
				{
					//folder
					if(lastEle.subfiles)
					{
						if(lastEle.currentEIndex >= lastEle.subfiles.length)
						{
							//delete empty folder
							_delStack.pop();		//delete [lastEle]
							//_client.tryInvoke(new GLDeleteFile(lastEle.file), afterRemovingEmptyFolder);
							buildSubProcess(new GLDeleteFile(lastEle.file), afterRemovingEmptyFolder);
						}
						else
						{
							handleSubFiles(lastEle);
						}
					}
					else
					{
						//try to get subfiles
						buildSubProcess(new GLChangeDictionary(lastEle.file.url), function(event:GLFTPEvent):void{
							var glist:GLList = new GLList();
							buildSubProcess(glist, function(event:GLFTPEvent):void{
								//subfolder
								//lastEle.subfiles = glist.dicInfos;
								lastEle.subfiles = new Array();
								for(var i:int=0 ; i<glist.dicInfos.length ; i++)
								{
									lastEle.subfiles.push(GLRemoteFilePack.getInstance(glist.dicInfos[i] as GLRemoteFile));
								}
								handleSubFiles(lastEle);
							});
						});
					}
				}
				else
				{
					//file
					_delStack.pop();		//delete [lastEle]
					buildSubProcess(new GLDeleteFile(lastEle.file), afterRemovingFile);
				}
			}
			else
			{
				//callHandler(new GLFTPEvent(GLFTPEvent.PROCESS_FINISH));
				if(_errorDelFiles.length <= 0)
				{
					callHandler(new GLFTPEvent(GLFTPEvent.PROCESS_FINISH));
				}
				else
				{
					var eve:GLFTPEvent = new GLFTPEvent(GLFTPEvent.PROCESS_FAIL);
					for(var j:int=0 ; j<_errorDelFiles.length ; j++)
					{
						eve.errMsg += "\""+(_errorDelFiles[j] as GLRemoteFile).name+"\" can not be deleted.\n";
					}
				}
			}
		}
		
		/**
		 * call "GLDeleteFile" to del folder
		 */ 
		private function afterRemovingEmptyFolder(event:GLFTPEvent):void
		{
			if(event.type == GLFTPEvent.PROCESS_FAIL)
			{
				//del folder fail
				_errorDelFiles.push(_deletingFile);
			}
			runStack();
		}
		
		/**
		 * call "GLDeleteFile" to del file
		 */ 
		private function afterRemovingFile(event:GLFTPEvent):void
		{
			try
			{
				if(event.type == GLFTPEvent.PROCESS_FAIL)
				{
					//del file fail
					_errorDelFiles.push(_deletingFile);
				}
				handleSubFiles(_delStack[_delStack.length-1] as GLRemoteFilePack);
			}
			catch(e:Error)
			{
				//nothing
			}
		}
		
		/**
		 * continue handle sub files
		 */ 
		private function handleSubFiles(_parent:GLRemoteFilePack):void
		{
			try
			{
				var subfile:GLRemoteFilePack = _parent.subfiles[_parent.currentEIndex] as GLRemoteFilePack;
				if(subfile)
				{
					_parent.currentEIndex++;
					_delStack.push(subfile);
					runStack();
				}
				else
				{
					//no subfiles
					runStack();
				}
			}
			catch(e:Error)
			{
				//no subfiles
				runStack();
			}
		}
	}
}