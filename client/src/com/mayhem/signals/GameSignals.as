package com.mayhem.signals 
{
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author availlant
	 */
	public class GameSignals 
	{
		
		public static var REFILL_POWERUP:Signal = new Signal();
		public static var SESSION_PAUSE:Signal = new Signal();
		public static var SESSION_RESTART:Signal = new Signal();
		public static var SESSION_START:Signal = new Signal();
		public static var REMOVE_MENU:Signal = new Signal();
		public static var OPEN_DOOR:Signal = new Signal();
		
		public function GameSignals() 
		{
			
		}
		
	}

}