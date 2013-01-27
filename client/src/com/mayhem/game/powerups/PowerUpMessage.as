package com.mayhem.game.powerups 
{
	/**
	 * ...
	 * @author availlant
	 */
	public class PowerUpMessage 
	{
		
		public static const POWERUP_EXPLOSION:int = 0;
		public static const POWERUP_INVISIBILITY:int = 1;
		public static const POWERUP_RANDOM_MAYHEM:int = 2;
		public static const POWERUP_SHIELD:int = 3;
		public static const POWERUP_BEAM:int = 4;
		
		public var triggerdBy:String;
		public var powerUpId:int;
		public var targets:Vector.<ExplosionData> = new Vector.<ExplosionData>();
		
		public function PowerUpMessage() 
		{
			
		}
		
	}

}