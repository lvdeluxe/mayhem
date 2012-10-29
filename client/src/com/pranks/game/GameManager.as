package com.pranks.game 
{
	import away3d.containers.View3D;
	import away3d.controllers.FollowController;
	import away3d.controllers.HoverController;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.AwayStats
	import away3d.entities.Mesh;
	import away3d.events.Object3DEvent;
	import away3d.lights.DirectionalLight;
	import away3d.lights.LightBase;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.materials.methods.HardShadowMapMethod;
	import away3d.materials.methods.SoftShadowMapMethod;
	import away3d.materials.methods.TripleFilteredShadowMapMethod;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.WireframePlane;
	import away3d.textures.BitmapTexture;
	import awayphysics.collision.dispatch.AWPGhostObject;
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.collision.shapes.AWPStaticPlaneShape;
	import awayphysics.dynamics.AWPDynamicsWorld;
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.dynamics.character.AWPKinematicCharacterController;
	import caurina.transitions.Equations;
	import caurina.transitions.Tweener;
	import flare.primitives.Cube;
	import flash.display.Stage;
	import flash.display.BitmapData
	import away3d.materials.TextureMaterial;
	import com.pranks.signals.MultiplayerSignals;
	import flash.events.TimerEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.events.Event;
	import com.pranks.signals.UserInputSignals;
	import flash.utils.setInterval;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author availlant
	 */
	public class GameManager 
	{
		
		private var _view3D:View3D;
		private var _allPlayers:Dictionary;
		
		private var _ownerCube:MovingCube;	
		
		private var _light:LightBase;
		private var _lightPicker:StaticLightPicker;
		private var _physicsWorld:AWPDynamicsWorld;
		private var _timeStep : Number = 1.0 / 60;
		
		private var _playerInputs:Dictionary;
		
		public static var MOVE_LEFT_KEY:uint = 0;
		public static var MOVE_RIGHT_KEY:uint = 1;
		public static var MOVE_UP_KEY:uint = 2;
		public static var MOVE_DOWN_KEY:uint = 3;
		
		private var downPressed:Boolean = false;
		private var upPressed:Boolean = false;
		private var rightPressed:Boolean = false;
		private var leftPressed:Boolean = false;
		
		private var _sendMoveMessage:Boolean = true;
		
		private var _updateTimer:Timer;
		
		private var _incFrame:uint = 0;
		
		private var _gameTimer:Timer;
		private var _currentElapsed:Number;
		
		private var _camController:FollowController;
		
		private var deccelY:Number = 0;
		
		private var _direction:Vector3D = new Vector3D();
		
		public function GameManager(stage:Stage, proxy:Stage3DProxy) 
		{
			_allPlayers = new Dictionary();
			
			_currentElapsed = getTimer();			
			
			_updateTimer = new Timer(500);
			_updateTimer.addEventListener(TimerEvent.TIMER, updatePosition);
						
			_view3D = new View3D();
			stage.addChild(_view3D);
			_view3D.stage3DProxy = proxy;
			_view3D.shareContext = true;

			_view3D.camera.y = 1200
			_view3D.camera.z = -1750;
			_view3D.camera.rotationX = 45;
			_view3D.camera.lens.far = 10000;
			
			_light = new DirectionalLight(-1, -1, 1);
			_light.color = 0xffffff;
			_light.y = 100;
			_light.z = 5000;
			_view3D.scene.addChild(_light);
			
			_lightPicker = new StaticLightPicker([_light]);
			
			_physicsWorld = AWPDynamicsWorld.getInstance();
			_physicsWorld.initWithDbvtBroadphase();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
 
			stage.addChild(new AwayStats(_view3D));
			
			MultiplayerSignals.USER_CREATED.add(onUserCreated);
			MultiplayerSignals.USER_REMOVED.add(onUserRemoved);
			UserInputSignals.USER_HAS_MOVED.add(onUserMoved);
			UserInputSignals.USER_HAS_STOPPED_MOVING.add(onUserStoppedMoving);
			UserInputSignals.USER_HAS_UPDATE_STATE.add(onUserUpdateState);
			
			createArena();			
		}
		
		private function createArena():void {
			
			var material : ColorMaterial = new ColorMaterial(0x00cc00);
			material.lightPicker = _lightPicker;
			//material.shadowMethod = new TripleFilteredShadowMapMethod(DirectionalLight(_light));
			
			var groundMesh:Mesh = new Mesh(new CubeGeometry(2500, 50, 2500), material);			
			var groundShape : AWPBoxShape = new AWPBoxShape(2500, 50, 2500);
			var groundRigidbody : AWPRigidBody = new AWPRigidBody(groundShape,groundMesh, 0);
			groundRigidbody.y = -25;
			_physicsWorld.addRigidBody(groundRigidbody);
			_view3D.scene.addChild(groundMesh);
			
			//var leftMesh:Mesh = new Mesh(new CubeGeometry(50, 200, 2500), material);			
			//var leftShape : AWPBoxShape = new AWPBoxShape(50, 200, 2500);
			//var leftRigidbody : AWPRigidBody = new AWPRigidBody(leftShape,leftMesh, 0);
			//leftRigidbody.x = -1275;
			//leftRigidbody.y = -25;
			//_physicsWorld.addRigidBody(leftRigidbody);
			//_view3D.scene.addChild(leftMesh);
			//
			//var rightMesh:Mesh = new Mesh(new CubeGeometry(50, 200, 2500), material);			
			//var rightShape : AWPBoxShape = new AWPBoxShape(50, 200, 2500);
			//var rightRigidbody : AWPRigidBody = new AWPRigidBody(rightShape,rightMesh, 0);
			//rightRigidbody.x = 1275;
			//rightRigidbody.y = -25;
			//_physicsWorld.addRigidBody(rightRigidbody);
			//_view3D.scene.addChild(rightMesh);
			//
			//
			//var upMesh:Mesh = new Mesh(new CubeGeometry(2500, 200, 50), material);			
			//var upShape : AWPBoxShape = new AWPBoxShape(2500, 200, 50);
			//var upRigidbody : AWPRigidBody = new AWPRigidBody(upShape,upMesh, 0);
			//upRigidbody.z = 1275;
			//rightRigidbody.y = -25;
			//_physicsWorld.addRigidBody(upRigidbody);
			//_view3D.scene.addChild(upMesh);
		}
		
		private function onUserUpdateState(uid:String, position:Vector3D, rotation:Vector3D, velocity:Vector3D):void {
			var cube:MovingCube = _allPlayers[uid]			
			if (cube != _ownerCube) {
				//cube.interpolateRotationTo = rotation;
				//var substractRotation:Vector3D = rotation.subtract(cube.body.rotation)
				//trace("substractRotation",substractRotation)
				//if (substractRotation.y > 5 || substractRotation.y < -5)
					//cube.doInterpolateRotation = true;
				//else
				//cube.interpolateRotationTo = rotation;
				cube.body.rotation = rotation;
				//var substractPosition:Vector3D = position.subtract(cube.body.position)
				//trace("substractPosition",substractPosition)
				//if (substractPosition.x > 5 || substractPosition.z > 5 || substractPosition.x < -5 || substractPosition.z < -5){
					//cube.interpolatePositionTo = position;
					//cube.doInterpolatePosition = true;
					//
				//}else
				//cube.doInterpolatePosition = true;
				cube.body.position = position;
				cube.body.linearVelocity = velocity;
			}
		}
		
		private function updatePosition(event:TimerEvent):void {
			if (_ownerCube.body.linearVelocity.equals(new Vector3D(0, 0, 0))) {
				_updateTimer.stop();
				return;
			}
			trace("send",_ownerCube.name, _ownerCube.body.linearVelocity)
			//if(!_ownerCube.deccelerateRotation && !_ownerCube.deccelerateVelocity)
			UserInputSignals.USER_UPDATE_STATE.dispatch(_ownerCube.body.position,_ownerCube.body.rotation,_ownerCube.body.linearVelocity);
		}
		
		
		private function moveObjects():void {
			var t:int = getTimer();
			var dt:Number = (t - _currentElapsed);
			_currentElapsed = t;
			//apply 500 force per second.
			var val:Number = (dt * 500) / 1000
			var moveX:Number = 0;
			var moveZ:Number = 0;			
				
			for each(var cube:MovingCube in _allPlayers) {
				moveX = 0;
				moveZ = 0;
				cube.checkDeccelerate();
				cube.checkInterpolate();
				var  prev:Vector3D = cube.body.position
				if (cube.userInputs[MOVE_LEFT_KEY])
					moveX = -cube.rotationSpeed;
				else if (cube.userInputs[MOVE_RIGHT_KEY])
					moveX = cube.rotationSpeed;
				if (cube.userInputs[MOVE_UP_KEY])
					moveZ = val;
				else if (cube.userInputs[MOVE_DOWN_KEY])
					moveZ = -val;				
				
				if (moveX != 0) {
					cube.body.angularVelocity = new Vector3D(0, moveX, 0);					
				}
				
				if (moveZ != 0) {
					var f:Vector3D = cube.body.front;
					f.scaleBy(moveZ);
					cube.body.applyCentralForce(f);
				}				
			}				
		}		
		
		
		public function renderPhysics():void {
			moveObjects();
			_physicsWorld.step(_timeStep, 1, _timeStep);
		}
		
		private function onKeyUp(event:KeyboardEvent):void {
			switch(event.keyCode) {
				case Keyboard.LEFT:
					leftPressed = false;
					break;
				case Keyboard.RIGHT:
					rightPressed = false;
					break;
				case Keyboard.UP:
					upPressed = false;
					break;
				case Keyboard.DOWN:
					downPressed = false;
					break;
			}
			
			UserInputSignals.USER_STOPPED_MOVING.dispatch(event.keyCode);
		}
		private function onKeyDown(event:KeyboardEvent):void {
			_sendMoveMessage = false;
			switch(event.keyCode) {
				case Keyboard.LEFT:
					if (leftPressed == false)
						_sendMoveMessage = true;
					leftPressed = true;
					break;
				case Keyboard.RIGHT:
					if (rightPressed == false)
						_sendMoveMessage = true;
					rightPressed = true;
					break;
				case Keyboard.UP:
					if (upPressed == false)
						_sendMoveMessage = true;
					upPressed = true;
					break;
				case Keyboard.DOWN:
					if (downPressed == false)
						_sendMoveMessage = true;
					downPressed = true;
					break;
			}
			if (_sendMoveMessage) {
				trace("sendingMessage")
				UserInputSignals.USER_IS_MOVING.dispatch(event.keyCode,new Date().getTime());
			}
		}
		
		private function onUserStoppedMoving(userId:String, keyCode:uint):void {
			var cube:MovingCube = _allPlayers[userId];
			trace(keyCode)
			switch(keyCode) {
				case Keyboard.LEFT:
				case Keyboard.RIGHT:
					cube.deccelerateRotation = true;
					break;
				case Keyboard.UP:
				case Keyboard.DOWN:
					trace(cube.name)
					cube.deccelerateVelocity = true;
					break;
			}
			cube.removeUserInput(keyCode);
		}
		
		private function onUserMoved(userId:String, keyCode:uint, timestamp:Number):void {
			var elapsed:Number = new Date().getTime() - timestamp
			_incFrame = 0;
			var cube:MovingCube = _allPlayers[userId];
			
			var moveZ:Number = 0;
			if (keyCode == Keyboard.LEFT ||keyCode == Keyboard.RIGHT ){
				cube.deccelerateRotation = false;
				cube.startedDeccelerateRotation = false
			}			
			if (keyCode == Keyboard.UP){
				cube.deccelerateVelocity = false;
				cube.startedDeccelerateVelocity = false
				cube.startVelocity = 10
			}else if (keyCode == Keyboard.DOWN){
				cube.deccelerateVelocity = false;
				cube.startedDeccelerateVelocity = false
				cube.startVelocity = -10;
			}
			if(moveZ != 0){
				var f:Vector3D = cube.body.front;
				f.scaleBy(moveZ);	
				cube.body.linearVelocity = f
			}
			cube.addUserInput(keyCode);			
		}
		
		private function onUserRemoved(userId:String):void {
			_view3D.scene.removeChild(_allPlayers[userId].mesh);
			_physicsWorld.removeRigidBody(_allPlayers[userId].body);
			delete _allPlayers[userId];
		}
		private function onUserCreated(dataObject:Object):void {
			var movingCube:MovingCube = new MovingCube(dataObject.uid,dataObject.coords, dataObject.rotation,dataObject.velocity,dataObject.isMainUser, _light);
			_allPlayers[dataObject.uid] = movingCube;			
			_view3D.scene.addChild(movingCube.mesh);
			_physicsWorld.addRigidBody(movingCube.body);
			movingCube.material.lightPicker = _lightPicker;
			trace("created",movingCube.name)
			if (dataObject.isMainUser){
				_ownerCube = movingCube;
				_ownerCube.mesh.addEventListener(Object3DEvent.POSITION_CHANGED, onCubeChanged);	
			}
		}
		
		
		private function onCubeChanged(event:Object3DEvent):void {
			var movingCube:MovingCube = event.currentTarget.extra as MovingCube;
			
			if (!_updateTimer.running)
				_updateTimer.start();
		}
	
		
		public function get renderer():View3D {
			return _view3D;
		}
		
		
		
	}

}