package com.mayhem.game 
{
	import away3d.debug.Trident;
	import away3d.entities.Mesh;
	import away3d.entities.Sprite3D;
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
	import away3d.primitives.SphereGeometry;
	import away3d.textures.BitmapCubeTexture;
	import away3d.textures.BitmapTexture;
	import away3d.textures.Texture2DBase;
	import awayphysics.collision.dispatch.AWPCollisionObject;
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.collision.shapes.AWPBvhTriangleMeshShape;
	import awayphysics.collision.shapes.AWPSphereShape;
	import awayphysics.data.AWPCollisionFlags;
	import awayphysics.dynamics.AWPDynamicsWorld;
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.dynamics.vehicle.AWPVehicleTuning;
	import awayphysics.events.AWPEvent;
	import com.mayhem.multiplayer.GameUserVO;
	import com.mayhem.signals.GameSignals;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.SetIntervalTimer;
	import flash.utils.Timer;
	import awayphysics.dynamics.vehicle.AWPRaycastVehicle
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;
	/**
	 * ...
	 * @author availlant
	 */
	public class MovingCube 
	{
		
		public var body:AWPRigidBody;
		public var mesh:Mesh
		public var userInputs:Dictionary;
		public var hasCollided:Boolean = false;
		public var hasFelt:Boolean = false;
		public var linearVelocityBeforeCollision:Vector3D = new Vector3D();
		public var totalEnergy:int = GameData.VEHICLE_MAX_ENERGY;
		public var spawnPosition:Vector3D = new Vector3D();
		public var powerupRefill:uint = 0;
		public var isInvisible:Boolean = false;
		
		private var _collisionTimer:Timer;		
		private var _invisibilityTimer:Timer;
		private var _shieldTimer:Timer;
		
		
		public var isInContactWithGound:Boolean = false;
		
		public var user:GameUserVO;
		
		public var enableBehavior:Boolean = false;
		
		public var targetedBy:MovingCube;
		
		private var _shieldMesh:Mesh;
		
		private var _shieldCollisionBody:AWPCollisionObject;
		
		public var infoPlane:Sprite3D;
		
		public var hasShield:Boolean = false;
		
		
		public function MovingCube(pUser:GameUserVO) 
		{
			user = pUser;			
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
			
			_shieldTimer = new Timer(GameData.SHIELD_DURATION, 1);
			_shieldTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onShieldComplete);

			mesh = ModelsManager.instance.allVehicleMeshes[user.vehicleId].clone() as Mesh;
			mesh.material = getMaterial();
			mesh.material.bothSides = true;
			mesh.material.lightPicker = MaterialsFactory.mainLightPicker;	
			
			

			mesh.extra = this;
			
			var boxShape : AWPBoxShape = new AWPBoxShape(450, 200, 600);
			body = new AWPRigidBody(boxShape, mesh, GameData.VEHICLE_MASS);
			body.addRay(new Vector3D(), new Vector3D(0,-150,0));
			//var trident:Trident = new Trident(500);
			//mesh.addChild(trident)
			body.gravity = new Vector3D(0, GameData.VEHICLE_GRAVITY,0);
			body.friction = GameData.VEHICLE_FRICTION;
			body.restitution = GameData.VEHICLE_RESTITUTION;
			body.ccdSweptSphereRadius = 0.5;
			body.ccdMotionThreshold = 1;
			body.linearDamping = GameData.LIN_DAMPING;
			body.angularDamping = GameData.ANG_DAMPING;
			body.linearFactor = new Vector3D(1,GameData.VEHICLE_LIN_FACTOR,1);
			body.angularFactor = new Vector3D(GameData.VEHICLE_ANG_FACTOR, 1, GameData.VEHICLE_ANG_FACTOR);
			body.addEventListener(AWPEvent.RAY_CAST, testRayCast);
			
			GameSignals.SET_USER_INFO_PLANE.add(setInfoPlane);
			GameSignals.GET_USER_INFO_PLANE.dispatch(user.uid);
			
		}
		
		private function setInfoPlane(userId:String,bitmapData:BitmapData):void 
		{
			if(userId == user.uid){
				var mat:TextureMaterial = new TextureMaterial(new BitmapTexture(bitmapData));
				mat.alphaThreshold = 0.25;
				infoPlane = new Sprite3D(mat, 500, 500);
				infoPlane.y = 200;
				mesh.addChild(infoPlane);
			}
		}
		
		private function testRayCast(event:AWPEvent):void {
			//event.collisionObject.
			isInContactWithGound = true;
		}
		//
		public function getMaterial():TextureMaterial {
			var bmp:BitmapTexture = new BitmapTexture(ModelsManager.instance.getVehicleTextureByIds(user.vehicleId, user.textureId));
			var mat:TextureMaterial = new TextureMaterial(bmp);
			mat.bothSides = true;
			return mat;
		}
		
		private function onInvisibilityComplete(event:TimerEvent):void {
			TextureMaterial(mesh.material).alpha = 1;
			mesh.castsShadows = true;
			isInvisible = false;
		}
		
		private function onShieldCollision(event:AWPEvent):void {
			
			if (!event.collisionObject.skin)
				return;
			var targetVehicle:MovingCube = event.collisionObject.skin.extra as MovingCube
			if (targetVehicle && targetVehicle != this) {
				var force:Vector3D = targetVehicle.body.position.subtract(body.position);
				force.normalize();
				force.y = 0;
				force.scaleBy(200);
				targetVehicle.body.applyCentralImpulse(force);
				//var explosion1:ExplosionData = new ExplosionData();
				//explosion1.impulse = force1;
				//explosion1.target = vehicle1.user.uid;
			}
		}
		
		private function onShieldComplete(event:TimerEvent):void {
			mesh.removeEventListener(Object3DEvent.POSITION_CHANGED, onShieldFrame);
			_shieldCollisionBody.removeEventListener(AWPEvent.COLLISION_ADDED, onShieldCollision);
			AWPDynamicsWorld.getInstance().removeCollisionObject(_shieldCollisionBody);
			mesh.parent.removeChild(_shieldMesh);
			hasShield = false;
			_shieldCollisionBody = null;
			_shieldMesh = null;
		}
		
		public function setShieldState():void {
			hasShield = true;
			if (_shieldMesh != null) {
				_shieldTimer.stop();
				_shieldTimer.reset();
				_shieldTimer.start();
				return;
			}
			ParticlesFactory.instance.getShieldParticles(mesh);
			_shieldMesh = new Mesh(new SphereGeometry(600), new ColorMaterial(0x33ff00, 0.25));
			mesh.parent.addChild(_shieldMesh);	
			var shieldShape:AWPSphereShape = new AWPSphereShape(600);
			_shieldCollisionBody = new AWPCollisionObject(shieldShape,_shieldMesh);
			_shieldCollisionBody.collisionFlags = AWPCollisionFlags.CF_NO_CONTACT_RESPONSE;
			_shieldCollisionBody.addEventListener(AWPEvent.COLLISION_ADDED, onShieldCollision);
			AWPDynamicsWorld.getInstance().addCollisionObject(_shieldCollisionBody);
			mesh.addEventListener(Object3DEvent.POSITION_CHANGED, onShieldFrame);
			_shieldTimer.start();
		}
		
		private function onShieldFrame(e:Object3DEvent):void 
		{
			_shieldCollisionBody.position = body.position;
		}
		
		
		public function setInvisibilityState(alphaValue:Number):void {
			TextureMaterial(mesh.material).alpha = alphaValue;
			isInvisible = true;
			mesh.castsShadows = false;
			_invisibilityTimer.reset();
			_invisibilityTimer.start();
		}
		
		public function setExplosionState():void {
			ParticlesFactory.instance.getExplosionParticles(body.position.clone());
		}
		
		public function setBeamState():void {
			ParticlesFactory.instance.getBeamParticles(mesh);
		}
		
		public function setRandomMayhemState(targetPosition1:Vector3D,targetPosition2:Vector3D,targetPosition3:Vector3D):void {
			ParticlesFactory.instance.getRandomRayParticles(body.position.clone(), targetPosition1);
			ParticlesFactory.instance.getRandomRayParticles(body.position.clone(), targetPosition2);
			ParticlesFactory.instance.getRandomRayParticles(body.position.clone(), targetPosition3);
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
			ParticlesFactory.instance.getSparksParticles(particlesPosition);
			//_collisionTimer.reset();
			//_collisionTimer.start();
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
			if(enableBehavior){
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