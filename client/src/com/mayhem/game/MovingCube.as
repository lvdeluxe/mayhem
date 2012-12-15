package com.mayhem.game 
{
	import away3d.debug.Trident;
	import away3d.entities.Mesh;
	import away3d.events.Object3DEvent;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	import away3d.primitives.CubeGeometry;
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.data.AWPCollisionFlags;
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.dynamics.vehicle.AWPVehicleTuning;
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
		
		public var speed:Number = 20;
		public var rotationSpeed:Number = 5;
		
		public var currentVelocity:Vector3D = new Vector3D();
		public var velocityBeforeCollision:Vector3D = new Vector3D();
		public var hasCollided:Boolean = false;
		public var hasFelt:Boolean = false;
		
		public var linearVelocityBeforeCollision:Vector3D = new Vector3D();
		
		private var _collisionTimer:Timer;
		
		public static const MAX_ENERGY:int = 100;
		public var totalEnergy:int = MAX_ENERGY;
		
		public var isTouchingGround:Boolean = true;
		public var floorCollidingFrames:Vector.<uint> = new Vector.<uint>();
		
		public var car:AWPRaycastVehicle;
		
		public var steering:Number = 0;
		
		
		public function MovingCube(id:String, coords: Vector3D, rotation: Vector3D,velocity: Vector3D,isMainUser:Boolean) 
		{
			name = id;
			userInputs = new Dictionary();
			userInputs[GameManager.MOVE_DOWN_KEY] = false;
			userInputs[GameManager.MOVE_LEFT_KEY] = false;
			userInputs[GameManager.MOVE_RIGHT_KEY] = false;
			userInputs[GameManager.MOVE_UP_KEY] = false;
			
			_collisionTimer = new Timer(200, 10);
			_collisionTimer.addEventListener(TimerEvent.TIMER,onTimer);
			_collisionTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onTimerComplete);
			
			//var matId:String = isMainUser ? MaterialsFactory.OWNER_CUBE_MATERIAL : MaterialsFactory.OTHER_CUBE_MATERIAL;
			//var mat:MaterialBase = MaterialsFactory.getMaterialById(matId);
			
			var cG:CubeGeometry = new CubeGeometry(100, 100, 100);
			mesh = new Mesh(cG, getMaterial(isMainUser));
			mesh.x = coords.x;
			mesh.y = coords.y;
			mesh.z = coords.z;	
			
			mesh.addChild(new Trident(100))
			
			mesh.extra = this;
			
			//var boxShape : AWPBoxShape = new AWPBoxShape(100, 100, 100);
			//body = new AWPRigidBody(boxShape, mesh, 1);
			//var trident:Trident = new Trident(150);
			//mesh.addChild(trident)
			//body.gravity = new Vector3D(0,-1,0);
			//body.friction = .1;
			//body.restitution = 0.1
			//body.ccdSweptSphereRadius = 0.5;
			//body.ccdMotionThreshold = 1;
			//body.angularFactor= new Vector3D(0.25,1,0.25);
			//body.position = coords;
			//body.rotation = rotation;
			//body.linearVelocity = velocity;
			
			createCar(coords);
		}
		
		private function createCar(coords:Vector3D):void {
			var carShape : AWPBoxShape = new AWPBoxShape(100, 100, 100);
			//var boxShape : AWPBoxShape = new AWPBoxShape(100, 100, 100);
			body = new AWPRigidBody(carShape, mesh, 1200);
			//carBody.activationState = AWPCollisionObject.DISABLE_DEACTIVATION;
			body.linearDamping = 0.1;
			body.angularDamping = 0.1;
			body.position = new Vector3D(0, 1500, 0);
			
			body.position = coords;
			//physicsWorld.addRigidBody(carBody);

			// create vehicle
			var turning : AWPVehicleTuning = new AWPVehicleTuning();
			turning.frictionSlip = 2;
			turning.suspensionStiffness = 100;
			turning.suspensionDamping = 0.85;
			turning.suspensionCompression = 0.83;
			turning.maxSuspensionTravelCm = 20;
			turning.maxSuspensionForce = 8000;
			car = new AWPRaycastVehicle(turning, body);
			//physicsWorld.addVehicle(car);

			// add four wheels
			car.addWheel(null, new Vector3D(-110, 80, 170), new Vector3D(0, -1, 0), new Vector3D(-1, 0, 0), 50, 100, turning, true);
			car.addWheel(null, new Vector3D(110, 80, 170), new Vector3D(0, -1, 0), new Vector3D(-1, 0, 0), 50, 100, turning, true);
			car.addWheel(null, new Vector3D(-110, 90, -210), new Vector3D(0, -1, 0), new Vector3D(-1, 0, 0), 50, 100, turning, false);
			car.addWheel(null, new Vector3D(110, 90, -210), new Vector3D(0, -1, 0), new Vector3D(-1, 0, 0), 50, 100, turning, false);
		}
		
		
		public function getMaterial(bool:Boolean):MaterialBase {
			var matId:String = bool ? MaterialsFactory.OWNER_CUBE_MATERIAL : MaterialsFactory.OTHER_CUBE_MATERIAL;
			var mat:MaterialBase = MaterialsFactory.getMaterialById(matId);
			return mat;
		}
		
		private function onTimer(event:TimerEvent):void {
			var visib:Boolean = mesh.visible
			mesh.visible = !visib;
		}
		
		private function onTimerComplete(event:TimerEvent):void {
			trace('back to normal')
			hasCollided = false;
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
		
		
		
		
		//private function linearEase(t:Number, b:Number, c:Number, d:Number):Number {
			//t  = current time
			//b = beggining value
			//c = end value
			//d = total time
			//return c*t/d + b;
		//};
		//
		//public function checkInterpolate():void {
			//if (doInterpolatePosition) {
				//if (interpolatePositionTo == null)
						//return;
				//if (!startedInterpolatePosition) {
					//startedInterpolatePosition = true;
					//interpolatePositionStartTime = getTimer();
					//startInterpolateAt = body.position;
					//
				//}
				//var factor:Number = linearEase(getTimer() - interpolatePositionStartTime, 0, 1, 450);
				//var tmpX:Number = startInterpolateAt.x + ((interpolatePositionTo.x - startInterpolateAt.x )* factor);
				//var tmpY:Number = startInterpolateAt.y + ((interpolatePositionTo.y - startInterpolateAt.y )* factor);
				//var tmpZ:Number = startInterpolateAt.z + ((interpolatePositionTo.z - startInterpolateAt.z )* factor);
				//trace(factor)
				//trace(startInterpolateAt)
				//trace(new Vector3D(tmpX, tmpY, tmpZ))
				//trace(interpolatePositionTo)
				//body.position = (new Vector3D(tmpX, tmpY, tmpZ))
			//
				//if (factor >= 1 || body.position.equals(interpolatePositionTo)) {
					//doInterpolatePosition = false;
					//startedInterpolatePosition = false;
					//
					//trace("////////////////////")
					//body.position = interpolatePositionTo;
				//}
			//}
		//}
		//
		//
		//private function quadOut(currTime:Number, start:Number, end:Number, totalTime:Number):Number {
			//t  = current time
			//b = beggining value
			//c = end value
			//d = total time
			//return 1 - Math.pow(1 - (currTime / totalTime), 5);
		//}
		
	}

}