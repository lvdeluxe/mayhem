package com.mayhem.game 
{
	import away3d.entities.Mesh;
	import away3d.events.Object3DEvent;
	import away3d.lights.DirectionalLight;
	import away3d.lights.LightBase;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.materials.methods.HardShadowMapMethod;
	import away3d.materials.methods.TripleFilteredShadowMapMethod;
	import away3d.primitives.CubeGeometry;
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.dynamics.AWPRigidBody;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
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
		
		public var speed:Number = 20;
		public var rotationSpeed:Number = 5;
		public var startVelocity:Number = 10;
		
		public var deccelerateRotation:Boolean = false;
		public var deccelerateVelocity:Boolean = false;
		public var startedDeccelerateRotation:Boolean = false;
		public var startedDeccelerateVelocity:Boolean = false;
		public var startDeccelerateVelocityTime:Number;
		public var startDeccelerateRotationTime:Number;
		public var deccelerateVelocityVector3:Vector3D
		public var deccelerateRotationVector3:Vector3D
		private var deccelRotationTime:Number = 500;
		private var deccelVelocityTime:Number = 500;
		public var doInterpolatePosition:Boolean = false;
		public var doInterpolateRotation:Boolean = false;		
		public var startedInterpolatePosition:Boolean = false;
		public var startedInterpolateRotation:Boolean = false;
		public var interpolatePositionTo:Vector3D;
		public var interpolateRotationTo:Vector3D;
		
		private var interpolatePositionTime:Number = 400;
		private var interpolatePositionStartTime:Number = 400;
		private var startInterpolateAt:Vector3D;
		
		public function MovingCube(id:String, coords: Vector3D, rotation: Vector3D,velocity: Vector3D,isMainUser:Boolean, light:LightBase) 
		{
			name = id;
			userInputs = new Dictionary();
			userInputs[GameManager.MOVE_DOWN_KEY] = false;
			userInputs[GameManager.MOVE_LEFT_KEY] = false;
			userInputs[GameManager.MOVE_RIGHT_KEY] = false;
			userInputs[GameManager.MOVE_UP_KEY] = false;
			
			var color:Number = isMainUser ? 0xcc0000 : 0x0000cc;
			var cubeBmd:BitmapData = new BitmapData(128, 128, false, color);
			material = new ColorMaterial(color);
			//ColorMaterial(material).shadowMethod = new TripleFilteredShadowMapMethod(DirectionalLight(light));

			var cG:CubeGeometry = new CubeGeometry(100, 100, 100);
			mesh = new Mesh(cG, material);
			mesh.x = coords.x;
			mesh.y = coords.y;
			mesh.z = coords.z;	
			
			mesh.extra = this;
			
			trace('coords=',coords)
			trace('rotate=',rotation)

			var boxShape : AWPBoxShape = new AWPBoxShape(100, 100, 100);
			body = new AWPRigidBody(boxShape, mesh, 1);
			body.gravity = new Vector3D(0,-1,0);
			body.friction = .1;
			body.restitution = 0.1
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
		
		
		private function doDecceleration(started:String, startTime:String, startVector:String, value:String,deccelType:String, totalTime:String):void {
			if (!this[started]) {
				this[started] = true;
				this[startTime] = getTimer();
				this[startVector] = this.body[value];
			}
			var factor:Number = quadOut(getTimer() - this[startTime], 0, 1, this[totalTime]);
			var tmpX:Number = this[startVector].x + (0 - this[startVector].x) * factor;
			var tmpY:Number = this[startVector].y + (0 - this[startVector].y) * factor;
			var tmpZ:Number = this[startVector].z + (0 - this[startVector].z) * factor;
			
			this.body[value] = (new Vector3D(tmpX, tmpY, tmpZ))
			
			if (factor >= 1 || this.body[value].equals(new Vector3D())) {
				this[deccelType] = false;
				this.body[value] = new Vector3D();
			}
		}
		
		private function linearEase(t:Number, b:Number, c:Number, d:Number):Number {
			//t  = current time
			//b = beggining value
			//c = end value
			//d = total time
			return c*t/d + b;
		};
		
		public function checkInterpolate():void {
			if (doInterpolatePosition) {
				if (interpolatePositionTo == null)
						return;
				if (!startedInterpolatePosition) {
					startedInterpolatePosition = true;
					interpolatePositionStartTime = getTimer();
					startInterpolateAt = body.position;
					
				}
				var factor:Number = linearEase(getTimer() - interpolatePositionStartTime, 0, 1, 450);
				var tmpX:Number = startInterpolateAt.x + ((interpolatePositionTo.x - startInterpolateAt.x )* factor);
				var tmpY:Number = startInterpolateAt.y + ((interpolatePositionTo.y - startInterpolateAt.y )* factor);
				var tmpZ:Number = startInterpolateAt.z + ((interpolatePositionTo.z - startInterpolateAt.z )* factor);
				trace(factor)
				trace(startInterpolateAt)
				trace(new Vector3D(tmpX, tmpY, tmpZ))
				trace(interpolatePositionTo)
				body.position = (new Vector3D(tmpX, tmpY, tmpZ))
			
				if (factor >= 1 || body.position.equals(interpolatePositionTo)) {
					doInterpolatePosition = false;
					startedInterpolatePosition = false;
					
					trace("////////////////////")
					body.position = interpolatePositionTo;
				}
			}
		}
		
		public function checkDeccelerate():void {
			
			
			if (deccelerateRotation) {
				//doInterpolateRotation = true
					
				doDecceleration("startedDeccelerateRotation", "startDeccelerateRotationTime","deccelerateRotationVector3","angularVelocity", "deccelerateRotation", "deccelRotationTime");
			}
			if (deccelerateVelocity) {
				//doInterpolatePosition = true;
				if (!startedDeccelerateVelocity){
					deccelVelocityTime = Math.round(Math.abs(body.linearVelocity.z) * 500);					
				}
				doDecceleration("startedDeccelerateVelocity", "startDeccelerateVelocityTime", "deccelerateVelocityVector3", "linearVelocity", "deccelerateVelocity", "deccelVelocityTime");
			}
		}
		private function quadOut(currTime:Number, start:Number, end:Number, totalTime:Number):Number {
			//t  = current time
			//b = beggining value
			//c = end value
			//d = total time
			return 1 - Math.pow(1 - (currTime / totalTime), 5);
		}
		
	}

}