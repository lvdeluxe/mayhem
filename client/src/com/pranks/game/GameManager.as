package com.pranks.game 
{
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.AwayStats
	import away3d.entities.Mesh;
	import away3d.events.Object3DEvent;
	import away3d.lights.DirectionalLight;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.HardShadowMapMethod;
	import away3d.materials.methods.SoftShadowMapMethod;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.WireframePlane;
	import away3d.textures.BitmapTexture;
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.collision.shapes.AWPStaticPlaneShape;
	import awayphysics.dynamics.AWPDynamicsWorld;
	import awayphysics.dynamics.AWPRigidBody;
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
		
		private var _light:PointLight;
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
		
		private var _tf:TextField;
		
		private var _gameTimer:Timer;
		private var _currentElapsed:Number;
		
		
		public function GameManager(stage:Stage, proxy:Stage3DProxy) 
		{
			_allPlayers = new Dictionary();
			
			_currentElapsed = getTimer();
			
			
			_updateTimer = new Timer(500);
			_updateTimer.addEventListener(TimerEvent.TIMER, updatePosition);
			
			_tf = new TextField();;
			_tf.width = 300;
			_tf.height = 150;
			_tf.border = true;
			_tf.textColor = 0xcc0000;
			_tf.multiline = true;			
						
			_view3D = new View3D();
			stage.addChild(_view3D);
			stage.addChild(_tf)
			_view3D.stage3DProxy = proxy;
			_view3D.shareContext = true;
			_view3D.camera.y = 1200
			_view3D.camera.z = -1750;
			_view3D.camera.rotationX = 45;
			_view3D.camera.lens.far = 10000;
			
			
			_light = new PointLight();
			_light.color = 0x2ef5c6;
			_light.y = 5000;
			_light.z = 0;
			_view3D.scene.addChild(_light);
			
			_lightPicker = new StaticLightPicker([_light]);
			
			_physicsWorld = AWPDynamicsWorld.getInstance();
			_physicsWorld.initWithDbvtBroadphase();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
 
			//stage.addChild(new AwayStats(_view3D));
			
			MultiplayerSignals.USER_CREATED.add(onUserCreated);
			MultiplayerSignals.USER_REMOVED.add(onUserRemoved);
			UserInputSignals.USER_HAS_MOVED.add(onUserMoved);
			UserInputSignals.USER_HAS_STOPPED_MOVING.add(onUserStoppedMoving);
			UserInputSignals.USER_HAS_UPDATE_STATE.add(onUserUpdateState);
			
			var material : ColorMaterial = new ColorMaterial(0x252525);
			material.lightPicker = _lightPicker;
			material.ambientColor = 0x0000cc;
			var mesh:Mesh = new Mesh(new PlaneGeometry(2500, 2500), material);
			
			var groundShape : AWPStaticPlaneShape = new AWPStaticPlaneShape(new Vector3D(0, 1, 0));
			var groundRigidbody : AWPRigidBody = new AWPRigidBody(groundShape, mesh, 0);
			_physicsWorld.addRigidBody(groundRigidbody);
			_view3D.scene.addChild(mesh);
			
		}
		
		private function onUserUpdateState(uid:String, rotation:Vector3D, position:Vector3D):void {
			var cube:MovingCube = _allPlayers[uid]
			if (cube != _ownerCube) {
				trace(rotation)
				cube.body.rotation = rotation;
				cube.body.position = position;
			}
		}
		
		private function updatePosition(event:TimerEvent):void {
			if (_ownerCube.body.linearVelocity.equals(new Vector3D(0, 0, 0)))
				_updateTimer.stop();
			trace(_ownerCube.body.linearVelocity)
			UserInputSignals.USER_UPDATE_STATE.dispatch(_ownerCube.body.rotation, _ownerCube.body.position);
		}
		
		private function moveObjects():void {
			var t:int = getTimer();
			var dt:Number = (t - _currentElapsed);
			_currentElapsed = t;
			//trace(dt)
			//apply 500 force per second.
			var val:Number = (dt * 500) / 1000
			//trace(val)
			var moveX:Number = 0;
			var moveZ:Number = 0;
				
			for each(var cube:MovingCube in _allPlayers) {
				moveX = 0;
				moveZ = 0;
				var  prev:Vector3D = cube.body.position
				//trace(prev)
				if (cube.userInputs[MOVE_LEFT_KEY])
					moveX = -10//val;
				else if (cube.userInputs[MOVE_RIGHT_KEY])
					moveX = 10//val;
				if (cube.userInputs[MOVE_UP_KEY])
					moveZ = 10//val;
				else if (cube.userInputs[MOVE_DOWN_KEY])
					moveZ = -10//val;
					
				if (moveX != 0 || moveZ != 0) {
					//hasMoved = true;
					cube.body.applyCentralForce(new Vector3D(moveX, 0, moveZ ));
					
					//cube.body.linearVelocity = new Vector3D(moveX, 0, moveZ);
					//cube.body.position = new Vector3D(prev.x + moveX, 0, prev.z + moveZ);
				}
				
			}
			
		}		
		
		public function renderPhysics():void {
			_physicsWorld.step(_timeStep, 1, _timeStep);
			moveObjects();
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
				//_incFrame = 0;
				trace("sendingMessage")
				//_updateTimer.start();
				UserInputSignals.USER_IS_MOVING.dispatch(event.keyCode,new Date().getTime());
			}
		}
		
		private function onUserStoppedMoving(userId:String, keyCode:uint):void {
			var cube:MovingCube = _allPlayers[userId];
			cube.removeUserInput(keyCode);
			//if (_ownerCube.userInputs[MOVE_LEFT_KEY] == false && _ownerCube.userInputs[MOVE_RIGHT_KEY] == false && _ownerCube.userInputs[MOVE_UP_KEY] == false && _ownerCube.userInputs[MOVE_DOWN_KEY] == false ) {
				//_updateTimer.stop();
				//_updateTimer.reset();
			//}
		}
		
		private function onUserMoved(userId:String, keyCode:uint, timestamp:Number):void {
			//_tf.text = (new Date().getTime() - timestamp).toString();
			var elapsed:Number = new Date().getTime() - timestamp
			_incFrame = 0;
			var cube:MovingCube = _allPlayers[userId];
			var val:Number = (elapsed * 500) / 1000
			
			var moveX:Number = 0;
			var moveZ:Number = 0;
			
			if (keyCode == Keyboard.LEFT)
				moveX = -val;
			else if (keyCode == Keyboard.RIGHT)
				moveX = val;
			if (keyCode == Keyboard.UP)
				moveZ = val;
			else if (keyCode == Keyboard.DOWN)
				moveZ = -val;
				
			cube.body.applyCentralForce(new Vector3D(moveX, 0, moveZ ));
			//_tf.text = elapsed.toString() + " / " + moveX.toString() + " / " + moveZ.toString();
			trace('input received')
			cube.addUserInput(keyCode);
			
		}
		
		private function onUserRemoved(userId:String):void {
			_view3D.scene.removeChild(_allPlayers[userId].mesh);
			delete _allPlayers[userId];
		}
		private function onUserCreated(dataObject:Object):void {
			var movingCube:MovingCube = new MovingCube(dataObject.uid,dataObject.coords, dataObject.isMainUser);
			_allPlayers[dataObject.uid] = movingCube;			
			_view3D.scene.addChild(movingCube.mesh);
			movingCube.material.lightPicker = _lightPicker;
			_physicsWorld.addRigidBody(movingCube.body);
			if (dataObject.isMainUser)
				_ownerCube = movingCube;
				_ownerCube.mesh.addEventListener(Object3DEvent.POSITION_CHANGED, onCubeChanged);
		}
		
		private function onCubeChanged(event:Object3DEvent):void {
			if (!_updateTimer.running)
				_updateTimer.start();
		}
	
		
		public function get renderer():View3D {
			return _view3D;
		}
		
		
		
	}

}