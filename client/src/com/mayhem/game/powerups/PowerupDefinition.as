package com.mayhem.game.powerups 
{
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
		private var _unlokcCredits:uint;
		private var _index:uint;
		
		public function PowerupDefinition(obj:Object) 
		{
			_id = obj.id;
			_index = obj.index;
			_title = obj.title;
			_description = obj.description;
			_unlockLevel = obj.unlockLevel;
			_unlockCoins = obj.unlockCoins;
			_unlokcCredits = obj.unlockCredits;
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
			return _unlokcCredits;
		}
		
		public function get index():uint 
		{
			return _index;
		}
		
	}

}