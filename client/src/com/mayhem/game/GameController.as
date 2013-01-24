package com.mayhem.game 
{
	import away3d.containers.View3D;
	import away3d.events.Object3DEvent;
	import away3d.materials.methods.OutlineMethod;
	import away3d.primitives.SkyBox;
	import away3d.textures.BitmapCubeTexture;
	import awayphysics.debug.AWPDebugDraw;
	import awayphysics.dynamics.AWPDynamicsWorld;
	import awayphysics.events.AWPEvent;
	import com.mayhem.game.powerups.PowerUpMessage;
	import com.mayhem.multiplayer.GameUserVO;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import playerio.DatabaseObject;	
	import flash.utils.getTimer;
	import com.mayhem.multiplayer.Connector;
	import flash.geom.Vector3D;
	import com.mayhem.signals.*;	
	import away3d.materials.TextureMaterial;
	import com.mayhem.game.powerups.ExplosionData;	
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author availlant
	 */
	public class GameController 
	{
		
		public static var MOVE_LEFT_KEY:uint = 0;
		public static var MOVE_RIGHT_KEY:uint = 1;
		public static var MOVE_UP_KEY:uint = 2;
		public static var MOVE_DOWN_KEY:uint = 3;
		
		private var downPressed:Boolean = false;
		private var upPressed:Boolean = false;
		private var rightPressed:Boolean = false;
		private var leftPressed:Boolean = false;
		
		private var _allPlayers:Dictionary;
		private var _ownerCube:MovingCube;	
		private var _sendMoveMessage:Boolean = true;
		
		private var _updateTimer:Timer;
		private var _currentTime:Number;		
		
		private var _allAICubes:Dictionary;
		
		private var _AIMaster:Boolean = false;
		
		private var _propsMenu:VehiclePropertiesMenu;
		
		private var _totalGameTime:uint = 0;
		
		private var _endSession:Boolean = false;
		
		private var _pausedVehicles:Dictionary = new Dictionary();		
		
		private var _cubemap:BitmapCubeTexture;
		
		private var _debugDraw:AWPDebugDraw;
		
		private var _physicsWorld:AWPDynamicsWorld;
		
		private var _timeStep : Number = 1.0 / 60;	
		
		private var _stats:GameStats;
		
		private var _view3D:View3D;
		
		private var _stage:Stage;
		
		private var _AIController:AIController;
		
		private var doDebugDraw:Boolean = false;
		
		public function GameController(pStage:Stage, view:View3D) 
		{
			_view3D = view;
			_stage = pStage;
			_allPlayers = new Dictionary();			
			_allAICubes = new Dictionary();			
			setUpdateTimer();
			setSkybox();
			setPhysics();
			setSignals();	
			pStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			pStage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			ArenaFactory.instance.initialize(_physicsWorld);
			view.scene.addChild(ArenaFactory.instance.getDefaultArena());
			_propsMenu = new VehiclePropertiesMenu(pStage, this, new Point(0,150));
		}	
		
		public function getElapsedTime():Number {
			var t:int = getTimer();
			var dt:Number = (t - _currentTime);
			_currentTime = t;
			_totalGameTime += dt;
			return dt;
		}
		
		public function renderGame():void {
			if (_ownerCube){
				if (_ownerCube.enableBehavior) {
					CameraManager.instance.updateCamera(_ownerCube.mesh.transform.clone(), _ownerCube.mesh.position.clone());
				}else {
					CameraManager.instance.setIntroPosition(_ownerCube.mesh.transform.clone(), _ownerCube.mesh.position.clone());
				}
				
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
			for each(var vehicle:MovingCube in _allPlayers){
				vehicle.isInContactWithGound = false;
			}
			_physicsWorld.step(dt / 1000, 1, _timeStep);			
			
			if (doDebugDraw)
				_debugDraw.debugDrawWorld();
		}
		
		public function checkVehicleCollision():void {
			for each(var vehicle:MovingCube in _allPlayers){
				if (vehicle == _ownerCube || vehicle is MovingAICube) {
					if (!vehicle.isInContactWithGound) {
						vehicle.body.linearDamping = 0;
						vehicle.body.angularDamping = 0;
						vehicle.body.mass = 5;
						vehicle.body.gravity = new Vector3D(0,-500,0);
					}else {
						vehicle.body.linearDamping = GameData.LIN_DAMPING;
						vehicle.body.angularDamping = GameData.ANG_DAMPING;
						vehicle.body.gravity = new Vector3D(0,GameData.VEHICLE_GRAVITY,0);
						vehicle.body.mass = 1;
					}
				}
			}
		}
		
		private function setPhysics():void{			
			_physicsWorld = AWPDynamicsWorld.getInstance();					
			_physicsWorld.initWithDbvtBroadphase();
			_physicsWorld.collisionCallbackOn = true;	
			_debugDraw = new AWPDebugDraw(_view3D, _physicsWorld);
			//_debugDraw.debugMode |= AWPDebugDraw.DBG_DrawRay;
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
			MultiplayerSignals.AI_TARGET_UPDATED.add(onAITargetUpdate);
			GameSignals.SET_AI_TARGET.add(setAITarget);
			GameSignals.DANGER_ZONE_COLLISION.add(onDangerZone);
		}
		
		private function onDangerZone(vehicle:MovingCube):void {
			vehicle.totalEnergy--;
			if (vehicle.totalEnergy < 0) {
				vehicle.totalEnergy = 0;
			}
			if (vehicle == _ownerCube || vehicle is MovingAICube) {
				if (vehicle.totalEnergy >= 0)
					if (vehicle == _ownerCube) {
						_stats.current_num_hits_received++;
						UISignals.ENERGY_UPDATE.dispatch(vehicle.totalEnergy / GameData.VEHICLE_MAX_ENERGY);
					}
				if (vehicle.totalEnergy == 0) {
					setVehicleDeath(vehicle);					
				}				
			}
			//var outline:OutlineMethod = new OutlineMethod(0x00cc00, 10);
			//TextureMaterial(vehicle.mesh.material).addMethod(outline)
		}
		
		private function onAITargetUpdate(chaser_id:String, target_id:String):void {
			_allAICubes[chaser_id].currentTarget = _allPlayers[target_id];
		}
		
		private function replaceUserByAIVehicle(dbObject:DatabaseObject):void {
			var vehicleName:String = dbObject.key;
			_stats.updateWithAllTimeData(dbObject);
			_pausedVehicles[vehicleName] = _allPlayers[vehicleName];
			var spawnIndex:int = _pausedVehicles[vehicleName].spawnIndex;
			var movingCube:MovingAICube = createAICube(spawnIndex);
			respawn(movingCube);
			_allAICubes[movingCube.name] = movingCube;
			_allPlayers[movingCube.name] = movingCube;
			
			if (_allPlayers[vehicleName] == _ownerCube) {
				_ownerCube.removeAllUserInputs();
				_stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				_stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
				_allPlayers[vehicleName].body.removeEventListener(AWPEvent.COLLISION_ADDED, collisionDetectionHandler);
				_allPlayers[vehicleName].mesh.removeEventListener(Object3DEvent.POSITION_CHANGED, onCubeChanged);
				_allPlayers[vehicleName].mesh.removeEventListener(Object3DEvent.ROTATION_CHANGED, onCubeChanged);
				//_allPlayers[vehicleName].mesh.material.alpha = 0.25;
				UISignals.SHOW_STATS.dispatch(_stats);
			}
			
			_view3D.scene.removeChild(_allPlayers[vehicleName].mesh);
			_physicsWorld.removeRigidBody(_allPlayers[vehicleName].body);
			delete _allPlayers[vehicleName];
			
		}
		
		private function onAIUpdateState(v:Vector.<Object>):void {
			if(!_AIMaster){
				for each(var obj:Object in v) {
					var aiCube:MovingAICube = _allAICubes["ai_" + obj.index.toString()];
					updateCube(aiCube,obj.body);
				}
			}
		}
		
		public function createAICube(index:int):MovingAICube {
			var aiUser:GameUserVO = new GameUserVO("ai_" + (index.toString()));
			aiUser.spawnIndex = index;
			var movingCube:MovingAICube = new MovingAICube(aiUser,getChaser());
			if (_AIMaster)
				movingCube.body.addEventListener(AWPEvent.COLLISION_ADDED, collisionDetectionHandler);
			movingCube.spawnPosition = ArenaFactory.instance.getSpawnPoint(index);
			return movingCube;
		}
		
		
		private function setAITarget(vehicle:MovingAICube):void {
			vehicle.currentTarget = getRandomAITarget(vehicle);
		}
		
		private function getRandomAITarget(aiCube:MovingAICube):MovingCube {
			var vehicle:MovingCube;
			var arr_targets:Vector.<MovingCube> = new Vector.<MovingCube>();
			for each(var user:MovingCube in _allPlayers) {
				if (user != aiCube.currentTarget && user !=aiCube && user.enableBehavior) {
					arr_targets.push(user);
				}				
			}
			if(arr_targets.length != 0){
				var rnd:uint = Math.floor(Math.random() * arr_targets.length);
				MultiplayerSignals.UPDATE_AI_TARGET.dispatch(aiCube.name, arr_targets[rnd].name);
				return arr_targets[rnd];
			}
			return vehicle;;
		}
		
		
		private function chaseTarget(chaser:MovingAICube, target:MovingCube):void {
			if (target) {				
				var a:Number = target.body.position.z - chaser.body.z;
				var b:Number = target.body.position.x - chaser.body.x;
				var rads:Number = Math.atan2(a, b);
				var f:Vector3D;
				var force:Number = 250 + (Math.random() * 50);
				var rotationY:Number = (rads * 180 / Math.PI);
				chaser.body.rotation = new Vector3D(0, -rotationY + 90, 0);
				f = chaser.body.front;
				f.scaleBy(force);
				chaser.body.applyCentralForce(f);
			}
		}
		
		private function setAIBehavior():void {
			for each(var AICube:MovingAICube in _allAICubes) 
				if(AICube.enableBehavior)chaseTarget(AICube, AICube.currentTarget);
		}
		
		private function setUpdateTimer():void{			
			_currentTime = getTimer();					
			_updateTimer = new Timer(200);
			_updateTimer.addEventListener(TimerEvent.TIMER, updatePosition);
		}
		
		private function setSkybox():void {
			_cubemap = ModelsManager.instance.getSkyboxTexture();
			var sky:SkyBox = new SkyBox(_cubemap);
			_view3D.scene.addChild(sky);
		}
		
		public function getOwnerVehicle():MovingCube {
			return _ownerCube;
		}
		
		/*private function hitFX():void{
			trace("hitFX in action.");
		}*/
		
		private function onKeyUp(event:KeyboardEvent):void {
			var _isVehicleInput:Boolean = false;
			switch(event.keyCode) {
				case Keyboard.D:
					doDebugDraw = !doDebugDraw;
					break;
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
		
		
		private function restartSession(vehicleName:String):void {
			var pausedVehicle:MovingCube = _pausedVehicles[vehicleName];
			var aiVehicle:MovingAICube = _allAICubes["ai_" + pausedVehicle.spawnIndex.toString()];
			_physicsWorld.removeRigidBody(aiVehicle.body);
			_view3D.scene.removeChild(aiVehicle.mesh);
			delete _allAICubes["ai_" + pausedVehicle.spawnIndex.toString()];
			delete _allPlayers["ai_" + pausedVehicle.spawnIndex.toString()];
			_allPlayers[vehicleName] = pausedVehicle;
			
			if (pausedVehicle == _ownerCube) {
				_stats = new GameStats(_ownerCube.name);
				_stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				_stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
				pausedVehicle.body.addEventListener(AWPEvent.COLLISION_ADDED, collisionDetectionHandler);
				pausedVehicle.mesh.addEventListener(Object3DEvent.POSITION_CHANGED, onCubeChanged);
				pausedVehicle.mesh.addEventListener(Object3DEvent.ROTATION_CHANGED, onCubeChanged);
				UISignals.REMOVE_STATS.dispatch();
				_totalGameTime = 0;
				_endSession = false;
			}
			
			respawn(pausedVehicle);
			
			delete _pausedVehicles[vehicleName];
		}
		
		private function sendRestart():void
		{
			var index:int = ArenaFactory.instance.getSpawnIndexByPosition(_ownerCube.spawnPosition);
			GameSignals.SESSION_RESTART.dispatch(_ownerCube.name, index);
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
			if (cube == _ownerCube) {
				UISignals.OWNER_RESPAWNED.dispatch();
			}
			GameSignals.OPEN_DOOR.dispatch(cube.spawnIndex);
			_physicsWorld.addRigidBody(cube.body);
			_view3D.scene.addChild(cube.mesh);
			cube.hasCollided = false;
			cube.totalEnergy = GameData.VEHICLE_MAX_ENERGY;
			cube.body.angularVelocity = new Vector3D();
			cube.body.linearVelocity = new Vector3D();
			cube.body.linearDamping = GameData.LIN_DAMPING;
			cube.body.angularDamping = GameData.ANG_DAMPING;
			cube.hasFelt = false;
			cube.body.position = cube.spawnPosition;
			cube.mesh.lookAt( new Vector3D(0, 50, 0));
			cube.body.rotation = new Vector3D(0, cube.mesh.rotationY, 0);
			var front:Vector3D = cube.body.front.clone();
			front.scaleBy(600);
			var pos:Vector3D = cube.spawnPosition.clone();
			pos = front.add(pos)
			cube.body.position = pos;
			
			setCountDown(cube);			
		}
		
		private function setCountDown(cube:MovingCube):void {
			if (cube == _ownerCube) {
				UISignals.SHOW_COUNTDOWN.dispatch();	
			}
			setTimeout(function():void {
				var impulse:Vector3D = cube.body.front;
				impulse.scaleBy(500);
				cube.body.applyImpulse(impulse,new Vector3D(0,0,0));
			}, 3000);
		}
		
		private function setVehicleDeath(deadVehicle:MovingCube):void {
			deadVehicle.enableBehavior = false;
			setTimeout(respawn, GameData.VEHICLE_RESPAWN_TIME, deadVehicle);
			_physicsWorld.removeRigidBody(deadVehicle.body);
			_view3D.scene.removeChild(deadVehicle.mesh);
			ParticlesFactory.instance.getDeathParticles(deadVehicle.body.position.clone());
			if (deadVehicle == _ownerCube) {
				_stats.current_num_kills_received++;	
				UISignals.ENERGY_OUT.dispatch();
			}
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
					setVehicleDeath(loser);
					
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
				loser.hasCollided = false;
			},200);
			
			loser.setImpactState(collisionPosition);
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
			var radius:Number = 2001;
			var maxForce:Number = GameData.EXPLOSION_FORCE;
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
		
		
		
		private function onUserStoppedMoving(userId:String, keyCode:uint, timestamp:Number):void {
			
			//var cube:MovingCube = _allPlayers[userId];
			//var elapsed:Number = timestamp - new Date().getTime();
			//
			//var force:Number = (elapsed * GameData.VEHICLE_LIN_VELOCITY) / 1000;
			//var moveZ:Number = 0;
			//
			//switch(keyCode) {
				//
				//case Keyboard.W:
				//case Keyboard.UP:
					//moveZ = -force;
					//break;
				//case Keyboard.S:
				//case Keyboard.DOWN:
					//moveZ = force;
					//break;
			//}
			//if (cube != _ownerCube){
				//if (moveZ != 0) {
					//var f:Vector3D = cube.body.front;
					//f.scaleBy(moveZ);	
					//cube.body.applyCentralForce(f)
				//}
				//cube.removeUserInput(keyCode);
			//}
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
			}else if (keyCode == Keyboard.RIGHT || keyCode == Keyboard.D) {
				moveX = torque;
			}			
			if (keyCode == Keyboard.UP || keyCode == Keyboard.W) {
				moveZ = force;
			}else if (keyCode == Keyboard.DOWN || keyCode == Keyboard.S) {
				moveZ = -force;
			}
			if (cube != _ownerCube){
				if (moveZ != 0) {
					var f:Vector3D = cube.body.front;
					f.scaleBy(moveZ);	
					if(cube.body)cube.body.applyCentralForce(f);
				}
				if (moveX != 0) {
					if(cube.body)cube.body.angularVelocity = new Vector3D(0,moveX,0);
				}
				cube.addUserInput(keyCode);		
			}
		}
		
		private function onUserRemoved(userId:String, userIndex:int):void {
			var movingCube:MovingAICube = createAICube(userIndex);
			respawn(movingCube);
			_allAICubes[movingCube.name] = movingCube;
			_allPlayers[movingCube.name] = movingCube;
			if (_allPlayers[userId] == _ownerCube) {
				_stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				_stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			}
			if(_allPlayers[userId].body)_allPlayers[userId].body.removeEventListener(AWPEvent.COLLISION_ADDED, collisionDetectionHandler);
			if(_allPlayers[userId].mesh)_allPlayers[userId].mesh.removeEventListener(Object3DEvent.POSITION_CHANGED, onCubeChanged);
			if(_allPlayers[userId].mesh)_allPlayers[userId].mesh.removeEventListener(Object3DEvent.ROTATION_CHANGED, onCubeChanged);
			if(_allPlayers[userId].mesh)_view3D.scene.removeChild(_allPlayers[userId].mesh);
			if(_allPlayers[userId].body)_physicsWorld.removeRigidBody(_allPlayers[userId].body);
			delete _allPlayers[userId];
		}
		
		private function getChaser():Boolean {
			var numAIVehicles:uint = 0;
			for each(var vehicle:MovingAICube in _allAICubes) {
				numAIVehicles++;
			}
			return numAIVehicles % 2 == 0;
		}
		
		private function createAICubes():void {
			var numAICubes:uint = ArenaFactory.instance.getAvailableSlots();
			for (var i:uint = Connector.MAX_USER_PER_ROOM - numAICubes ; i < Connector.MAX_USER_PER_ROOM; i++) {
				var movingCube:MovingAICube = createAICube(i);
				respawn(movingCube);
				_allPlayers[movingCube.name] = movingCube;
				_allAICubes[movingCube.name] = movingCube;
			}		
		}
		
		private function createMovingCube(user:GameUserVO, lightRigidBody:LightRigidBody = null):MovingCube {
			var movingCube:MovingCube = new MovingCube(user);			
			//_view3D.scene.addChild(movingCube.mesh);
			//_physicsWorld.addRigidBody(movingCube.body);			
			trace("created", movingCube.name);
			if (user.isMainUser) {
				
				_totalGameTime = 0;
				if (user.spawnIndex == 0)
					_AIMaster = true;
				_ownerCube = movingCube;
				_stats = new GameStats(_ownerCube.name);
				_ownerCube.spawnPosition = ArenaFactory.instance.getSpawnPoint(user.spawnIndex);
				_ownerCube.body.addEventListener(AWPEvent.COLLISION_ADDED, collisionDetectionHandler);
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
			_allPlayers[dataObject.user.uid] = createMovingCube(dataObject.user, dataObject.rigidBody);
			respawn(_allPlayers[dataObject.user.uid]);
		}
		
		private function onUserCreated(user:GameUserVO):void {
			trace("GameUserVO", user.uid, user.xp, user.igc )
			if (user.isMainUser)
				UISignals.UPDATE_USER_INFO.dispatch(user.igc, user.xp);
				
			_allPlayers[user.uid] = createMovingCube(user);			
			var aiCube:MovingAICube = _allAICubes["ai_" + user.spawnIndex];
			respawn(_allPlayers[user.uid]);
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
					
					var subs:Vector3D = targetCube.body.position.subtract(cubeCollider.body.position);
					subs.negate();
					subs.normalize();
					subs.y = 0;
					var max1:Number = manifold.forceB * 3 > 300 ? 300 : manifold.forceB * 3;
					subs.scaleBy(max1);
					cubeCollider.body.applyCentralImpulse(subs);
					
					var subs2:Vector3D = cubeCollider.body.position.subtract(targetCube.body.position);
					subs2.negate();
					subs2.normalize();
					subs2.y = 0;
					var max2:Number = manifold.forceA * 3 > 300 ? 300 : manifold.forceA * 3;
					subs2.scaleBy(max2);
					targetCube.body.applyCentralImpulse(subs2);
					
					UserInputSignals.USER_IS_COLLIDING.dispatch(manifold);
					targetCube.hasCollided = true;
					cubeCollider.hasCollided = true;
					if (_AIMaster){
						if (cubeCollider is MovingAICube)
							MovingAICube(cubeCollider).currentTarget = getRandomAITarget(MovingAICube(cubeCollider));
						if (targetCube is MovingAICube)
							MovingAICube(targetCube).currentTarget = getRandomAITarget(MovingAICube(targetCube));
					}
				}
			}
		}		
		
		private function onCubeChanged(event:Object3DEvent):void {
			if (!_updateTimer.running)
				_updateTimer.start();
		}	
	}

}