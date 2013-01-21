package com.mayhem.game 
{
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapCubeTexture;
	import away3d.textures.BitmapTexture;
	import com.mayhem.multiplayer.GameUserVO;
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * @author availlant
	 */
	public class MovingAICube extends MovingCube
	{
		public var isChaser:Boolean;
		
		public function MovingAICube(user:GameUserVO, pIsChaser:Boolean) 
		{
			super(user);
			isChaser = pIsChaser;
		}
	
		
		override public function getMaterial():TextureMaterial {
			var bmp:BitmapTexture = new BitmapTexture(ModelsManager.instance.getAIVehicleTexture());
			var mat:TextureMaterial = new TextureMaterial(bmp);
			return mat;
		}
		
		
	}

}