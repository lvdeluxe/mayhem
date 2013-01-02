package com.mayhem.signals 
{
	/**
	 * ...
	 * @author availlant
	 */
	import org.osflash.signals.Signal;
	 
	public class UISignals 
	{
		public static var ENERGY_UPDATE:Signal = new Signal();
		public static var ENERGY_OUT:Signal = new Signal();
		public static var OWNER_FELT:Signal = new Signal();
		public static var OWNER_RESPAWNED:Signal = new Signal();
		public static var OWNER_POWERUP_FILL:Signal = new Signal();
		public static var UPDATE_GAME_TIMER:Signal = new Signal();
		public static var CLICK_RESTART:Signal = new Signal();
		public static var SHOW_STATS:Signal = new Signal();
		public static var UPDATE_USER_INFO:Signal = new Signal();
		
		public function UISignals() 
		{
			
		}
		
	}

}