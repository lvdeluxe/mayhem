package com.mayhem.game 
{
	//import away3d.materials.MaterialBase;
	import flare.materials.Shader3D;
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * @author availlant
	 */
	public class MovingAICube extends MovingCube
	{
		
		public function MovingAICube(id:String, coords: Vector3D, rotation: Vector3D,velocity: Vector3D,isMainUser:Boolean) 
		{
			super(id, coords, rotation, velocity, isMainUser);
			//setAIBehavior();
		}
		
		public function setAIBehavior():void {
			
		}
		
		override public function getMaterial(bool:Boolean):Shader3D {
			var mat:Shader3D = MaterialsFactory.getMaterialById(MaterialsFactory.AI_CUBE_MATERIAL);
			return mat;
		}
		
		
	}

}