package com.mayhem.game 
{
	import away3d.containers.View3D;
	import away3d.controllers.FollowController;
	import away3d.controllers.HoverController;
	import away3d.core.managers.Stage3DProxy;
	import away3d.core.math.Quaternion;
	import away3d.debug.AwayStats
	import away3d.entities.Mesh;
	import away3d.events.Object3DEvent;
	import away3d.lights.DirectionalLight;
	import away3d.lights.LightBase;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.WireframePlane;
	import away3d.textures.BitmapTexture;
	import awayphysics.collision.dispatch.AWPGhostObject;
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.collision.shapes.AWPCylinderShape;
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
		
		private var _gameTimer:Timer;
		private var _currentTime:Number;
		
		private var deccelY:Number = 0;
		
		private var _direction:Vector3D = new Vector3D();
		
		private const collisionNone : int = 0;
		private const collisionGround : int = 1;
		private const collisionBox : int = 2;
		
		private var _debugDraw:AWPDebugDraw;
		
		private var _debugTextField:TextField
		
		private var _cameraController:HoverController;		
		
		
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
			
			_updateTimer = new Timer(200);
			_updateTimer.addEventListener(TimerEvent.TIMER, updatePosition);
						
			_view3D = new View3D();
			stage.addChild(_view3D);
			_view3D.stage3DProxy = proxy;
			_view3D.shareContext = true;

			_view3D.camera.y = 2000
			_view3D.camera.z = -5000;
			_view3D.camera.rotationX = 45;
			_view3D.camera.lens.far = 10000;
			
			_light = new PointLight();
			_light.specular = 0.8;
			_light.y = 1000;
			_light.color = 0xFFFFFF;
			_light.z = 0;
			_light.x = 0;
			_light.castsShadows = false;
			_light.shaderPickingDetails = false;
			_light.ambientColor = 0xFFFFFF;
			_light.radius = Number.MAX_VALUE ;
			_light.fallOff = Number.MAX_VALUE ;
			_light.ambient = 0.5;
			_light.diffuse = 1;
			_light.name = "pointlight_0";
			
			_lightPicker = new StaticLightPicker([_light]);
			
			_physicsWorld = AWPDynamicsWorld.getInstance();		
			
			_physicsWorld.initWithDbvtBroadphase();
			_physicsWorld.collisionCallbackOn = true;
			//_physicsWorld.gravity = new Vector3D(0,-10,0)
			
			//_debugDraw = new AWPDebugDraw(_view3D, _physicsWorld);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
 
			stage.addChild(new AwayStats(_view3D));
			
			MultiplayerSignals.USER_JOINED.add(onUserCreated);
			MultiplayerSignals.USERS_IN_ROOM.add(onUserInRoom);
			MultiplayerSignals.USER_REMOVED.add(onUserRemoved);
			UserInputSignals.USER_HAS_MOVED.add(onUserMoved);
			UserInputSignals.USER_HAS_STOPPED_MOVING.add(onUserStoppedMoving);
			UserInputSignals.USER_HAS_UPDATE_STATE.add(onUserUpdateState);
			
			createArena();
			
			//createMovingCube("availlant", false)
		}
		
		private function createArena():void {
			var mat1:ColorMaterial = new ColorMaterial();
			mat1.ambient = 0;
			mat1.smooth = true;
			mat1.repeat = false;
			mat1.depthCompareMode = "less";
			mat1.mipmap = true;
			mat1.bothSides = false;
			mat1.ambientColor = 0xFFFFFF;
			mat1.blendMode = "normal";
			mat1.alphaThreshold = 0;
			mat1.gloss = 1;
			mat1.alpha = 1;
			mat1.alphaBlending = false;
			mat1.name = "mat1";
			mat1.alphaPremultiplied = true;
			mat1.specularColor = 0xFFFFFF;
			mat1.color = 0x3E9613;
			mat1.specular = 0;
			mat1.lightPicker = _lightPicker;
			
			var groundMesh:Mesh = new Mesh(new CubeGeometry(5000, 50, 5000), mat1);			
			var groundShape : AWPBoxShape = new AWPBoxShape(5000, 50, 5000);
			var groundRigidbody : AWPRigidBody = new AWPRigidBody(groundShape,groundMesh, 0);
			groundRigidbody.y = -25;
			_physicsWorld.addRigidBody(groundRigidbody);
			_view3D.scene.addChild(groundMesh);
			
			var bottomWallMesh1:Mesh = new Mesh(new CubeGeometry(1900, 200, 50), mat1);
			var bottomWallShape1 : AWPBoxShape = new AWPBoxShape(1900, 200, 50);
			var bottomWallRigidbody1 : AWPRigidBody = new AWPRigidBody(bottomWallShape1,bottomWallMesh1, 0);
			bottomWallRigidbody1.x = (5000/2) - (2500/2) - 100;
			bottomWallRigidbody1.y = 100;
			bottomWallRigidbody1.z = -2475;
			_physicsWorld.addRigidBody(bottomWallRigidbody1);
			_view3D.scene.addChild(bottomWallMesh1);
			
			var bottomWallMesh2:Mesh = new Mesh(new CubeGeometry(1900, 200, 50), mat1);
			var bottomWallShape2 : AWPBoxShape = new AWPBoxShape(1900, 200, 50);
			var bottomWallRigidbody2 : AWPRigidBody = new AWPRigidBody(bottomWallShape2,bottomWallMesh2, 0);
			bottomWallRigidbody2.x =  - ((5000/2) - (2500/2)) + 100;
			bottomWallRigidbody2.y = 100;
			bottomWallRigidbody2.z = -2475;
			_physicsWorld.addRigidBody(bottomWallRigidbody2);
			_view3D.scene.addChild(bottomWallMesh2);
			
			var frontWallMesh:Mesh = new Mesh(new CubeGeometry(4000, 200, 50), mat1);
			var frontWallShape : AWPBoxShape = new AWPBoxShape(4000, 200, 50);
			var frontWallRigidbody : AWPRigidBody = new AWPRigidBody(frontWallShape,frontWallMesh, 0);
			frontWallRigidbody.y = 100;
			frontWallRigidbody.z = 2475;
			_physicsWorld.addRigidBody(frontWallRigidbody);
			_view3D.scene.addChild(frontWallMesh);
			
			var leftWallMesh:Mesh = new Mesh(new CubeGeometry(50, 200, 4000), mat1);
			var leftWallShape : AWPBoxShape = new AWPBoxShape(50, 200, 4000);
			var leftWallRigidbody : AWPRigidBody = new AWPRigidBody(leftWallShape,leftWallMesh, 0);
			leftWallRigidbody.y = 100;
			leftWallRigidbody.x = -2475;
			_physicsWorld.addRigidBody(leftWallRigidbody);
			_view3D.scene.addChild(leftWallMesh);			
			
			var rightWallMesh:Mesh = new Mesh(new CubeGeometry(50, 200, 4000), mat1);
			var rightWallShape : AWPBoxShape = new AWPBoxShape(50, 200, 4000);
			var rightWallRigidbody : AWPRigidBody = new AWPRigidBody(rightWallShape,rightWallMesh, 0);
			rightWallRigidbody.y = 100;
			rightWallRigidbody.x = 2475;
			_physicsWorld.addRigidBody(rightWallRigidbody);
			_view3D.scene.addChild(rightWallMesh);
			
			var mat2:ColorMaterial = new ColorMaterial();
			mat2.ambient = 0;
			mat2.smooth = true;
			mat2.repeat = false;
			mat2.depthCompareMode = "less";
			mat2.mipmap = true;
			mat2.bothSides = false;
			mat2.ambientColor = 0xFFFFFF;
			mat2.blendMode = "normal";
			mat2.alphaThreshold = 0;
			mat2.gloss = 1;
			mat2.alpha = 1;
			mat2.alphaBlending = false;
			mat2.name = "mat1";
			mat2.alphaPremultiplied = true;
			mat2.specularColor = 0xFFFFFF;
			mat2.color = 0x666666;
			mat2.specular = 0;
			mat2.lightPicker = _lightPicker;
			
			var nwBumperMesh:Mesh = new Mesh(new CylinderGeometry(200, 200, 200), mat2);
			var nwBumperShape : AWPCylinderShape = new AWPCylinderShape(200, 200);
			var nwBumperRigidbody : AWPRigidBody = new AWPRigidBody(nwBumperShape,nwBumperMesh, 0);
			nwBumperRigidbody.y = 100;
			nwBumperRigidbody.x = -1000;
			nwBumperRigidbody.z = 1000;
			_physicsWorld.addRigidBody(nwBumperRigidbody);
			_view3D.scene.addChild(nwBumperMesh);
			
			var neBumperMesh:Mesh = new Mesh(new CylinderGeometry(200, 200, 200), mat2);
			var neBumperShape : AWPCylinderShape = new AWPCylinderShape(200, 200);
			var neBumperRigidbody : AWPRigidBody = new AWPRigidBody(neBumperShape,neBumperMesh, 0);
			neBumperRigidbody.y = 100;
			neBumperRigidbody.x = 1000;
			neBumperRigidbody.z = 1000;
			_physicsWorld.addRigidBody(neBumperRigidbody);
			_view3D.scene.addChild(neBumperMesh);
			
			var swBumperMesh:Mesh = new Mesh(new CylinderGeometry(200, 200, 200), mat2);
			var swBumperShape : AWPCylinderShape = new AWPCylinderShape(200, 200);
			var swBumperRigidbody : AWPRigidBody = new AWPRigidBody(swBumperShape,swBumperMesh, 0);
			swBumperRigidbody.y = 100;
			swBumperRigidbody.x = -1000;
			swBumperRigidbody.z = -1000;
			_physicsWorld.addRigidBody(swBumperRigidbody);
			_view3D.scene.addChild(swBumperMesh);
			
			var seBumperMesh:Mesh = new Mesh(new CylinderGeometry(200, 200, 200), mat2);
			var seBumperShape : AWPCylinderShape = new AWPCylinderShape(200, 200);
			var seBumperRigidbody : AWPRigidBody = new AWPRigidBody(seBumperShape,seBumperMesh, 0);
			seBumperRigidbody.y = 100;
			seBumperRigidbody.x = 1000;
			seBumperRigidbody.z = -1000;
			_physicsWorld.addRigidBody(seBumperRigidbody);
			_view3D.scene.addChild(seBumperMesh);
			
			var landingPlatformMesh:Mesh = new Mesh(new CubeGeometry(400, 50, 500), mat1);
			var landingPlatformShape:AWPBoxShape = new AWPBoxShape(400, 50, 500);
			var landingPlatformBody:AWPRigidBody = new AWPRigidBody(landingPlatformShape, landingPlatformMesh, 0);
			landingPlatformBody.rotationX = 30;
			landingPlatformBody.z = -2500 - ((Math.sin(60 * Math.PI / 180) * 500) / 2)
			trace(landingPlatformBody.z)
			landingPlatformBody.y = ((Math.cos(60 * Math.PI / 180) * 500) / 2)
			_physicsWorld.addRigidBody(landingPlatformBody);
			_view3D.scene.addChild(landingPlatformMesh);
		}
		
		private function onUserUpdateState(uid:String, rBodyObject:LightRigidBody):void {
			var cube:MovingCube = _allPlayers[uid]	
			if (cube != _ownerCube) {
				updateCube(cube,rBodyObject);
			}
		}
		
		private function updateCube(cube:MovingCube, rBodyObject:LightRigidBody):void {
			cube.body.rotation = rBodyObject.rotation;
			cube.body.position = rBodyObject.position;
			cube.body.linearVelocity = rBodyObject.linearVelocity;
			cube.body.applyCentralForce(rBodyObject.totalForce);
		}
		
		private function updatePosition(event:TimerEvent):void {
			if (_ownerCube.body.linearVelocity.nearEquals(new Vector3D(0, 0, 0),0.00001)) {
				_updateTimer.stop();
				return;
			}
			UserInputSignals.USER_UPDATE_STATE.dispatch(LightRigidBody.fromAWPRigidBody(_ownerCube.body));
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
					cube.body.applyTorque(new Vector3D(0, moveX, 0));					
				}
				
				if (moveZ != 0) {
					var f:Vector3D = cube.body.front;
					f.scaleBy(moveZ);
					cube.body.applyCentralForce(f);
				}
			}				
		}		
		
		private function updateCamera():void {
			var _qCam:Quaternion = new Quaternion();
			var _qTarget:Quaternion = new Quaternion();	
			
			var mat:Matrix3D = _ownerCube.mesh.transform;
			
			var rotateAxis:Vector3D = Vector3D.X_AXIS;
			var _qAxis:Quaternion = new Quaternion();
			_qAxis.fromAxisAngle(rotateAxis,Math.PI / 4)
			
			_qTarget.fromMatrix(mat);
			_qTarget.multiply(_qTarget, _qAxis);
			
			var cameraTransform:Matrix3D = _view3D.camera.transform.clone();
			
			_qCam.fromMatrix(cameraTransform);
			
			_qCam.lerp(_qCam, _qTarget,0.1);
			
			var newTransform:Matrix3D = _qCam.toMatrix3D().clone();
			
			_view3D.camera.transform = newTransform;
			
			_view3D.camera.position = _ownerCube.mesh.position.clone();
			_view3D.camera.moveBackward(3000);
			_view3D.camera.moveDown(500); 
		}
		
		public function renderPhysics():void {
			if (_ownerCube) {
				updateCamera();
			}
			var t:int = getTimer();
			var dt:Number = (t - _currentTime);
			_currentTime = t;
			moveObjects(dt);
			_physicsWorld.step(dt / 1000, 1, _timeStep);
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
			_ownerCube.removeUserInput(event.keyCode);		
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
				_ownerCube.addUserInput(event.keyCode);			
				UserInputSignals.USER_IS_MOVING.dispatch(event.keyCode,new Date().getTime());
			}
		}
		
		private function onUserStoppedMoving(userId:String, keyCode:uint, timestamp:Number):void {
			
			var cube:MovingCube = _allPlayers[userId];
			//if (cube != _ownerCube)
				//return;
			var elapsed:Number = timestamp - new Date().getTime();
			
			var force:Number = (elapsed * 500) / 1000
			var moveZ:Number = 0;
			
			switch(keyCode) {
				case Keyboard.LEFT:
				case Keyboard.RIGHT:
					cube.body.angularDamping = 0.98;
					break;
				case Keyboard.UP:
					moveZ = -force;
					cube.body.linearDamping = 0.98;
					break;
				case Keyboard.DOWN:
					moveZ = force;
					cube.body.linearDamping = 0.98;
					break;
			}
			if (cube != _ownerCube){
				if (moveZ != 0) {
					var f:Vector3D = cube.body.front;
					f.scaleBy(moveZ);				
					cube.body.applyCentralForce(f)
				}
			
				cube.removeUserInput(keyCode);
			}
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
			
			
			var cube:MovingCube = _allPlayers[userId];
			
			var elapsed:Number = new Date().getTime() - timestamp
			
			var force:Number = (elapsed * 500) / 1000
			var torque:Number = (elapsed * 50) / 1000
		
			
			var moveX:Number = 0;
			var moveZ:Number = 0;
			if (keyCode == Keyboard.LEFT) {
				moveX = -torque;
				cube.body.angularDamping = 0;
			}else if (keyCode == Keyboard.RIGHT ) {
				moveX = torque;
				cube.body.angularDamping = 0;
			}			
			if (keyCode == Keyboard.UP) {
				cube.body.linearDamping = 0;
				moveZ = force;
			}else if (keyCode == Keyboard.DOWN) {
				cube.body.linearDamping = 0;
				moveZ = -force;
			}
			if (cube != _ownerCube){
				if (moveZ != 0) {
					var f:Vector3D = cube.body.front;
					f.scaleBy(moveZ);	
					cube.body.applyCentralForce(f);
				}
				if (moveX != 0) {
					//cube.body.angularVelocity = new Vector3D(0,moveX,0);
				}
				cube.addUserInput(keyCode);		
			}
		}
		
		private function onUserRemoved(userId:String):void {
			_view3D.scene.removeChild(_allPlayers[userId].mesh);
			_physicsWorld.removeRigidBody(_allPlayers[userId].body);
			delete _allPlayers[userId];
		}
		
		private function createMovingCube(name:String,isOwner:Boolean, lightRigidBody:LightRigidBody = null):MovingCube {
			var movingCube:MovingCube = new MovingCube(name,  new Vector3D(0,200,-2600),  new Vector3D(30,0,0), new Vector3D(0,0,0), isOwner);
			_view3D.scene.addChild(movingCube.mesh);
			_physicsWorld.addRigidBody(movingCube.body);
			movingCube.material.lightPicker = _lightPicker;
			trace("created",movingCube.name)
			if (isOwner){
				_ownerCube = movingCube;
				_ownerCube.body.addEventListener(AWPEvent.COLLISION_ADDED,collisionDetectionHandler);
				_ownerCube.mesh.addEventListener(Object3DEvent.POSITION_CHANGED, onCubeChanged);
				_ownerCube.mesh.addEventListener(Object3DEvent.ROTATION_CHANGED, onCubeChanged);					
			}
			trace(lightRigidBody)
			if (lightRigidBody) {
				trace(lightRigidBody, lightRigidBody.position)
				updateCube(movingCube, lightRigidBody);
			}
			return movingCube;
		}
		
		private function onUserInRoom(dataObject:Object):void {
			_allPlayers[dataObject.uid] = createMovingCube(dataObject.uid,dataObject.isMainUser, dataObject.rigidBody);
		}
		private function onUserCreated(dataObject:Object):void {
			_allPlayers[dataObject.uid] = createMovingCube(dataObject.uid,dataObject.isMainUser);			
		}
		
		protected function collisionDetectionHandler(event:AWPEvent):void
		{
			var cubeCollider:MovingCube = MovingCube(event.collisionObject.skin.extra);
			if (cubeCollider)
			{
				//trace(_ownerCube.hasCollided)
				if (!_ownerCube.hasCollided){
					_ownerCube.velocityBeforeCollision = _ownerCube.currentVelocity.clone();
					var ownerForce:Number = _ownerCube.velocityBeforeCollision.length;
					var colliderForce:Number = cubeCollider.body.linearVelocity.length;
					var loserCube:MovingCube = ownerForce < colliderForce ? _ownerCube : cubeCollider; 
					//loserCube.body.clearForces();
					trace(_ownerCube.velocityBeforeCollision.crossProduct(cubeCollider.body.linearVelocity))
					trace(cubeCollider.body.linearVelocity.crossProduct(_ownerCube.velocityBeforeCollision))
					var forceToApply:Vector3D = _ownerCube.velocityBeforeCollision.crossProduct(cubeCollider.body.linearVelocity)
					//forceToApply.scaleBy(100)
					//loserCube.body.angularDamping = 0
					//loserCube.body.angularFactor = new Vector3D(0,0,0)
					//loserCube.body.applyCentralImpulse(forceToApply)
					//loserCube.body.friction = 0.001
					//loserCube.body.
					trace('//////////////////////')
				}
				_ownerCube.hasCollided = true;
				
				
				
				
				//trace(_ownerCube.velocityBeforeCollision)
				//trace(_ownerCube.velocityBeforeCollision.length)
				//trace("collision detected with cube",cubeCollider);
				//trace("owner velocity",_ownerCube.body.linearVelocity);
				//trace("owner force",_ownerCube.body.totalForce);
				//trace("collider velocity",cubeCollider.body.linearVelocity.length);
				//trace("collider force", cubeCollider.body.totalForce);
				
			}
		}
		
		
		private function onCubeChanged(event:Object3DEvent):void {
			_ownerCube.currentVelocity = _ownerCube.body.linearVelocity;
			if (!_updateTimer.running)
				_updateTimer.start();
		}
	
		
		public function get renderer():View3D {
			return _view3D;
		}
		
		
		
	}

}