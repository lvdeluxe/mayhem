package com.mayhem.game 
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author availlant
	 */
	public class GameData 
	{
		
		public static const VEHICLE_GRAVITY:int = -20;
		public static const VEHICLE_MASS:uint = 1;
		public static const VEHICLE_FRICTION:Number = 0.1;
		public static const VEHICLE_RESTITUTION:Number = 0.1;
		public static const VEHICLE_ANG_FACTOR:Number = 0.25;
		public static const VEHICLE_LIN_FACTOR:Number = 0.25;
		public static const VEHICLE_MAX_ENERGY:Number = 150;
		public static const VEHICLE_RESPAWN_TIME:Number = 2000;
		
		public static const GAME_SESSION_DURATION:Number = 120000;
		
		public static var VEHICLE_LIN_VELOCITY:Number = 750;
		public static var VEHICLE_ANG_VELOCITY:Number = 65;
		public static var CAMERA_OFFSET_Y:Number = 500;
		public static var CAMERA_OFFSET_Z:Number = 3000;
		public static var CAMERA_ROTATION_X:Number = Math.PI / 4;
		
		public static const POWERUP_FULL:Number = 50;
		public static const POWERUP_EXPLOSION:int = 0;
		public static const POWERUP_INVISIBILITY:int = 1;
		public static const INVISIBILITY_DURATION:Number = 10000;
		
		
		
		public function GameData() 
		{
			
		}
		
		public static function getDamageByExplosionImpulse(impulse:Vector3D):void {
			
		}
		
	}

}