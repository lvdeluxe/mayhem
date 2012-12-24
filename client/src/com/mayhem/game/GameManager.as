package com.mayhem.game 
{
	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.core.math.Quaternion;
	import away3d.debug.AwayStats
	import away3d.entities.Mesh;
	import away3d.events.Object3DEvent;
	import away3d.lights.PointLight;
	import away3d.containers.ObjectContainer3D;
	import awayphysics.data.AWPCollisionFlags;
	import awayphysics.debug.AWPDebugDraw;
	import awayphysics.dynamics.AWPDynamicsWorld;
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.events.AWPEvent;
	import caurina.transitions.Tweener;
	import com.mayhem.multiplayer.Connector;
	import flash.display.Stage;
	import flash.events.TimerEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import com.mayhem.signals.*;
	import flash.utils.setTimeout;
	
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
		private var _physicsWorld:AWPDynamicsWorld;
		private var _timeStep : Number = 1.0 / 60;
		
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
		private var _currentTime:Number;
		private var _debugDraw:AWPDebugDraw;
		
		private var _incAICubes:uint = 0;
		
		private var _allAICubes:Dictionary;
		
		private var _arenaReady:Boolean = false;
		
		private var _AIMaster:Boolean = false;
	
		public function GameManager(stage:Stage, proxy:Stage3DProxy) 
		{
			_allPlayers = new Dictionary();			
			_allAICubes = new Dictionary();			
			setUpdateTimer();
			setView(stage,proxy);
			setLights();
			setPhysics();
			setSignals();			
			//createAICubes();
			MaterialsFactory.initialize([_light]);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			var stats:AwayStats = new AwayStats(_view3D)
			stage.addChild(stats);
			ArenaFactory.instance.initialize(_physicsWorld);
			ParticlesFactory.instance.initialize(_view3D.scene);
			CameraManager.instance.initialize(_view3D.camera);
			_view3D.scene.addChild(ArenaFactory.instance.getDefaultArena());
		}
		
		private function setUpdateTimer():void{			
			_currentTime = getTimer();					
			_updateTimer = new Timer(100);
			_updateTimer.addEventListener(TimerEvent.TIMER, updatePosition);
		}
		
		private function setView(pStage:Stage, pProxy:Stage3DProxy):void{						
			_view3D = new View3D();
			pStage.addChild(_view3D);
			_view3D.stage3DProxy = pProxy;
			_view3D.shareContext = true;

			_view3D.camera.y = 2000
			_view3D.camera.z = -5000;
			_view3D.camera.rotationX = 45;
			_view3D.camera.lens.far = 10000;
		}
		
		private function setLights():void{			
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
		}
		
		private function setPhysics():void{			
			_physicsWorld = AWPDynamicsWorld.getInstance();					
			_physicsWorld.initWithDbvtBroadphase();
			_physicsWorld.collisionCallbackOn = true;			
			_debugDraw = new AWPDebugDraw(_view3D, _physicsWorld);
		}
		
		private function setSignals():void{			
			MultiplayerSignals.USER_JOINED.add(onUserCreated);
			MultiplayerSignals.USERS_IN_ROOM.add(onUserInRoom);
			MultiplayerSignals.USER_REMOVED.add(onUserRemoved);
			MultiplayerSignals.USER_HAS_COLLIDED.add(onCubeCollision)
			UserInputSignals.USER_HAS_MOVED.add(onUserMoved);
			UserInputSignals.USER_HAS_STOPPED_MOVING.add(onUserStoppedMoving);
			UserInputSignals.USER_HAS_UPDATE_STATE.add(onUserUpdateState);
			UserInputSignals.AI_HAS_UPDATE_STATE.add(onAIUpdateState);
			UserInputSignals.USER_IS_FALLING.add(onUserFelt);
			GameSignals.ARENA_READY.add(onArenaReady);
		}
		
		private function onUserFelt(cube:MovingCube):void {
			if (cube == _ownerCube) {
				UISignals.OWNER_FELT.dispatch();
				setTimeout(respawn, 2000);
			}
		}
		private function respawn():void {
			UISignals.OWNER_RESPAWNED.dispatch();
			_ownerCube.body.angularVelocity = new Vector3D();
			_ownerCube.body.linearVelocity = new Vector3D();
			_ownerCube.body.linearDamping = 0.98;
			_ownerCube.body.angularDamping = 0.98;
			_ownerCube.hasFelt = false;
			_ownerCube.body.position = _ownerCube.spawnPosition;
			_ownerCube.mesh.lookAt( new Vector3D(0, 50, 0));
			_ownerCube.body.rotation = new Vector3D(0,_ownerCube.mesh.rotationY,0);
		}
		
		private function onCubeCollision(manifold:CollisionManifold):void {
			var cubeA:MovingCube = _allPlayers[manifold.colliderA];
			var cubeB:MovingCube = _allPlayers[manifold.colliderB];
			var loser:MovingCube = manifold.forceA > manifold.forceB ? cubeB : cubeA;
			var winner:MovingCube = manifold.forceA > manifold.forceB ? cubeA : cubeB;
			trace(manifold.forceA,manifold.forceB)
			if (loser == _ownerCube) {
				var remove:Number = (cubeA == _ownerCube) ? manifold.forceB : manifold.forceA;
				_ownerCube.totalEnergy -= remove;
				if (_ownerCube.totalEnergy < 0) {
					_ownerCube.totalEnergy = 0;
				}
				if (_ownerCube.totalEnergy >= 0) UISignals.ENERGY_UPDATE.dispatch(_ownerCube.totalEnergy / MovingCube.MAX_ENERGY);
				if (_ownerCube.totalEnergy == 0) {
					UISignals.ENERGY_OUT.dispatch();
					setTimeout(respawn, 2000);
				}				
			}
			trace(cubeA, cubeB, loser, winner)
			var collisionPosition:Vector3D = manifold.forceA > manifold.forceB ? manifold.positionB : manifold.positionA;
			setTimeout(function():void{
				winner.hasCollided = false;
			},200);
			
			loser.setImpactState(collisionPosition);
		}
		
		
		private function onAIUpdateState(v:Vector.<Object>):void {
			if(!_AIMaster){
				for each(var obj:Object in v) {
					var aiCube:MovingAICube = _allAICubes["ai_" + obj.index.toString()];
					updateCube(aiCube,obj.body);
				}
			}
		}
		private function onUserUpdateState(uid:String, rBodyObject:LightRigidBody):void {
			var cube:MovingCube = _allPlayers[uid]	
			if (cube != _ownerCube) {
				updateCube(cube,rBodyObject);
			}
		}
		
		private function updateCube(cube:MovingCube, rBodyObject:LightRigidBody):void {
			if(rBodyObject && cube)rBodyObject.applyToRigidBody(cube.body);
		}
		
		private function updatePosition(event:TimerEvent):void {
			if (_ownerCube.body.linearVelocity.nearEquals(new Vector3D(0, 0, 0),0.00001) && !_AIMaster) {
				_updateTimer.stop();
				return;
			}
			UserInputSignals.USER_UPDATE_STATE.dispatch(LightRigidBody.fromAWPRigidBody(_ownerCube.body));
			
			if (_AIMaster) {
				var v:Vector.<Object> = new Vector.<Object>()
				for each(var AICube:MovingAICube in _allAICubes) {
					var o:Object = { index:int(AICube.name.split("_")[1]), body:LightRigidBody.fromAWPRigidBody(AICube.body) };
					v.push(o);					
				}
				UserInputSignals.AI_UPDATE_STATE.dispatch(v);
			}
		}
		
		
		private function moveObjects(elapsed:Number):void {			
			//apply 1000 force per second.
			var force:Number = (elapsed * 1000) / 1000
			//apply 50 torque per second
			var torque:Number = 2.5//0.1//(elapsed * 2) / 1000
			
			var moveX:Number = 0;
			var moveZ:Number = 0;			
				
			for each(var cube:MovingCube in _allPlayers) {
				moveX = 0;
				moveZ = 0;
				if (cube.userInputs[MOVE_LEFT_KEY])
					moveX = -torque;
				else if (cube.userInputs[MOVE_RIGHT_KEY])
					moveX = torque;
				if (cube.userInputs[MOVE_UP_KEY])
					moveZ = force;
				else if (cube.userInputs[MOVE_DOWN_KEY])
					moveZ = - force;				
				
				if (moveZ != 0) {
					var f:Vector3D = cube.body.front;
					f.scaleBy(moveZ);
					cube.body.applyCentralForce(f);						
				}
				
				var totalForce:Number = cube.body.linearVelocity.clone().normalize();
				if (moveX != 0) {		
					cube.body.activate(true);
					cube.body.angularVelocity = new Vector3D(0,moveX ,0);
				}				
			}				
		}	
		
		public function getElapsedTime():Number {
			var t:int = getTimer();
			var dt:Number = (t - _currentTime);
			_currentTime = t;
			return dt;
		}
		
		public function renderPhysics():void {
			
			if (_ownerCube){
				CameraManager.instance.updateCamera(_ownerCube.mesh.transform.clone(), _ownerCube.mesh.position.clone());
			}
			var dt:Number = getElapsedTime();
			moveObjects(dt);
			ParticlesFactory.instance.checkRemoveParticles();
			setLastVelocity();
			setAIBehavior();			
			_physicsWorld.step(dt / 1000, 5, _timeStep);	
			
			//_debugDraw.debugDrawWorld();
		}
		
		private function getClosestTarget(position:Vector3D):MovingCube {
			var distanceTmp:Number = Number.MAX_VALUE;
			var closest:MovingCube;
			for each(var user:MovingCube in _allPlayers) {
				var dist:Number = Vector3D.distance(user.body.position, position);
				var min:Number = Math.min(distanceTmp, dist);
				if (min == dist) {
					closest = user;
				}
				distanceTmp = dist;
			}
			return closest;
		}
		
		private function chaseTarget(chaser:MovingAICube, target:MovingCube):void {
			if (target) {				
				var a:Number = target.body.position.z - chaser.body.z;
				var b:Number = target.body.position.x - chaser.body.x;
				var rads:Number = Math.atan2(a, b);
				chaser.body.rotation = new Vector3D(0, -(rads * 180 / Math.PI) + 90, 0);
				//
				var f:Vector3D = chaser.body.front;
				f.scaleBy(10);
				chaser.body.applyCentralForce(f);		
			}
		}
		
		private function setAIBehavior():void {
			for each(var AICube:MovingAICube in _allAICubes) 
				chaseTarget(AICube, getClosestTarget(AICube.body.position));
		}
		
		private function setLastVelocity():void
		{
			for each(var cube:MovingCube in _allPlayers) {
				cube.linearVelocityBeforeCollision = cube.body.linearVelocity.clone();
			}
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
	
		private function onUserMoved(userId:String, keyCode:uint, timestamp:Number):void {			
			var cube:MovingCube = _allPlayers[userId];			
			var elapsed:Number = new Date().getTime() - timestamp
			
			var force:Number = (elapsed * 500) / 1000;
			var torque:Number = (elapsed * 50) / 1000;		
			
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
					f.scaleBy(5);	
					cube.body.linearVelocity = f;
				}
				if (moveX != 0) {
					cube.body.angularVelocity = new Vector3D(0,moveX,0);
				}
				cube.addUserInput(keyCode);		
			}
		}
		
		private function onUserRemoved(userId:String, userIndex:int):void {
			var movingCube:MovingAICube = createAICube(userIndex);
			_allAICubes[movingCube.name] = movingCube;
			_view3D.scene.removeChild(_allPlayers[userId].mesh);
			_physicsWorld.removeRigidBody(_allPlayers[userId].body);
			delete _allPlayers[userId];
		}
		
		private function createAICube(index:int):MovingAICube {
			var movingCube:MovingAICube = new MovingAICube("ai_"+(index.toString()),  new Vector3D(0, 50, -0),  new Vector3D(0, 180, 0), new Vector3D(0, 0, 0), false);
			//movingCube.body.addEventListener(AWPEvent.COLLISION_ADDED, collisionDetectionHandler);
			movingCube.spawnPosition = ArenaFactory.instance.getSpawnPoint(index);
			_view3D.scene.addChild(movingCube.mesh);
			_physicsWorld.addRigidBody(movingCube.body);
			movingCube.body.position = movingCube.spawnPosition;
			return movingCube;
		}
		
		private function createAICubes():void {
			var numAICubes:uint = ArenaFactory.instance.getAvailableSlots();
			trace(numAICubes)
			for (var i:uint = Connector.MAX_USER_PER_ROOM - numAICubes ; i < Connector.MAX_USER_PER_ROOM; i++) {
				var movingCube:MovingAICube = createAICube(i);
				_allPlayers[movingCube.name] = movingCube;
				_allAICubes[movingCube.name] = movingCube;
			}			
		}
		
		private function onArenaReady(allSpawnPoint:Vector.<Mesh>):void {
			_arenaReady = true;
			for each(var cube:MovingCube in _allPlayers) {
				if (!cube.mesh.parent) {
					_view3D.scene.addChild(cube.mesh);
					_physicsWorld.addRigidBody(cube.body);
				}
			}
		}
		
		private function createMovingCube(name:String, isOwner:Boolean, spawnPointIndex:int, lightRigidBody:LightRigidBody = null):MovingCube {
			var movingCube:MovingCube = new MovingCube(name,  new Vector3D(0, 50, -2500),  new Vector3D(0, 0, 0), new Vector3D(0, 0, 0), isOwner);
			if(_arenaReady){
				_view3D.scene.addChild(movingCube.mesh);
				_physicsWorld.addRigidBody(movingCube.body);
			}
			trace("created", movingCube.name);
			if (isOwner) {
				if (spawnPointIndex == 0)
					_AIMaster = true;
				_ownerCube = movingCube;
				_ownerCube.spawnPosition = ArenaFactory.instance.getSpawnPoint(spawnPointIndex);
				_ownerCube.body.addEventListener(AWPEvent.COLLISION_ADDED, collisionDetectionHandler);
				_ownerCube.body.position = _ownerCube.spawnPosition;
				var lookAtPoint:Vector3D = new Vector3D();
				_ownerCube.mesh.lookAt( new Vector3D(0, 50, 0));
				_ownerCube.body.rotation = new Vector3D(0,_ownerCube.mesh.rotationY,0);
				_ownerCube.mesh.addEventListener(Object3DEvent.POSITION_CHANGED, onCubeChanged);
				_ownerCube.mesh.addEventListener(Object3DEvent.ROTATION_CHANGED, onCubeChanged);
				createAICubes();
			}
			if (lightRigidBody) {
				updateCube(movingCube, lightRigidBody);
			}
			return movingCube;
		}
		
		private function onUserInRoom(dataObject:Object):void {
			_allPlayers[dataObject.uid] = createMovingCube(dataObject.uid,dataObject.isMainUser, -1, dataObject.rigidBody);
		}
		
		private function onUserCreated(dataObject:Object):void {
			_allPlayers[dataObject.uid] = createMovingCube(dataObject.uid, dataObject.isMainUser, dataObject.user_index);			
			var aiCube:MovingAICube = _allAICubes["ai_" + dataObject.user_index];
			if (aiCube) {
				_view3D.scene.removeChild(aiCube.mesh);
				_physicsWorld.removeRigidBody(aiCube.body);
				delete _allPlayers[aiCube.name];
				delete _allAICubes[aiCube.name];
			}
		}
		
		protected function collisionDetectionHandler(event:AWPEvent):void
		{
			
			if (!event.collisionObject.skin)
				return;
				
			var cubeCollider:MovingCube = event.collisionObject.skin.extra as MovingCube;
			
			if (cubeCollider)
			{
				trace('collision!!!!!! ',_ownerCube.hasCollided, cubeCollider.hasCollided)
				if (!_ownerCube.hasCollided && !cubeCollider.hasCollided) {
					var manifold:CollisionManifold = new CollisionManifold();
					manifold.colliderA = cubeCollider.name;
					manifold.colliderB = _ownerCube.name;
					manifold.positionA = event.manifoldPoint.localPointA;
					manifold.positionB = event.manifoldPoint.localPointB;
					manifold.forceA = cubeCollider.linearVelocityBeforeCollision.length;
					manifold.forceB = _ownerCube.linearVelocityBeforeCollision.length;
					trace(manifold.forceA,manifold.forceB)
					if (manifold.forceA > manifold.forceB) {
						trace('DISPATCH COLLISION')
						UserInputSignals.USER_IS_COLLIDING.dispatch(manifold);
					}
					_ownerCube.hasCollided = true;
					cubeCollider.hasCollided = true;
				}
				
				
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