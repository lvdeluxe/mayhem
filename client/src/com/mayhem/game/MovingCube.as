package com.mayhem.game 
{
	import away3d.debug.Trident;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.events.Object3DEvent;
	import away3d.library.AssetLibrary;
	import away3d.library.assets.AssetType;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.materials.methods.FresnelEnvMapMethod;
	import away3d.materials.methods.FresnelSpecularMethod;
	import away3d.materials.methods.SoftShadowMapMethod;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.CubeGeometry;
	import away3d.textures.BitmapCubeTexture;
	import away3d.textures.BitmapTexture;
	import away3d.textures.Texture2DBase;
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.collision.shapes.AWPBvhTriangleMeshShape;
	import awayphysics.data.AWPCollisionFlags;
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.dynamics.vehicle.AWPVehicleTuning;
	import awayphysics.events.AWPEvent;
	import flash.events.TimerEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.SetIntervalTimer;
	import flash.utils.Timer;
	import awayphysics.dynamics.vehicle.AWPRaycastVehicle
	/**
	 * ...
	 * @author availlant
	 */
	public class MovingCube 
	{
		
		public var body:AWPRigidBody;
		public var mesh:Mesh
		public var userInputs:Dictionary;
		public var name:String;			
		public var hasCollided:Boolean = false;
		public var hasFelt:Boolean = false;
		public var linearVelocityBeforeCollision:Vector3D = new Vector3D();
		public var totalEnergy:int = GameData.VEHICLE_MAX_ENERGY;
		public var spawnPosition:Vector3D = new Vector3D();
		public var powerupRefill:uint = 0;
		public var isInvisible:Boolean = false;
		
		private var _collisionTimer:Timer;		
		private var _invisibilityTimer:Timer;
		
		private var _cubeMap:BitmapCubeTexture;
		
		public var isInContactWithGound:Boolean = false;
		
		
		public function MovingCube(id:String, isMainUser:Boolean, cubeMap:BitmapCubeTexture) 
		{
			name = id;
			_cubeMap = cubeMap;
			userInputs = new Dictionary();
			userInputs[GameController.MOVE_DOWN_KEY] = false;
			userInputs[GameController.MOVE_LEFT_KEY] = false;
			userInputs[GameController.MOVE_RIGHT_KEY] = false;
			userInputs[GameController.MOVE_UP_KEY] = false;
			
			_collisionTimer = new Timer(200, 10);
			_collisionTimer.addEventListener(TimerEvent.TIMER,onTimer);
			_collisionTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			
			_invisibilityTimer = new Timer(GameData.INVISIBILITY_DURATION, 1);
			_invisibilityTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onInvisibilityComplete);

			mesh = ModelsManager.instance.allVehicleMeshes[0].clone() as Mesh;
			mesh.material = getMaterial();
			mesh.material.lightPicker = MaterialsFactory.mainLightPicker;		

			mesh.extra = this;
			
			var boxShape : AWPBoxShape = new AWPBoxShape(450, 200, 600);
			body = new AWPRigidBody(boxShape, mesh, GameData.VEHICLE_MASS);
			body.addRay(new Vector3D(), new Vector3D(0,-150,0));
			var trident:Trident = new Trident(150);
			mesh.addChild(trident)
			body.gravity = new Vector3D(0, GameData.VEHICLE_GRAVITY,0);
			body.friction = GameData.VEHICLE_FRICTION;
			body.restitution = GameData.VEHICLE_RESTITUTION;
			body.ccdSweptSphereRadius = 0.5;
			body.ccdMotionThreshold = 1;
			body.linearFactor = new Vector3D(1,GameData.VEHICLE_LIN_FACTOR,1);
			body.angularFactor = new Vector3D(GameData.VEHICLE_ANG_FACTOR, 1, GameData.VEHICLE_ANG_FACTOR);
			body.addEventListener(AWPEvent.RAY_CAST, testRayCast);
			
		}
		
		private function testRayCast(event:AWPEvent):void {
			isInContactWithGound = true;
		}
		//
		public function getMaterial():TextureMaterial {
			var bmp:BitmapTexture = new BitmapTexture(ModelsManager.instance.getRandomVehicleTexture());
			var mat:TextureMaterial = new TextureMaterial(bmp);
			return mat;
		}
		
		private function onInvisibilityComplete(event:TimerEvent):void {
			TextureMaterial(mesh.material).alpha = 1;
			mesh.castsShadows = true;
			isInvisible = false;
		}
		
		
		public function setInvisibilityState(alphaValue:Number):void {
			TextureMaterial(mesh.material).alpha = alphaValue;
			isInvisible = true;
			mesh.castsShadows = false;
			_invisibilityTimer.reset();
			_invisibilityTimer.start();
		}
		public function setExplosionState():void {
			ParticlesFactory.instance.getExplosionParticles(body.position.clone(), null);
		}

		private function onTimer(event:TimerEvent):void {
			var visib:Boolean = mesh.visible
			mesh.visible = !visib;
		}
		
		private function onTimerComplete(event:TimerEvent):void {
			hasCollided = false;
			mesh.visible = true;
		}
		
		public function setImpactState(position:Vector3D):void {
			var particlesPosition:Vector3D = mesh.transform.transformVector(position);
			ParticlesFactory.instance.getSparksParticles(particlesPosition, null);
			_collisionTimer.reset();
			_collisionTimer.start();
		}
		
		private function enableCollision():void {
			hasCollided = false;
		}
		
		public function removeAllUserInputs():void {
			userInputs[GameController.MOVE_LEFT_KEY] = false;
			userInputs[GameController.MOVE_RIGHT_KEY] = false;
			userInputs[GameController.MOVE_UP_KEY] = false;
			userInputs[GameController.MOVE_DOWN_KEY] = false;
		}
		
		public function addUserInput(keyCode:uint):void {
			if(isInContactWithGound){
				switch(keyCode) {
					case Keyboard.A:
					case Keyboard.LEFT:
						userInputs[GameController.MOVE_LEFT_KEY] = true;
						break;
					case Keyboard.D:
					case Keyboard.RIGHT:
						userInputs[GameController.MOVE_RIGHT_KEY] = true;
						break;
					case Keyboard.W:
					case Keyboard.UP:
						userInputs[GameController.MOVE_UP_KEY] = true;
						break;
					case Keyboard.S:
					case Keyboard.DOWN:
						userInputs[GameController.MOVE_DOWN_KEY] = true;
						break;
				}
			}
		}
		public function removeUserInput(keyCode:uint):void {
			switch(keyCode) {
				case Keyboard.A:
				case Keyboard.LEFT:
					userInputs[GameController.MOVE_LEFT_KEY] = false;
					break;
				case Keyboard.D:
				case Keyboard.RIGHT:
					userInputs[GameController.MOVE_RIGHT_KEY] = false;
					break;
				case Keyboard.W:
				case Keyboard.UP:
					userInputs[GameController.MOVE_UP_KEY] = false;
					break;
				case Keyboard.S:
				case Keyboard.DOWN:
					userInputs[GameController.MOVE_DOWN_KEY] = false;
					break;
			}
		}
	}
}