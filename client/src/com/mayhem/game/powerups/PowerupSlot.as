package com.mayhem.game.powerups 
{
	import playerio.DatabaseObject;
	/**
	 * ...
	 * @author availlant
	 */
	public class PowerupSlot 
	{
		
		private var _id:String;
		private var _unlockLevel:int;
		private var _unlockCoins:int;
		private var _unlockCredits:int;
		
		public function PowerupSlot(dbObj:DatabaseObject) 
		{
			_id = dbObj.key;
			_unlockLevel = dbObj.UnlockLevel;
			_unlockCoins = dbObj.PriceCoins;
			_unlockCredits = dbObj.PriceFBC;
		}
		
		public function get id():String 
		{
			return _id;
		}
		
		public function get unlockLevel():int 
		{
			return _unlockLevel;
		}
		
		public function get unlockCoins():int 
		{
			return _unlockCoins;
		}
		
		public function get unlockCredits():int 
		{
			return _unlockCredits;
		}
		
	}

}