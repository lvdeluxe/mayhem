package com.pranks.game 
{
	import away3d.entities.Mesh;
	import away3d.events.Object3DEvent;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	import away3d.primitives.CubeGeometry;
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.dynamics.AWPRigidBody;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author availlant
	 */
	public class MovingCube 
	{
		
		public var body:AWPRigidBody;
		public var mesh:Mesh
		public var userInputs:Dictionary;
		public var material:MaterialBase;
		public var name:String;
		
		public function MovingCube(id:String, coords: Vector3D, rotation: Vector3D,velocity: Vector3D,isMainUser:Boolean) 
		{
			name = id;
			userInputs = new Dictionary();
			userInputs[GameManager.MOVE_DOWN_KEY] = false;
			userInputs[GameManager.MOVE_LEFT_KEY] = false;
			userInputs[GameManager.MOVE_RIGHT_KEY] = false;
			userInputs[GameManager.MOVE_UP_KEY] = false;
			
			var color:Number = isMainUser ? 0xcc0000 : 0x0000cc;
			var cubeBmd:BitmapData = new BitmapData(128, 128, false, color);
			//cubeBmd.perlinNoise(7, 7, 5, 12345, true, true, 7, !isMainUser);
			material = new ColorMaterial(color);
			//cubeMaterial.lightPicker = _lightPicker;

			var cG:CubeGeometry = new CubeGeometry(100, 100, 100);
			mesh = new Mesh(cG, material);
			mesh.x = coords.x;
			mesh.y = coords.y;
			mesh.z = coords.z;	
			
			trace('coords=',coords)
			trace('rotate=',rotation)

			var boxShape : AWPBoxShape = new AWPBoxShape(100, 100, 100);
			body = new AWPRigidBody(boxShape, mesh, 1);
			body.gravity = new Vector3D(0,-1,0);
			body.friction = .9;
			body.ccdSweptSphereRadius = 0.5;
			body.ccdMotionThreshold = 1;
			body.position = coords;
			body.rotation = rotation;
			body.linearVelocity = velocity;
			
		}
		
		public function addUserInput(keyCode:uint):void {
			switch(keyCode) {
				case Keyboard.LEFT:
					userInputs[GameManager.MOVE_LEFT_KEY] = true;
					break;
				case Keyboard.RIGHT:
					userInputs[GameManager.MOVE_RIGHT_KEY] = true;
					break;
				case Keyboard.UP:
					userInputs[GameManager.MOVE_UP_KEY] = true;
					break;
				case Keyboard.DOWN:
					userInputs[GameManager.MOVE_DOWN_KEY] = true;
					break;
			}
		}
		public function removeUserInput(keyCode:uint):void {
			switch(keyCode) {
				case Keyboard.LEFT:
					userInputs[GameManager.MOVE_LEFT_KEY] = false;
					break;
				case Keyboard.RIGHT:
					userInputs[GameManager.MOVE_RIGHT_KEY] = false;
					break;
				case Keyboard.UP:
					userInputs[GameManager.MOVE_UP_KEY] = false;
					break;
				case Keyboard.DOWN:
					userInputs[GameManager.MOVE_DOWN_KEY] = false;
					break;
			}
		}
		
	}

}