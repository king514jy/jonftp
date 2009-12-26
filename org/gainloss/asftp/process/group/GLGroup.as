package org.gainloss.asftp.process.group
{
	import org.gainloss.asftp.events.GLFTPEvent;
	import org.gainloss.asftp.events.GLRequestEvent;
	import org.gainloss.asftp.process.GLProcess;
	import org.gainloss.asftp.response.GLResponse;
	
	/**
	 * this is abstract class
	 * 
	 * all its subclass are allowed to run multiply processes in queue
	 */ 
	public class GLGroup extends GLProcess
	{
		public function GLGroup()
		{
			//TODO: implement function
			super();
		}
		
		/*
		public final function set client(_c:GLFTPClient):void
		{
			_client = _c;
		}
		
		protected var _client:GLFTPClient;*/
		
		
		private var _currentSubProcess:GLProcess;
		private var _currentSubHandler:Function;
		
		
		protected override function responseHandler(res:GLResponse):void
		{
			//do nothing
			if(_currentSubProcess)
			{
				_currentSubProcess.response(res);
			}
		}
		
		
		/////////////////////////////////////
		
		protected function buildSubProcess(_process:GLProcess, _handler:Function):void
		{
			try
			{
				clear();
				
				_currentSubProcess = _process;
				_currentSubHandler = _handler;
				
				_currentSubProcess.addEventListener(GLRequestEvent.PROCESS_SEND_COMMAND, onTryToSendCMDHandler);
				_currentSubProcess.addEventListener(GLFTPEvent.PROCESS_FINISH, myProcessHandler);
				_currentSubProcess.addEventListener(GLFTPEvent.PROCESS_FAIL, myProcessHandler);
				
				//call it
				_currentSubProcess.request();
			}
			catch(e:Error)
			{
				//nothing
			}
		}
		
		/**
		 * send command to socket
		 */ 
		private function onTryToSendCMDHandler(event:GLRequestEvent):void
		{
			event.stopPropagation();
			//send again
			/*
			var eve:GLRequestEvent = new GLRequestEvent(GLRequestEvent.PROCESS_SEND_COMMAND);
			eve.gl = event.gl;
			dispatchEvent(eve);*/
			sendCmd(event.gl);
		}
		
		private function clear():void
		{
			if(_currentSubProcess)
			{
				_currentSubProcess.cancel();
				
				_currentSubProcess.removeEventListener(GLRequestEvent.PROCESS_SEND_COMMAND, onTryToSendCMDHandler);
				_currentSubProcess.removeEventListener(GLFTPEvent.PROCESS_FINISH, myProcessHandler);
				_currentSubProcess.removeEventListener(GLFTPEvent.PROCESS_FAIL, myProcessHandler);
				
				_currentSubProcess = null;
				_currentSubHandler = null;
			}
		}
		
		/**
		 * receive sub process's event
		 */ 
		private function myProcessHandler(event:GLFTPEvent):void
		{
			if(_currentSubHandler)
			{
				_currentSubHandler(event);
			}
		}
		
	}
}