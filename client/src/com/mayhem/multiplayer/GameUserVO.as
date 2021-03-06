package com.mayhem.multiplayer 
{
	import com.mayhem.game.GameStats;
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
		public var vehicleId:uint;
		public var textureId:uint;
		public var isAIMaster:Boolean;
		public var powerupSlots:uint = 0;
		public var powerups:Vector.<String> = new Vector.<String>();
		public var selectedPowerups:Array;
		public var hasMusic:Boolean;
		public var stats:GameStats;
		
		public function GameUserVO(pId:String) 
		{
			uid = pId;
		}
		
	}

}