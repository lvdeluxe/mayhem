package com.mayhem.game 
{
	import away3d.containers.View3D;
	import away3d.core.managers.Mouse3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.core.math.Quaternion;
	import away3d.core.math.Vector3DUtils;
	import away3d.debug.AwayStats
	import away3d.debug.Trident;
	import away3d.entities.Mesh;
	import away3d.events.Object3DEvent;
	import away3d.lights.DirectionalLight;
	import away3d.lights.PointLight;
	import away3d.containers.ObjectContainer3D;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.SkyBox;
	import away3d.textures.BitmapCubeTexture;
	import awayphysics.data.AWPCollisionFlags;
	import awayphysics.debug.AWPDebugDraw;
	import awayphysics.dynamics.AWPDynamicsWorld;
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.events.AWPEvent;
	import caurina.transitions.Tweener;
	import com.bit101.components.HUISlider;
	import com.mayhem.game.powerups.ExplosionData;
	import com.mayhem.game.powerups.PowerUpMessage;
	import com.mayhem.multiplayer.Connector;
	import com.mayhem.multiplayer.GameUserVO;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
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
	import playerio.DatabaseObject;
	
	/**
	 * ...
	 * @author availlant
	 */
	public class GameManager 
	{
		
		private var _view3D:View3D;
		private var _allPlayers:Dictionary;
		
		private var _ownerCube:MovingCube;	
		
		private var _light:DirectionalLight;
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
		
		private var _AIMaster:Boolean = false;
		
		private var _propsMenu:VehiclePropertiesMenu;
		
		private var _totalGameTime:uint = 0;
		
		private var _endSession:Boolean = false;
		
		private var _stage:Stage;
		
		private var _pausedVehicles:Dictionary = new Dictionary();
		
		private var _stats:GameStats;
		
		private var _cubemap:BitmapCubeTexture;
		
	
		public function GameManager(stage:Stage, proxy:Stage3DProxy) 
		{
			_stage = stage;
			_allPlayers = new Dictionary();			
			_allAICubes = new Dictionary();			
			setUpdateTimer();
			setView(stage,proxy);
			setLights();
			setSkybox();
			setPhysics();
			setSignals();			
			MaterialsFactory.initialize([_light]);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(Event.RESIZE, onResize);
			var stats:AwayStats = new AwayStats(_view3D)
			stage.addChild(stats);
			ArenaFactory.instance.initialize(_physicsWorld);
			ParticlesFactory.instance.initialize(_view3D.scene);
			CameraManager.instance.initialize(_view3D.camera);
			_view3D.scene.addChild(ArenaFactory.instance.getDefaultArena());
			_propsMenu = new VehiclePropertiesMenu(stage, this, new Point(0,stats.height + 10));
		}
		
		private function onResize(event:Event):void {
			//_view3D.
			//_view3D.width = _stage.stage3Ds[0].context3D.
			//_view3D.height = _stage.height
		}
		
		private function setSkybox():void {
			_cubemap = ModelsManager.instance.getSkyboxTexture();
			var sky:SkyBox = new SkyBox(_cubemap);
			_view3D.scene.addChild(sky);
		}
		
		public function getOwnerVehicle():MovingCube {
			return _ownerCube;
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
			_light = new DirectionalLight();
			_light.diffuse = 1;
			_light.color = 0xFFFFFF;
			_light.ambient = 0.5;
			_light.castsShadows = true;
			_light.ambientColor = 0xFFFFFF;
			_light.specular = 0.8;
			_light.shaderPickingDetails = true;
			_light.direction = new Vector3D(-0.07848641852943786, -0.9962904287522878, -0.035288293852277955);
			_light.name = "pointlight_0";
			_view3D.scene.addChild(_light);
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
			MultiplayerSignals.USER_HAS_COLLIDED.add(onCubeCollision);
			MultiplayerSignals.POWERUP_TRIGGERED.add(onPowerUpTriggered);
			UserInputSignals.USER_HAS_MOVED.add(onUserMoved);
			UserInputSignals.USER_HAS_STOPPED_MOVING.add(onUserStoppedMoving);
			UserInputSignals.USER_HAS_UPDATE_STATE.add(onUserUpdateState);
			UserInputSignals.AI_HAS_UPDATE_STATE.add(onAIUpdateState);
			UserInputSignals.USER_IS_FALLING.add(onUserFelt);			
			GameSignals.REFILL_POWERUP.add(onPowerUpRefill);
			MultiplayerSignals.SESSION_PAUSED.add(replaceUserByAIVehicle);
			UISignals.CLICK_RESTART.add(sendRestart);
			MultiplayerSignals.SESSION_RESTARTED.add(restartSession);
		}
		
		private function restartSession(vehicleName:String):void {
			_stats = new GameStats(_ownerCube.name);
			var spawnIndex:int = ArenaFactory.instance.getSpawnIndexByPosition(_ownerCube.spawnPosition)
			var aiVehicle:MovingAICube = _allAICubes["ai_" + spawnIndex.toString()];
			_physicsWorld.removeRigidBody(aiVehicle.body);
			_view3D.scene.removeChild(aiVehicle.mesh);
			delete _allAICubes["ai_" + spawnIndex.toString()];
			delete _allPlayers["ai_" + spawnIndex.toString()];
			
			var pausedVehicle:MovingCube = _pausedVehicles[vehicleName];
			_allPlayers[vehicleName] = pausedVehicle;
			_physicsWorld.addRigidBody(pausedVehicle.body);
			if (pausedVehicle == _ownerCube) {
				_stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				_stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			}
			pausedVehicle.body.addEventListener(AWPEvent.COLLISION_ADDED, collisionDetectionHandler);
			pausedVehicle.mesh.addEventListener(Object3DEvent.POSITION_CHANGED, onCubeChanged);
			pausedVehicle.mesh.addEventListener(Object3DEvent.ROTATION_CHANGED, onCubeChanged);
			TextureMaterial(pausedVehicle.mesh.material).alpha = 1;
			_totalGameTime = 0;
			_endSession = false;
			respawn(pausedVehicle);
			
			delete _pausedVehicles[vehicleName];
		}
		
		private function sendRestart():void
		{
			var index:int = ArenaFactory.instance.getSpawnIndexByPosition(_ownerCube.spawnPosition);
			GameSignals.SESSION_RESTART.dispatch(_ownerCube.name, index);
		}
		
		private function replaceUserByAIVehicle(dbObject:DatabaseObject):void {
			var vehicleName:String = dbObject.key;
			_stats.updateWithAllTimeData(dbObject);
			_pausedVehicles[vehicleName] = _allPlayers[vehicleName];
			var spawnIndex:int = ArenaFactory.instance.getSpawnIndexByPosition(_pausedVehicles[vehicleName].spawnPosition);
			var movingCube:MovingAICube = createAICube(spawnIndex);
			_allAICubes[movingCube.name] = movingCube;
			_allPlayers[movingCube.name] = movingCube;
			
			if (_allPlayers[vehicleName] == _ownerCube) {
				_ownerCube.removeAllUserInputs();
				_stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				_stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			}
			_allPlayers[vehicleName].body.removeEventListener(AWPEvent.COLLISION_ADDED, collisionDetectionHandler);
			_allPlayers[vehicleName].mesh.removeEventListener(Object3DEvent.POSITION_CHANGED, onCubeChanged);
			_allPlayers[vehicleName].mesh.removeEventListener(Object3DEvent.ROTATION_CHANGED, onCubeChanged);
			_allPlayers[vehicleName].mesh.material.alpha = 0.25;
			_physicsWorld.removeRigidBody(_allPlayers[vehicleName].body);
			delete _allPlayers[vehicleName];
			UISignals.SHOW_STATS.dispatch(_stats);
		}
		
		private function onPowerUpRefill(cube:MovingCube):void {
			if (cube == _ownerCube) {
				cube.powerupRefill++;
				if (cube.powerupRefill > GameData.POWERUP_FULL) {
					cube.powerupRefill = GameData.POWERUP_FULL;
				}
				UISignals.OWNER_POWERUP_FILL.dispatch(cube.powerupRefill);
			}else if(cube is MovingAICube && _AIMaster){
				cube.powerupRefill++;
				if (cube.powerupRefill > GameData.POWERUP_FULL) {
					cube.powerupRefill = GameData.POWERUP_FULL;
					triggerExplosion(cube);
					cube.powerupRefill = 0;
				}
			}
		}
		
		private function onPowerUpTriggered(mess:PowerUpMessage):void {
			if (mess.triggerdBy != _ownerCube.name) {
				switch(mess.powerUpId) {
					case GameData.POWERUP_EXPLOSION:
						_allPlayers[mess.triggerdBy].setExplosionState();
						for each(var eData:ExplosionData in mess.targets) {
							var cube:MovingCube = _allPlayers[eData.target];
							cube.body.applyCentralImpulse(eData.impulse);
						}
						break;
					case GameData.POWERUP_INVISIBILITY:
						_allPlayers[mess.triggerdBy].setInvisibilityState(0.05);
						break;
				}
				
			}
		}
		
		private function onUserFelt(cube:MovingCube):void {
			cube.totalEnergy = 0;	
			if (cube == _ownerCube) {
				_stats.current_num_felt++;
				UISignals.OWNER_FELT.dispatch();
			}
			setTimeout(respawn, 2000, cube);
		}
		
		private function respawn(cube:MovingCube):void {
			if(cube == _ownerCube)
				UISignals.OWNER_RESPAWNED.dispatch();
			cube.hasCollided = false;
			cube.totalEnergy = GameData.VEHICLE_MAX_ENERGY;
			cube.body.angularVelocity = new Vector3D();
			cube.body.linearVelocity = new Vector3D();
			if(!(cube is MovingAICube)){
				cube.body.linearDamping = 0.98;
				cube.body.angularDamping = 0.98;
			}
			cube.hasFelt = false;
			cube.body.position = cube.spawnPosition;
			cube.mesh.lookAt( new Vector3D(0, 50, 0));
			cube.body.rotation = new Vector3D(0,cube.mesh.rotationY,0);
		}
		
		private function onCubeCollision(manifold:CollisionManifold):void {
			var cubeA:MovingCube = _allPlayers[manifold.colliderA];
			var cubeB:MovingCube = _allPlayers[manifold.colliderB];
			var loser:MovingCube = manifold.forceA > manifold.forceB ? cubeB : cubeA;
			var winner:MovingCube = manifold.forceA > manifold.forceB ? cubeA : cubeB;
			var remove:Number = (cubeA == loser) ? manifold.forceB : manifold.forceA;
				loser.totalEnergy -= remove;
				if (loser.totalEnergy < 0) {
					loser.totalEnergy = 0;
				}
			if (loser == _ownerCube || loser is MovingAICube) {
				
				if (loser.totalEnergy >= 0)
					if (loser == _ownerCube) {
						_stats.current_num_hits_received++;
						UISignals.ENERGY_UPDATE.dispatch(_ownerCube.totalEnergy / GameData.VEHICLE_MAX_ENERGY);
					}
				if (loser.totalEnergy == 0) {
					if (loser == _ownerCube) {
						_stats.current_num_kills_received++;
						UISignals.ENERGY_OUT.dispatch();
					}
					setTimeout(respawn, GameData.VEHICLE_RESPAWN_TIME, loser);
				}				
			}
			if (winner == _ownerCube) {
				_stats.current_max_speed = Math.max(_stats.current_max_speed,winner.linearVelocityBeforeCollision.length );
				_stats.current_num_hits_inflicted++;
				if (loser.totalEnergy == 0)
					_stats.current_num_kills_inflicted++;
			}

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
			var force:Number = (elapsed * GameData.VEHICLE_LIN_VELOCITY) / 1000;
			var torque:Number = (elapsed * GameData.VEHICLE_ANG_VELOCITY) / 1000;
			var moveX:Number = 0;
			var moveZ:Number = 0;			
				
			for each(var cube:MovingCube in _allPlayers) {
				if (cube.totalEnergy > 0){
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
		}	
		
		public function getElapsedTime():Number {
			var t:int = getTimer();
			var dt:Number = (t - _currentTime);
			_currentTime = t;
			_totalGameTime += dt;
			return dt;
		}
		
		public function render():void {
			if (_ownerCube){
				CameraManager.instance.updateCamera(_ownerCube.mesh.transform.clone(), _ownerCube.mesh.position.clone());
				if(_totalGameTime < GameData.GAME_SESSION_DURATION){
					UISignals.UPDATE_GAME_TIMER.dispatch(_totalGameTime);
				}else {
					if (!_endSession) {
						GameSignals.SESSION_PAUSE.dispatch(_stats);
						_endSession = true;
					}
				}
			}
			var dt:Number = getElapsedTime();
			moveObjects(dt);
			ParticlesFactory.instance.checkRemoveParticles();
			setLastVelocity();
			setAIBehavior();			
			
			_physicsWorld.step(dt / 1000, 5, _timeStep);	
			
			_view3D.render();
			
			//_debugDraw.debugDrawWorld();
		}
		
		private function getClosestTarget(aiCube:MovingCube):MovingCube {
			var distanceTmp:Number = Number.MAX_VALUE;
			var position:Vector3D = aiCube.body.position;
			var closest:MovingCube;
			for each(var user:MovingCube in _allPlayers) {
				if(user!=aiCube && !user.isInvisible){
					var dist:Number = Vector3D.distance(user.body.position, position);
					var min:Number = Math.min(distanceTmp, dist);
					if (min == dist) {
						closest = user;
						distanceTmp = dist;
					}					
				}
			}
			return closest;
		}
		
		private function chaseTarget(chaser:MovingAICube, target:MovingCube):void {
			if (target) {				
				var a:Number = target.body.position.z - chaser.body.z;
				var b:Number = target.body.position.x - chaser.body.x;
				var rads:Number = Math.atan2(a, b);
				chaser.body.rotation = new Vector3D(0, -(rads * 180 / Math.PI) + 90, 0);
				var f:Vector3D = chaser.body.front;
				f.scaleBy(10);
				chaser.body.applyCentralForce(f);		
			}
		}
		
		private function setAIBehavior():void {
			for each(var AICube:MovingAICube in _allAICubes) 
				chaseTarget(AICube, getClosestTarget(AICube));
		}
		
		private function setLastVelocity():void
		{
			for each(var cube:MovingCube in _allPlayers) {
				cube.linearVelocityBeforeCollision = cube.body.linearVelocity.clone();
			}
		}
		
		private function triggerInvisibility(pCube:MovingCube):void {
			pCube.setInvisibilityState(0.25);
			var message:PowerUpMessage = new PowerUpMessage();
			message.triggerdBy = pCube.name;
			message.powerUpId = GameData.POWERUP_INVISIBILITY;
			UserInputSignals.POWERUP_TRIGGER.dispatch(message);
		}
		
		private function triggerExplosion(pCube:MovingCube):void {
			pCube.setExplosionState();
			var message:PowerUpMessage = new PowerUpMessage();
			message.triggerdBy = pCube.name;
			message.powerUpId = GameData.POWERUP_EXPLOSION;
			var radius:Number = 1000;
			var maxForce:Number = 100;
			for each(var cube:MovingCube in _allPlayers) {
				if (cube != pCube)
				var dist:Number = Vector3D.distance(pCube.body.position, cube.body.position);
				if (dist <= radius) {
					var data:ExplosionData = new ExplosionData();
					data.target = cube.name;
					var force:Number = ((radius - dist) * maxForce / radius);
					var forceVector:Vector3D = cube.body.position.subtract(pCube.body.position)
					forceVector.normalize();
					forceVector.scaleBy(force);
					cube.body.applyCentralImpulse(forceVector);
					data.impulse = forceVector;
					message.targets.push(data);
				}
			}
			UserInputSignals.POWERUP_TRIGGER.dispatch(message);
		}
		
		private function onKeyUp(event:KeyboardEvent):void {
			var _isVehicleInput:Boolean = false;
			switch(event.keyCode) {
				case Keyboard.NUMPAD_1:
				case Keyboard.NUMBER_1:
					if(_ownerCube.powerupRefill == GameData.POWERUP_FULL){
						triggerExplosion(_ownerCube);
						_ownerCube.powerupRefill = 0;
						UISignals.OWNER_POWERUP_FILL.dispatch(_ownerCube.powerupRefill);
					}
					break;
				case Keyboard.NUMPAD_2:
				case Keyboard.NUMBER_2:
					if(_ownerCube.powerupRefill == GameData.POWERUP_FULL){
						triggerInvisibility(_ownerCube);
						_ownerCube.powerupRefill = 0;
						UISignals.OWNER_POWERUP_FILL.dispatch(_ownerCube.powerupRefill);
					}
					break;
				case Keyboard.TAB:
					_propsMenu.visible = !_propsMenu.visible;
					break;
				case Keyboard.A:
				case Keyboard.LEFT:
					_isVehicleInput = true;
					leftPressed = false;
					break;
				case Keyboard.D:
				case Keyboard.RIGHT:
					_isVehicleInput = true;
					rightPressed = false;
					break;
				case Keyboard.W:
				case Keyboard.UP:
					_isVehicleInput = true;
					upPressed = false;
					break;
				case Keyboard.S:
				case Keyboard.DOWN:
					_isVehicleInput = true;
					downPressed = false;
					break;
			}
			if(_isVehicleInput){
				_ownerCube.removeUserInput(event.keyCode);		
				UserInputSignals.USER_STOPPED_MOVING.dispatch(event.keyCode, new Date().getTime());
			}
		}
		private function onKeyDown(event:KeyboardEvent):void {
			_sendMoveMessage = false;
			switch(event.keyCode) {

				case Keyboard.A:
				case Keyboard.LEFT:
					if (leftPressed == false)
						_sendMoveMessage = true;
					leftPressed = true;
					break;
				case Keyboard.D:
				case Keyboard.RIGHT:
					if (rightPressed == false)
						_sendMoveMessage = true;
					rightPressed = true;
					break;
				case Keyboard.W:
				case Keyboard.UP:
					if (upPressed == false)
						_sendMoveMessage = true;
					upPressed = true;
					break;
				case Keyboard.S:
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
			
			var force:Number = (elapsed * GameData.VEHICLE_LIN_VELOCITY) / 1000;
			var moveZ:Number = 0;
			
			switch(keyCode) {
				case Keyboard.A:
				case Keyboard.D:
				case Keyboard.LEFT:
				case Keyboard.RIGHT:
					cube.body.angularDamping = 0.98;
					break;
				case Keyboard.W:
				case Keyboard.UP:
					moveZ = -force;
					cube.body.linearDamping = 0.98;
					break;
				case Keyboard.S:
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
			
			var force:Number = (elapsed * GameData.VEHICLE_LIN_VELOCITY) / 1000;
			var torque:Number = (elapsed * GameData.VEHICLE_ANG_VELOCITY) / 1000;		
			
			var moveX:Number = 0;
			var moveZ:Number = 0;
			if (keyCode == Keyboard.LEFT || keyCode == Keyboard.A) {
				moveX = -torque;
				cube.body.angularDamping = 0;
			}else if (keyCode == Keyboard.RIGHT || keyCode == Keyboard.D) {
				moveX = torque;
				cube.body.angularDamping = 0;
			}			
			if (keyCode == Keyboard.UP || keyCode == Keyboard.W) {
				cube.body.linearDamping = 0;
				moveZ = force;
			}else if (keyCode == Keyboard.DOWN || keyCode == Keyboard.S) {
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
					cube.body.angularVelocity = new Vector3D(0,moveX,0);
				}
				cube.addUserInput(keyCode);		
			}
		}
		
		private function onUserRemoved(userId:String, userIndex:int):void {
			var movingCube:MovingAICube = createAICube(userIndex);
			_allAICubes[movingCube.name] = movingCube;
			_allPlayers[movingCube.name] = movingCube;
			if (_allPlayers[userId] == _ownerCube) {
				_stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				_stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			}
			_allPlayers[userId].body.removeEventListener(AWPEvent.COLLISION_ADDED, collisionDetectionHandler);
			_allPlayers[userId].mesh.removeEventListener(Object3DEvent.POSITION_CHANGED, onCubeChanged);
			_allPlayers[userId].mesh.removeEventListener(Object3DEvent.ROTATION_CHANGED, onCubeChanged);
			_view3D.scene.removeChild(_allPlayers[userId].mesh);
			_physicsWorld.removeRigidBody(_allPlayers[userId].body);
			delete _allPlayers[userId];
		}
		
		private function createAICube(index:int):MovingAICube {
			var movingCube:MovingAICube = new MovingAICube("ai_"+(index.toString()), false, _cubemap);
			if (_AIMaster)
				movingCube.body.addEventListener(AWPEvent.COLLISION_ADDED, collisionDetectionHandler);
			movingCube.spawnPosition = ArenaFactory.instance.getSpawnPoint(index);
			_view3D.scene.addChild(movingCube.mesh);
			_physicsWorld.addRigidBody(movingCube.body);
			movingCube.body.position = movingCube.spawnPosition;
			return movingCube;
		}
		
		private function createAICubes():void {
			var numAICubes:uint = ArenaFactory.instance.getAvailableSlots();
			for (var i:uint = Connector.MAX_USER_PER_ROOM - numAICubes ; i < Connector.MAX_USER_PER_ROOM; i++) {
				var movingCube:MovingAICube = createAICube(i);
				_allPlayers[movingCube.name] = movingCube;
				_allAICubes[movingCube.name] = movingCube;
			}			
		}
		
		private function createMovingCube(name:String, isOwner:Boolean, spawnPointIndex:int, lightRigidBody:LightRigidBody = null):MovingCube {
			var movingCube:MovingCube = new MovingCube(name, isOwner, _cubemap);			
			_view3D.scene.addChild(movingCube.mesh);
			_physicsWorld.addRigidBody(movingCube.body);			
			trace("created", movingCube.name);
			if (isOwner) {
				
				_totalGameTime = 0;
				if (spawnPointIndex == 0)
					_AIMaster = true;
				_ownerCube = movingCube;
				_stats = new GameStats(_ownerCube.name);
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
		
		//private function onUserCreated(dataObject:Object):void {
		private function onUserCreated(user:GameUserVO):void {
			trace("GameUserVO", user.uid, user.xp, user.igc )
			if (user.isMainUser)
				UISignals.UPDATE_USER_INFO.dispatch(user.igc, user.xp);
				
			_allPlayers[user.uid] = createMovingCube(user.uid, user.isMainUser, user.spawnIndex);			
			var aiCube:MovingAICube = _allAICubes["ai_" + user.spawnIndex];
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
			if (event.collisionObject.skin.name == "main2")
				return;				
				
			var cubeCollider:MovingCube = event.collisionObject.skin.extra as MovingCube;
			var targetCube:MovingCube = event.currentTarget.skin.extra as MovingCube
			if (cubeCollider == null || targetCube == null)
				return;
			if (cubeCollider!=null && targetCube!=null)
			{
				if (!targetCube.hasCollided && !cubeCollider.hasCollided) {
					var manifold:CollisionManifold = new CollisionManifold();
					manifold.colliderA = cubeCollider.name;
					manifold.colliderB = targetCube.name;
					manifold.positionA = event.manifoldPoint.localPointA;
					manifold.positionB = event.manifoldPoint.localPointB;
					manifold.forceA = cubeCollider.linearVelocityBeforeCollision.length;
					manifold.forceB = targetCube.linearVelocityBeforeCollision.length;
					UserInputSignals.USER_IS_COLLIDING.dispatch(manifold);
					targetCube.hasCollided = true;
					cubeCollider.hasCollided = true;
				}
			}
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