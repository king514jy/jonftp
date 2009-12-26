package org.gainloss.asftp.request
{
	public class GLRequestType
	{
		public static const STOR:String		= "STOR";
		public static const CDUP:String		= "CDUP";		//CWD to the parent of the current directory
		public static const BINARY:String	= "TYPE I";
		public static const ASCII:String	= "TYPE A";
		public static const USER:String		= "USER";		//send user name
		public static const PASS:String		= "PASS";
		public static const QUIT:String		= "QUIT";
		public static const CWD:String		= "CWD";
		public static const PWD:String		= "PWD";
		public static const LIST:String		= "LIST";
		public static const PASV:String		= "PASV";		//enter passive mode
		public static const RETR:String		= "RETR";
		public static const MKD:String		= "MKD";		//make a remote directory
		public static const RNFR:String		= "RNFR";		//rename from
		public static const RNTO:String		= "RNTO";		//rename to
		public static const RMD:String		= "RMD";		//remove a remote dictionary
		public static const DELE:String		= "DELE";		//delete a remote file
		public static const SYST:String		= "SYST";		//system type
	}
}