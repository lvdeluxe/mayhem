package com.mayhem.signals 
{
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author availlant
	 */
	public class UserInputSignals 
	{
		
		public static var USER_IS_MOVING:Signal = new Signal();
		public static var USER_STOPPED_MOVING:Signal = new Signal();
		public static var USER_UPDATE_STATE:Signal = new Signal();
		public static var AI_UPDATE_STATE:Signal = new Signal();
		public static var USER_HAS_MOVED:Signal = new Signal();
		public static var USER_HAS_STOPPED_MOVING:Signal = new Signal();
		public static var USER_HAS_UPDATE_STATE:Signal = new Signal();
		public static var AI_HAS_UPDATE_STATE:Signal = new Signal();
		public static var USER_IS_COLLIDING:Signal = new Signal();
		public static var USER_IS_FALLING:Signal = new Signal();
		
		
		
		
		public function UserInputSignals() 
		{
			
		}
		
	}

}