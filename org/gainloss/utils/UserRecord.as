package org.gainloss.utils
{
	import flash.data.SQLStatement;
	
	public class UserRecord
	{
		public var siteName:String	="";
		
		public var host:String		=""//"59.63.41.90";
		public var port:int			=21;
		public var username:String	=""//"noahgeniu";
		public var pwd:String		="";
		
		
		//////////////////////////////////////////
		/*
		private static const JONFTP_SO_NAME:String = "JONFTP_SO_NAME";
		
		public static function createFromSO():UserRecord
		{
			var rec:Object = SharedObject.getLocal(JONFTP_SO_NAME).data["record"]
			
			var ur:UserRecord = new UserRecord();
			if(rec)
			{
				ur.host = rec["host"].toString();
				ur.port = parseInt(rec["port"]);
				ur.username = rec["username"].toString();
			}
			return ur;
		}
		*/
		
		//////////////////////////////////////////
		
		
		/*
		public static function saveRecord(ur:UserRecord):void
		{
			if(SharedObject.getLocal(JONFTP_SO_NAME).data["records"] == null)
			{
				SharedObject.getLocal(JONFTP_SO_NAME).data["records"] = new Array();
			}
			(SharedObject.getLocal(JONFTP_SO_NAME).data["records"] as Array).push(ur);
			//SharedObject.getLocal(JONFTP_SO_NAME).data["record"] = ur;
			//SharedObject.getLocal(JONFTP_SO_NAME).data["record"]["pwd"] = null;
		}
		
		public static function removeUserRecord(_index:int):void
		{
			if(SharedObject.getLocal(JONFTP_SO_NAME).data["records"] is Array && _index >= 0)
			{
				var arr:Array = createRecordsFromSO();
				arr.splice(_index, 1);
				//SharedObject.getLocal(JONFTP_SO_NAME).clear();
				//SharedObject.getLocal(JONFTP_SO_NAME).flush();
				SharedObject.getLocal(JONFTP_SO_NAME).data["records"] = new Array();
				for(var i:int=0 ; i<arr.length ; i++)
				{
					saveRecord(arr[i] as UserRecord);
				}
			}
		}
		
		public static function clearAllRecords():void
		{
			SharedObject.getLocal(JONFTP_SO_NAME).data["records"] = new Array();
			SharedObject.getLocal(JONFTP_SO_NAME).flush();
		}
		
		public static function createRecordsFromSO():Array
		{
			var arr:Array = new Array();
			
			var rec:Array = SharedObject.getLocal(JONFTP_SO_NAME).data["records"] as Array;		//records
			if(rec)
			{
				for(var i:int=0 ; i<rec.length ; i++)
				{
					try
					{
						var ur:UserRecord = new UserRecord();
						
						ur.siteName = rec[i]["siteName"].toString();
						
						ur.host = rec[i]["host"].toString();
						ur.port = parseInt(rec[i]["port"]);
						ur.username = rec[i]["username"].toString();
						
						arr.push(ur);
					}
					catch(e:Error)
					{
						//nothing
					}
				}
			}
			
			return arr;
		}*/
		
		
		//////////////////////////////////////////
		
		/**
		 * select all
		 */ 
		public static function createRecordsFromSO():Array
		{
			var stat:SQLStatement = new SQLStatement();
			stat.sqlConnection = GLSqlConnectionInfo.getConnection();
			stat.text = "select * from sites where flag=1";
			stat.execute();
			
			return stat.getResult().data;
		}
		
		/**
		 * remove record
		 * 
		 * @param _index		id of record
		 */ 
		public static function removeUserRecord(_index:int):void
		{
			var stat:SQLStatement = new SQLStatement();
			stat.sqlConnection = GLSqlConnectionInfo.getConnection();
			stat.text = "update sites set flag=0 where site_id=?";
			stat.parameters[0] = _index;
			stat.execute();
		}
		
		/**
		 * rename
		 * 
		 * @param _index		id of record
		 * @param siteName
		 */ 
		public static function renameUserRecord(_index:int, siteName:String):void
		{
			var stat:SQLStatement = new SQLStatement();
			stat.sqlConnection = GLSqlConnectionInfo.getConnection();
			stat.text = "update sites set site_name=? where site_id=?";
			stat.parameters[0] = siteName;
			stat.parameters[1] = _index;
			stat.execute();
		}
		
		/**
		 * save this record
		 */ 
		public static function saveRecord(ur:UserRecord):void
		{
			var stat:SQLStatement = new SQLStatement();
			stat.sqlConnection = GLSqlConnectionInfo.getConnection();
			stat.text = "insert into sites (site_name, site_host, site_port, site_username) values(?,?,?,?)";
			stat.parameters[0] = ur.siteName;
			stat.parameters[1] = ur.host;
			stat.parameters[2] = ur.port;
			stat.parameters[3] = ur.username;
			stat.execute();
		}
	}
}