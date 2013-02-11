package com.mayhem.ui 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	/**
	 * ...
	 * @author availlant
	 */
	public class TexturesManager 
	{
		
		[Embed(source = "/assets/powerups/powerup1.jpg")]
		public static var PowerUp1:Class;
		[Embed(source = "/assets/powerups/powerup2.jpg")]
		public static var PowerUp2:Class;
		[Embed(source = "/assets/powerups/powerup3.jpg")]
		public static var PowerUp3:Class;
		[Embed(source = "/assets/powerups/powerup4.jpg")]
		public static var PowerUp4:Class;
		[Embed(source = "/assets/powerups/powerup5.jpg")]
		public static var PowerUp5:Class;
		[Embed(source = "/assets/powerups/powerup1_locked.jpg")]
		public static var PowerUp1_Locked:Class;
		[Embed(source = "/assets/powerups/powerup2_locked.jpg")]
		public static var PowerUp2_Locked:Class;
		[Embed(source = "/assets/powerups/powerup3_locked.jpg")]
		public static var PowerUp3_Locked:Class;
		[Embed(source = "/assets/powerups/powerup4_locked.jpg")]
		public static var PowerUp4_Locked:Class;
		[Embed(source = "/assets/powerups/powerup5_locked.jpg")]
		public static var PowerUp5_Locked:Class;
		[Embed(source = "/assets/ui/cross.png")]
		public static var CloseButton:Class;
		[Embed(source = "/assets/ui/powerup_empty_slot.png")]
		public static var EmptySlot:Class;
		[Embed(source = "/assets/ui/powerup_locked_slot.png")]
		public static var LockedSlot:Class;
		
		public function TexturesManager() 
		{
			
		}
		
		public static function getPowerupBitmapDataById(powerup_id:String):BitmapData {
			var bmpData:BitmapData;
			switch(powerup_id) {
				case "powerup_0":
					bmpData = Bitmap(new PowerUp1()).bitmapData;
					break;
				case "powerup_1":
					bmpData = Bitmap(new PowerUp2()).bitmapData;
					break;
				case "powerup_2":
					bmpData = Bitmap(new PowerUp3()).bitmapData;
					break;
				case "powerup_3":
					bmpData = Bitmap(new PowerUp4()).bitmapData;
					break;
				case "powerup_4":
					bmpData = Bitmap(new PowerUp5()).bitmapData;
					break;
			}
			return bmpData;
		}
		
	}

}