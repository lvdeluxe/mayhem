package com.mayhem.signals 
{
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author availlant
	 */
	public class MultiplayerSignals 
	{
		
		public static var USER_CREATED:Signal = new Signal();
		public static var USER_REMOVED:Signal = new Signal();
		
		public function MultiplayerSignals() 
		{
			
		}
		
	}

}