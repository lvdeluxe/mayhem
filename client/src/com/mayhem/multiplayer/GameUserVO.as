package com.mayhem.multiplayer 
{
	/**
	 * ...
	 * @author availlant
	 */
	public class GameUserVO 
	{
		public var uid:String;
		public var spawnIndex:uint;
		public var name:String;
		public var igc:uint;
		public var xp:uint;
		public var isMainUser:Boolean;
		
		public function GameUserVO(pId:String) 
		{
			uid = pId;
		}
		
	}

}