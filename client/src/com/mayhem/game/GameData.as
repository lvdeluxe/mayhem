package com.mayhem.game 
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author availlant
	 */
	public class GameData 
	{
		
		public static const VEHICLE_GRAVITY:int = -10;
		public static const VEHICLE_MASS:uint = 1;
		public static const VEHICLE_FRICTION:Number = 0.5;
		public static const VEHICLE_RESTITUTION:Number = 0.0;
		public static const VEHICLE_ANG_FACTOR:Number = 0.25;
		public static const VEHICLE_LIN_FACTOR:Number = 0.25;
		public static const VEHICLE_MAX_ENERGY:Number = 150;
		public static const VEHICLE_RESPAWN_TIME:Number = 2000;
		public static const ANG_DAMPING_DEFAULT:Number = 0.9;
		public static const ANG_DAMPING_DECCEL:Number = 0.9;
		public static const LIN_DAMPING_DEFAULT:Number = 0.9;
		public static const LIN_DAMPING_DECCEL:Number = 0.9;
		
		public static const GAME_SESSION_DURATION:Number = 120000;
		
		public static var VEHICLE_LIN_VELOCITY:Number = 2700;
		public static var VEHICLE_ANG_VELOCITY:Number = 60;
		public static var CAMERA_OFFSET_Y:Number = 100;
		public static var CAMERA_OFFSET_Z:Number = 3000;
		public static var CAMERA_ROTATION_X:Number = 0.5//Math.PI / 4;
		
		public static const BUMPER_FORCE:Number = 100;
		public static const EXPLOSION_FORCE:Number = 300;
		
		public static const POWERUP_FULL:Number = 50;
		public static const POWERUP_EXPLOSION:int = 0;
		public static const POWERUP_INVISIBILITY:int = 1;
		public static const INVISIBILITY_DURATION:Number = 10000;
		
		public static var ARENA_FRICTION:Number = 0.5;
		public static var ARENA_RESTITUTION:Number = 0;
		
		public static const XP_FOR_LEVELS:Array = 	[0, 10, 50, 200, 500, 900, 1500, 2800, 4000, 8000, 15000, 40000, 100000];
		//public static const LEVES:Array = 			[1,  2,  3,   4,   5,   6,    7,    8,    9,   10,    11,    12,     13];
		
		
		public function GameData() 
		{
			
		}
		
		public static function getLevelForXP(xp:uint):uint {
			var level:uint = 0;
			for (var i:uint = 0 ; i < XP_FOR_LEVELS.length - 1; i++ ) {
				var before:uint = XP_FOR_LEVELS[i];
				var after:uint = XP_FOR_LEVELS[i + 1];
				if (xp >= before && xp < after)
					return i;
			}
			return level;
		}
		
		public static function getFactorForXP(xp:uint):Number {
			var scale:Number = 0;
			for (var i:uint = 0 ; i < XP_FOR_LEVELS.length - 1; i++ ) {
				var before:uint = XP_FOR_LEVELS[i];
				var after:uint = XP_FOR_LEVELS[i + 1];
				if (xp >= before && xp < after) {
					var divider:Number = after - before;
					return (xp - before) / divider;
				}
			}
			return scale;
		}
		
		public static function getDamageByExplosionImpulse(impulse:Vector3D):void {
			
		}
		
	}

}