package com.mayhem.signals 
{
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author availlant
	 */
	public class SocialSignals 
	{
		
		public static var IMAGE_LOADED:Signal = new Signal();
		public static var COINS_PURCHASE:Signal = new Signal();
		public static var COINS_PURCHASED:Signal = new Signal();
		public static var GET_LEADERBOARD_FRIENDS:Signal = new Signal();
		
		public function SocialSignals() 
		{
			
		}
		
	}

}