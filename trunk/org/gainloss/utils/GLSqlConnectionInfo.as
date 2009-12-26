package org.gainloss.utils
{
	import flash.data.*;
	import flash.filesystem.File;
	
	/**
	 * create connection to db
	 */ 
	public class GLSqlConnectionInfo
	{
		private static var conn:SQLConnection;
		
		
		public static function getConnection():SQLConnection
		{
			if(conn == null || !conn.connected)
			{
				var dbfile:File = File.applicationStorageDirectory.resolvePath("records.db");
				
				conn = new SQLConnection();
				conn.open(dbfile);
				
				//create tables
				var stat1:SQLStatement = new SQLStatement();
				stat1.sqlConnection = conn;
				stat1.text = "create table if not exists sites (site_id integer primary key autoincrement, site_name text default '', site_host text default '', site_port integer default 21, site_username text default '', site_pwd text default '', flag integer default 1, created_time text default CURRENT_TIMESTAMP)";
				stat1.execute();
			}
			return conn;
		}
	}
}