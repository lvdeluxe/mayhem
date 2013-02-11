package com.mayhem.multiplayer 
{
	import playerio.DatabaseObject;
	/**
	 * ...
	 * @author availlant
	 */
	public class CoinsPackage 
	{
		private var _id:String;
		private var _amount:int;
		private var _cost:int;
		
		public function CoinsPackage(obj:DatabaseObject) 
		{
			_id = obj.key;
			_amount = obj.Amount;
			_cost = obj.PriceFBC;
		}
		
		public function get id():String 
		{
			return _id;
		}
		
		public function get amount():int 
		{
			return _amount;
		}
		
		public function get cost():int 
		{
			return _cost;
		}
		
	}

}