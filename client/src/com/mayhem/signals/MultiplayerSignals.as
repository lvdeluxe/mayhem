package com.mayhem.signals 
{
	import org.osflash.signals.natives.base.SignalBitmap;
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author availlant
	 */
	public class MultiplayerSignals 
	{
		
		public static var CONNECTED:Signal = new Signal();
		public static var USER_LOADED:Signal = new Signal();
		public static var USER_JOINED:Signal = new Signal();
		public static var USERS_IN_ROOM:Signal = new Signal();
		public static var USER_REMOVED:Signal = new Signal();
		public static var USER_HAS_COLLIDED:Signal = new Signal();
		public static var POWERUP_TRIGGERED:Signal = new Signal();
		public static var SESSION_PAUSED:Signal = new Signal();
		public static var SESSION_RESTARTED:Signal = new Signal();
		public static var UPDATE_AI_TARGET:Signal = new Signal();
		public static var AI_TARGET_UPDATED:Signal = new Signal();
		public static var VEHICLE_DIE:Signal = new Signal();
		public static var VEHICLE_DIED:Signal = new Signal();
		static public const CREATE_AI_VEHICLES:Signal = new Signal();
		static public const POWERUP_UNLOCK:Signal = new Signal();
		static public const POWERUP_UNLOCKED:Signal = new Signal();
		static public const POWERUP_CREDITS_UNLOCK:Signal = new Signal();
		static public const SLOT_UNLOCK:Signal = new Signal();
		static public const SLOT_UNLOCKED:Signal = new Signal();
		static public const SLOT_CREDITS_UNLOCK:Signal = new Signal();
		static public const SLOT_CREDITS_UNLOCKED:Signal = new Signal();
		static public const CHANGE_MUSIC_SETTINGS:Signal = new Signal();
		static public const LEVEL_UP:Signal = new Signal();
		
		public function MultiplayerSignals() 
		{
			
		}
		
	}

}