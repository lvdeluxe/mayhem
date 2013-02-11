package com.mayhem.game.powerups 
{
	import playerio.DatabaseObject;
	/**
	 * ...
	 * @author availlant
	 */
	public class PowerupDefinition 
	{
		private var _id:String;
		private var _title:String;
		private var _description:String;
		private var _unlockLevel:uint;
		private var _unlockCoins:uint;
		private var _unlockCredits:uint;
		//private var _index:uint;
		
		public function PowerupDefinition(obj:DatabaseObject) 
		{
			_id = obj.key;
			_title = obj.Title;
			_description = obj.Description;
			_unlockLevel = obj.UnlockLevel;
			_unlockCoins = obj.PriceCoins;
			_unlockCredits = obj.PriceFBC;
		}
		
		public function get id():String 
		{
			return _id;
		}
		
		public function get title():String 
		{
			return _title;
		}
		
		public function get description():String 
		{
			return _description;
		}
		
		public function get unlockLevel():uint 
		{
			return _unlockLevel;
		}
		
		public function get unlockCoins():uint 
		{
			return _unlockCoins;
		}
		
		public function get unlokcCredits():uint 
		{
			return _unlockCredits;
		}		
	}

}