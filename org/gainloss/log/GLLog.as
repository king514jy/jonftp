package org.gainloss.log
{
	import flash.events.EventDispatcher;
	
	[Bindable]
	public class GLLog extends EventDispatcher
	{
		public function GLLog()
		{
			//TODO: implement function
			super();
		}
		
		/**
		 * every element should be instance of GLIWriter
		 */ 
		private var writers:Array = new Array();
		
		/////////////////////////////////////////
		//
		// global settings
		//
		/////////////////////////////////////////
		
		private static var owner:GLLog;
		
		public static function getInstance():GLLog
		{
			if(owner == null)
			{
				owner = new GLLog();
			}
			return owner;
		}
		
		/**
		 * add writer
		 * 
		 * @param _writer	subclass of GLIWriter
		 */ 
		public static function addWriter(_writer:Class):void
		{
			var _writers:Array = GLLog.getInstance().writers;
			if(_writers)
			{
				for(var i:int=0 ; i<_writers.length ; i++)
				{
					if(_writers[i] is _writer)
					{
						return;
					}
				}
				_writers.push(new _writer());
			}
		}
		
		/**
		 *	get its instance by class
		 */ 
		public static function getWriterInstance(_writer:Class):GLIWriter
		{
			var _writers:Array = GLLog.getInstance().writers;
			if(_writers)
			{
				for(var i:int=0 ; i<_writers.length ; i++)
				{
					if(_writers[i] is _writer)
					{
						return _writers[i] as GLIWriter;
					}
				}
			}
			
			return null;
		}
		
		/**
		 * remove one writer
		 * 
		 * @param _writer	subclass of GLIWriter
		 */ 
		public static function removeWriter(_writer:Class):void
		{
			var _writers:Array = GLLog.getInstance().writers;
			if(_writers)
			{
				for(var i:int=0 ; i<_writers.length ; i++)
				{
					if(_writers[i] is _writer)
					{
						GLLog.getInstance().writers = _writers.splice(i,1);
					}
				}
			}
		}
		
		
		///////////////////////////////////////////////
		
		/**
		 * record state message
		 * 
		 * @param msg
		 */ 
		public final function pushStateMsg(msg:String):void
		{
			pushMsg("STATE: "+msg);
		}
		
		/**
		 * record error message
		 * 
		 * @param msg
		 */
		public final function pushErrorMsg(msg:String):void
		{
			pushMsg("ERROR: "+msg);
		}
		
		/**
		 * record common message, no prefix
		 * 
		 * @param msg
		 */
		public final function pushCommonMsg(msg:String):void
		{
			pushMsg(msg);
		}
		
		/**
		 * build rich expression
		 */ 
		protected function pushMsg(msg:String):void
		{
			if(writers)
			{
				for(var i:int=0 ; i<writers.length ; i++)
				{
					try
					{
						(writers[i] as GLIWriter).pushMsg(msg);
					}
					catch(e:Error)
					{
						//the instance is not the subone of GLIWriter
					}
				}
			}
		}
		
	}
}