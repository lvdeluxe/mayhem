package com.mayhem.game 
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
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.WireframePlane;
	import away3d.textures.BitmapTexture;
	import awayphysics.collision.dispatch.AWPGhostObject;
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.collision.shapes.AWPStaticPlaneShape;
	import awayphysics.data.AWPCollisionFlags;
	import awayphysics.debug.AWPDebugDraw;
	import awayphysics.dynamics.AWPDynamicsWorld;
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.dynamics.character.AWPKinematicCharacterController;
	import awayphysics.events.AWPEvent;
	import flash.display.Stage;
	import flash.display.BitmapData
	import away3d.materials.TextureMaterial;
	import com.mayhem.signals.MultiplayerSignals;
	import flash.events.TimerEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.events.Event;
	import com.mayhem.signals.UserInputSignals;
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
		
		private var _gameTimer:Timer;
		private var _currentTime:Number;
		
		private var _camController:FollowController;
		
		private var deccelY:Number = 0;
		
		private var _direction:Vector3D = new Vector3D();
		
		private const collisionNone : int = 0;
		private const collisionGround : int = 1;
		private const collisionBox : int = 2;
		
		private var _debugDraw:AWPDebugDraw;
		
		private var _debugTextField:TextField
		
		//private startMovingAt:Number
		//private stopMovingAt:Number;
		
		public function GameManager(stage:Stage, proxy:Stage3DProxy) 
		{
			_allPlayers = new Dictionary();
			
			_debugTextField = new TextField();
			
			
			_debugTextField.width = 800;
			_debugTextField.height = 600;
			stage.addChild(_debugTextField);
			_debugTextField.text = 'yo';
			_debugTextField.textColor = 0xcc0000;
			
			_currentTime = getTimer();			
			
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
			_physicsWorld.collisionCallbackOn = true;
			
			_debugDraw = new AWPDebugDraw(_view3D, _physicsWorld);
			
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
			
			var groundMesh:Mesh = new Mesh(new CubeGeometry(2500, 50, 2500), material);			
			var groundShape : AWPBoxShape = new AWPBoxShape(2500, 50, 2500);
			var groundRigidbody : AWPRigidBody = new AWPRigidBody(groundShape,groundMesh, 0);
			groundRigidbody.y = -25;
			_physicsWorld.addRigidBody(groundRigidbody);
			//_physicsWorld.addRigidBodyWithGroup(groundRigidbody, collisionGround, collisionBox);
			_view3D.scene.addChild(groundMesh);
		}
		
		private function onUserUpdateState(uid:String, position:Vector3D, rotation:Vector3D, velocity:Vector3D):void {
			var cube:MovingCube = _allPlayers[uid]			
			if (cube != _ownerCube) {
				//cube.body.clearForces();
				//cube.mesh. = rotation;
				cube.mesh.position = position;
				//cube.body.linearVelocity = velocity;
			}
		}
		
		private function updatePosition(event:TimerEvent):void {
			//if (_ownerCube.body.linearVelocity.equals(new Vector3D(0, 0, 0))) {
				//_updateTimer.stop();
				//return;
			//}
			//UserInputSignals.USER_UPDATE_STATE.dispatch(_ownerCube.body.position,_ownerCube.body.rotation,_ownerCube.body.linearVelocity);
			//UserInputSignals.USER_UPDATE_STATE.dispatch(_ownerCube.mesh.position,new Vector3D(),new Vector3D());
		}
		
		
		private function moveObjects(elapsed:Number):void {
			
			//apply 500 force per second.
			var force:Number = (elapsed * 500) / 1000
			//apply 50 torque per second
			var torque:Number = (elapsed * 50) / 1000
			
			var moveX:Number = 0;
			var moveZ:Number = 0;			
				
			for each(var cube:MovingCube in _allPlayers) {
				moveX = 0;
				moveZ = 0;
				//cube.body.clearForces(); 
				if (cube.userInputs[MOVE_LEFT_KEY])
					moveX = -torque;
				else if (cube.userInputs[MOVE_RIGHT_KEY])
					moveX = torque;
				if (cube.userInputs[MOVE_UP_KEY])
					moveZ = force;
				else if (cube.userInputs[MOVE_DOWN_KEY])
					moveZ = -force;				
				
				if (moveX != 0) {
					//cube.body.applyTorque(new Vector3D(0, moveX, 0));					
				}
				
				if (moveZ != 0) {
					//var f:Vector3D = cube.body.front;
					//f.scaleBy(moveZ);
					//trace(moveZ)
					//trace(cube.mesh.position)
					var pos:Vector3D = cube.mesh.position
					pos.z += moveZ
					cube.mesh.position = pos
					//cube.body.applyCentralForce(f);
					//displayDebugInfo(cube.body.linearVelocity);
				}				
			}				
		}		
		
		
		public function renderPhysics():void {
			var t:int = getTimer();
			var dt:Number = (t - _currentTime);
			_currentTime = t;
			moveObjects(dt);
			//_physicsWorld.step(dt / 1000, 1, _timeStep);
			//_debugDraw.debugDrawWorld();
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
			//if (!_updateTimer.running)
				//_updateTimer.start();
			//UserInputSignals.USER_UPDATE_STATE.dispatch(_ownerCube.body.position,_ownerCube.body.rotation,_ownerCube.body.linearVelocity);
			UserInputSignals.USER_STOPPED_MOVING.dispatch(event.keyCode,new Date().getTime());
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
				//trace("sendingMessage")
				UserInputSignals.USER_IS_MOVING.dispatch(event.keyCode,new Date().getTime());
			}
		}
		
		private function onUserStoppedMoving(userId:String, keyCode:uint, timestamp:Number):void {
			
			//var elapsed:Number = new Date().getTime() - timestamp
			
			var cube:MovingCube = _allPlayers[userId];
			cube.stopMovingAt = timestamp
			var elapsed:Number = cube.stopMovingAt - cube.startMovingAt
			displayDebugInfo(cube.stopMovingAt - cube.startMovingAt);
			var force:Number = (elapsed * 500) / 1000
			var moveZ:Number = 0;
			switch(keyCode) {
				case Keyboard.LEFT:
				case Keyboard.RIGHT:
					//cube.body.angularDamping = 0.98;
					break;
				case Keyboard.UP:
					moveZ = force;
					//cube.body.linearDamping = 0.98;
					break;
				case Keyboard.DOWN:
					moveZ = -force;
					//cube.body.linearDamping = 0.98;
					break;
			}
			var f:Vector3D = cube.startPosition
			f.z += moveZ
			cube.mesh.position = f;
			displayDebugInfo(("end " + cube.mesh.position.toString()))
			//_updateTimer.stop();
			cube.removeUserInput(keyCode);
		}
		
		private function displayDebugInfo(data:*):void {
			_debugTextField.text = data.toString();			
			var myFormat:TextFormat = new TextFormat();
			myFormat.align = TextFormatAlign.RIGHT;
			myFormat.size = 12;
			myFormat.bold = true;
			myFormat.font = "Verdana";
			_debugTextField.setTextFormat(myFormat);
		}
		
		private function onUserMoved(userId:String, keyCode:uint, timestamp:Number):void {
			
			var elapsed:Number = new Date().getTime() - timestamp
			//displayDebugInfo(elapsed);
			var cube:MovingCube = _allPlayers[userId];
			cube.startPosition = cube.mesh.position;
			cube.startMovingAt = timestamp
			
			var force:Number = (elapsed * 500) / 1000
			var torque:Number = (elapsed * 50) / 1000
			
			var moveX:Number = 0;
			var moveZ:Number = 0;
			if (keyCode == Keyboard.LEFT) {
				moveX = -torque;
				//cube.body.angularDamping = 0;
			}else if (keyCode == Keyboard.RIGHT ) {
				moveX = torque;
				//cube.body.angularDamping = 0;
			}			
			if (keyCode == Keyboard.UP) {
				//cube.body.linearDamping = 0;
				moveZ = force;
			}else if (keyCode == Keyboard.DOWN) {
				//cube.body.linearDamping = 0;
				moveZ = -force;
			}
			if (moveZ != 0) {
				//displayDebugInfo(moveZ);
				//var f:Vector3D = cube.body.front;
				//f.scaleBy(moveZ);	
				//displayDebugInfo(force)
				//cube.body.position =  f
				//displayDebugInfo(f)
				
				//cube.body.linearVelocity = f
				//trace(cube.body.position.x + 10*elapsed)
				//trace(cube.body.position.y + 10*elapsed)
				//trace(cube.body.position.z + 10*elapsed)
				//position = position + velocity*dt;
				//position = position + velocity*elapsed;
				//cube.body.applyCentralForce(f);
				//cube.body.applyImpulse(f, new Vector3D(0,0,0))
				var f:Vector3D = cube.mesh.position
				
				f.z += moveZ
				//cube.mesh.position = f;
				displayDebugInfo(("start " + cube.mesh.position.toString()))
			}
			if (moveX != 0) {
				//cube.body.angularVelocity = new Vector3D(0,moveX,0);
			}
			cube.addUserInput(keyCode);			
		}
		
		private function onUserRemoved(userId:String):void {
			_view3D.scene.removeChild(_allPlayers[userId].mesh);
			//_physicsWorld.removeRigidBody(_allPlayers[userId].body);
			delete _allPlayers[userId];
		}
		private function onUserCreated(dataObject:Object):void {
			var movingCube:MovingCube = new MovingCube(dataObject.uid,dataObject.coords, dataObject.rotation,dataObject.velocity,dataObject.isMainUser, _light);
			_allPlayers[dataObject.uid] = movingCube;			
			_view3D.scene.addChild(movingCube.mesh);
			//_physicsWorld.addRigidBody(movingCube.body);
			movingCube.material.lightPicker = _lightPicker;
			//_physicsWorld.addRigidBodyWithGroup(movingCube.body, collisionBox, collisionGround);
			//movingCube.body.addEventListener(AWPEvent.COLLISION_ADDED,collisionDetectionHandler);

			trace("created",movingCube.name)
			if (dataObject.isMainUser){
				_ownerCube = movingCube;
				_ownerCube.mesh.addEventListener(Object3DEvent.POSITION_CHANGED, onCubeChanged);	
			}
		}
		
		protected function collisionDetectionHandler(event:AWPEvent):void
		{
		  //trace("collision detected");
		  //if (event.collisionObject == ballBody)
		  //{
			//trace("collision detected with ball");
		  //}
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