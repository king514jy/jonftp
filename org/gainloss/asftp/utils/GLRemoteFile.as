package org.gainloss.asftp.utils
{
	import flash.events.EventDispatcher;
	
	import org.gainloss.asftp.GLFTPClient;

	public class GLRemoteFile extends EventDispatcher
	{
		public function GLRemoteFile()
		{
			//TODO: implement function
			super();
		}
		
		
		public var name:String = "";
		public var url:String = "";
		public var lastModifiedDate:String = "";	//date time
		public var size:Number = 0;					//bytes
		//public var isDictionary:Boolean=false;	//is dictionary or file
		public var type:String = "-"					//d,-,or l
		
		public var theLink:String = null;			//it's avaiable only if the type is 'l'
		
		
		public static function parseFromItemOfList(itemstr:String):GLRemoteFile
		{
			try
			{
				var glr:GLRemoteFile = new GLRemoteFile();
				//different system has different way
				if(GLFTPClient.remoteSysType == GLFTPClient.TYPE_WIN_NT)
				{
					/* MSDOS format */
				    /* 04-27-00  09:09PM       <DIR>          licensed */
				    /* 07-18-00  10:16AM       <DIR>          pub */
				    /* 04-14-00  03:47PM                  589 readme.htm */
					var items:Array = itemstr.split(/\s+/g);
					glr.name = itemstr.substr(itemstr.indexOf(items[3].toString()));
					glr.lastModifiedDate = items.slice(0,1).join(" ");
					glr.size = (items[2].toString()=="<DIR>")?0:parseInt(items[2]);
					glr.type = (items[2].toString()=="<DIR>")?"d":"-"
				}
				else
				{
					/* UNIX-style listing, without inum and without blocks */
				    /* "-rw-r--r--   1 root     other        531 Jan 29 03:26 README" */
				    /* "dr-xr-xr-x   2 root     other        512 Apr  8  1994 etc" */
				    /* "dr-xr-xr-x   2 root     512 Apr  8  1994 etc" */
				    /* "lrwxrwxrwx   1 root     other          7 Jan 25 00:17 bin -> usr/bin" */
				    /* Also produced by Microsoft's FTP servers for Windows: */
				    /* "----------   1 owner    group         1803128 Jul 10 10:18 ls-lR.Z" */
				    /* "d---------   1 owner    group               0 May  9 19:45 Softlib" */
				    /* Also WFTPD for MSDOS: */
				    /* "-rwxrwxrwx   1 noone    nogroup      322 Aug 19  1996 message.ftp" */
				    /* Also NetWare: */
				    /* "d [R----F--] supervisor            512       Jan 16 18:53    login" */
				    /* "- [R----F--] rhesus             214059       Oct 20 15:27    cx.exe" */
				    /* Also NetPresenz for the Mac: */
				    /* "-------r--         326  1391972  1392298 Nov 22  1995 MegaPhone.sit" */
				    /* "drwxrwxr-x               folder        2 May 10  1996 network" */
					
					//default is GLFTPClient.UNIX
					var items:Array = itemstr.split(/\s+/g);
					glr.type = items[0].toString().charAt(0)//items[0].toString().charAt(0)=="d" || items[0].toString().charAt(0)=="l"
					if(glr.type == "l")
					{
						//link
						glr.name = itemstr.substring(itemstr.indexOf(items[8].toString()), itemstr.lastIndexOf("->")-1);
						glr.theLink = itemstr.substring(itemstr.lastIndexOf("->")+3);
					}
					else
					{
						glr.name = itemstr.substr(itemstr.indexOf(items[8].toString()));
					}
					glr.lastModifiedDate = items.slice(5,8).join(" ");
					glr.size = parseInt(items[4]);
					//glr.isDictionary = (parseInt(items[1])>1);
				}
				return glr
			}
			catch(e:Error)
			{
				trace(e.message);
			}
			return null;
		}
	}
}