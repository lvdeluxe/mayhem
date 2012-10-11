package com.pranks.signals 
{
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author availlant
	 */
	public class UserInputSignals 
	{
		
		public static var USER_IS_MOVING:Signal = new Signal();
		public static var USER_HAS_MOVED:Signal = new Signal();
		
		public function UserInputSignals() 
		{
			
		}
		
	}

}