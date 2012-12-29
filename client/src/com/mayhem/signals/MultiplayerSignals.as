package com.mayhem.signals 
{
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author availlant
	 */
	public class MultiplayerSignals 
	{
		
		public static var USER_JOINED:Signal = new Signal();
		public static var USERS_IN_ROOM:Signal = new Signal();
		public static var USER_REMOVED:Signal = new Signal();
		public static var USER_HAS_COLLIDED:Signal = new Signal();
		public static var POWERUP_TRIGGERED:Signal = new Signal();
		public static var SESSION_PAUSE:Signal = new Signal();
		public static var SESSION_PAUSED:Signal = new Signal();
		
		public function MultiplayerSignals() 
		{
			
		}
		
	}

}