package com.mayhem.game 
{
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapTexture;
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * @author availlant
	 */
	public class MovingAICube extends MovingCube
	{
		
		public function MovingAICube(id:String, isMainUser:Boolean) 
		{
			super(id, isMainUser);
		}
	
		
		override public function getMaterial():TextureMaterial {
			var bmp:BitmapTexture = new BitmapTexture(ModelsManager.instance.getAIVehicleTexture());
			var mat:TextureMaterial = new TextureMaterial(bmp);
			return mat;
		}
		
		
	}

}