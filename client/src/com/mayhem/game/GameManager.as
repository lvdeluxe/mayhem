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
		
		private var _debugCubes:Boolean = false;
		private var _debugContainer:Sprite;
		
	
		public function GameManager(stage:Stage, proxy:Stage3DProxy) 
		{
			_allPlayers = new Dictionary();			
			_allAICubes = new Dictionary();			
			setUpdateTimer();
			setView(stage,proxy);
			setLights();
			setPhysics();
			setSignals();			
			MaterialsFactory.initialize([_light]);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			var stats:AwayStats = new AwayStats(_view3D)
			stage.addChild(stats);
			ArenaFactory.instance.initialize(_physicsWorld);
			ParticlesFactory.instance.initialize(_view3D.scene);
			CameraManager.instance.initialize(_view3D.camera);
			_view3D.scene.addChild(ArenaFactory.instance.getDefaultArena());
			setDebugCubes(stage, stats.height);
		}
		
		private function onSlideFriction(e:Event):void {
			var slider:HUISlider = e.currentTarget as HUISlider;
			_ownerCube.body.friction = slider.value
		}
		private function onSlideRestitution(e:Event):void {
			var slider:HUISlider = e.currentTarget as HUISlider;
			_ownerCube.body.restitution = slider.value
		}
		private function onSlideMass(e:Event):void {
			var slider:HUISlider = e.currentTarget as HUISlider;
			_ownerCube.body.mass = slider.value
		}
		private function onSlideAngSpeed(e:Event):void {
			var slider:HUISlider = e.currentTarget as HUISlider;
			MovingCube.MAX_ROTATION = slider.value;
		}
		private function onSlideLinSpeed(e:Event):void {
			var slider:HUISlider = e.currentTarget as HUISlider;
			MovingCube.MAX_VELOCITY = slider.value;
		}
		private function onSlideGravity(e:Event):void {
			var slider:HUISlider = e.currentTarget as HUISlider;
			_ownerCube.body.gravity = new Vector3D(0, slider.value, 0);
		}
		private function onSlideAngular(e:Event):void {
			var slider:HUISlider = e.currentTarget as HUISlider;
			_ownerCube.body.angularFactor = new Vector3D(slider.value, 1, slider.value);
		}
		private function onSlideLinear(e:Event):void {
			var slider:HUISlider = e.currentTarget as HUISlider;
			_ownerCube.body.linearFactor = new Vector3D(slider.value, 1, slider.value);
		}
		
		private function setDebugCubes(stage:Stage, x:Number):void {
			_debugContainer = new Sprite();
			_debugContainer.y = x + 10
			var sliderFriction:HUISlider = new HUISlider(_debugContainer, 10, 10, 'friction', onSlideFriction);
			sliderFriction.minimum = 0;
			sliderFriction.maximum = 1;
			sliderFriction.value = 0.1;
			var sliderGravity:HUISlider = new HUISlider(_debugContainer, 10, 22, 'gravity', onSlideGravity);
			sliderGravity.minimum = 0;
			sliderGravity.maximum = -100;
			sliderGravity.value = -1;
			var sliderRestitution:HUISlider = new HUISlider(_debugContainer, 10, 34, 'restitution', onSlideRestitution);
			sliderRestitution.minimum = 0;
			sliderRestitution.maximum = 10;
			sliderRestitution.value = 0.1;
			var sliderAngularFactor:HUISlider = new HUISlider(_debugContainer, 10, 46, 'angular F', onSlideAngular);
			sliderAngularFactor.minimum = 0;
			sliderAngularFactor.maximum = 1;
			sliderAngularFactor.value = 0.25;
			var sliderMass:HUISlider = new HUISlider(_debugContainer, 10, 58, 'mass', onSlideMass);
			sliderMass.minimum = 0;
			sliderMass.maximum = 100;
			sliderMass.value = 1;
			var sliderLinearF:HUISlider = new HUISlider(_debugContainer, 10, 70, 'linear F', onSlideLinear);
			sliderLinearF.minimum = 0;
			sliderLinearF.maximum = 1;
			sliderLinearF.value = 0.25;
			var sliderAngSpeed:HUISlider = new HUISlider(_debugContainer, 10, 82, 'Angular Speed', onSlideAngSpeed);
			sliderAngSpeed.minimum = 50;
			sliderAngSpeed.maximum = 500;
			sliderAngSpeed.value = 150;
			var sliderLinSpeed:HUISlider = new HUISlider(_debugContainer, 10, 94, 'Linear Speed', onSlideLinSpeed);
			sliderLinSpeed.minimum = 50;
			sliderLinSpeed.maximum = 5000;
			sliderLinSpeed.value = 1000;
			stage.addChild(_debugContainer);			
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
			_view3D.scene.addChild(_light)
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
			MultiplayerSignals.POWERUP_TRIGGERED.add(onPowerUpTriggered)
			GameSignals.REFILL_POWERUP.add(onPowerUpRefill);
		}
		
		private function onPowerUpRefill(cube:MovingCube):void {
			if (cube == _ownerCube) {
				cube.powerupRefill++;
				if (cube.powerupRefill > MovingCube.POWERUP_FULL) {
					cube.powerupRefill = MovingCube.POWERUP_FULL;
				}
				UISignals.OWNER_POWERUP_FILL.dispatch(cube.powerupRefill);
			}else if(cube is MovingAICube && _AIMaster){
				cube.powerupRefill++;
				if (cube.powerupRefill > MovingCube.POWERUP_FULL) {
					cube.powerupRefill = MovingCube.POWERUP_FULL;
					setExplosion(cube);
				}
			}
		}
		
		private function onPowerUpTriggered(mess:PowerUpMessage):void {
			if (mess.triggerdBy != _ownerCube.name) {
				_allPlayers[mess.triggerdBy].triggerPowerUp();
				for each(var eData:ExplosionData in mess.targets) {
					var cube:MovingCube = _allPlayers[eData.target];
					cube.body.applyCentralImpulse(eData.impulse);
				}
			}
		}
		
		private function onUserFelt(cube:MovingCube):void {
			cube.totalEnergy = 0;	
			if (cube == _ownerCube)	
				UISignals.OWNER_FELT.dispatch();
			setTimeout(respawn, 2000, cube);
		}
		private function respawn(cube:MovingCube):void {
			if(cube == _ownerCube)
				UISignals.OWNER_RESPAWNED.dispatch();
			cube.hasCollided = false;
			cube.totalEnergy = MovingCube.MAX_ENERGY;
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
			if (loser == _ownerCube || loser is MovingAICube) {
				var remove:Number = (cubeA == loser) ? manifold.forceB : manifold.forceA;
				loser.totalEnergy -= remove;
				if (loser.totalEnergy < 0) {
					loser.totalEnergy = 0;
				}
				if (loser.totalEnergy >= 0)
					if (loser == _ownerCube)
						UISignals.ENERGY_UPDATE.dispatch(_ownerCube.totalEnergy / MovingCube.MAX_ENERGY);
				if (loser.totalEnergy == 0) {
					if (loser == _ownerCube)
						UISignals.ENERGY_OUT.dispatch();
					setTimeout(respawn, 2000, loser);
				}				
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
			//apply 1000 force per second.
			var force:Number = (elapsed * MovingCube.MAX_VELOCITY) / 1000;
			//apply 50 torque per second
			var torque:Number = (elapsed * MovingCube.MAX_ROTATION) / 1000;
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
		
		private function getClosestTarget(aiCube:MovingCube):MovingCube {
			var distanceTmp:Number = Number.MAX_VALUE;
			var position:Vector3D = aiCube.body.position;
			var closest:MovingCube;
			for each(var user:MovingCube in _allPlayers) {
				if(user!=aiCube){
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
		
		private function setExplosion(pCube:MovingCube):void {
			pCube.triggerPowerUp();
			var message:PowerUpMessage = new PowerUpMessage();
			message.triggerdBy = pCube.name;
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
			switch(event.keyCode) {
				case Keyboard.NUMBER_1:
					trace(_ownerCube.powerupRefill, MovingCube.POWERUP_FULL)
					if(_ownerCube.powerupRefill == MovingCube.POWERUP_FULL){
						setExplosion(_ownerCube);
						_ownerCube.powerupRefill = 0;
						UISignals.OWNER_POWERUP_FILL.dispatch(_ownerCube.powerupRefill);
					}
					break;
				case Keyboard.TAB:
					_debugContainer.visible = ! _debugContainer.visible;
					break;
				case Keyboard.A:
				case Keyboard.LEFT:
					leftPressed = false;
					break;
				case Keyboard.D:
				case Keyboard.RIGHT:
					rightPressed = false;
					break;
				case Keyboard.W:
				case Keyboard.UP:
					upPressed = false;
					break;
				case Keyboard.S:
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
			
			var force:Number = (elapsed * 500) / 1000
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
			
			var force:Number = (elapsed * 500) / 1000;
			var torque:Number = (elapsed * 50) / 1000;		
			
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
			var movingCube:MovingCube = new MovingCube(name,  new Vector3D(0, 50, -2500),  new Vector3D(0, 0, 0), new Vector3D(0, 0, 0), isOwner);
			
			_view3D.scene.addChild(movingCube.mesh);
			_physicsWorld.addRigidBody(movingCube.body);
			
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
			if (event.collisionObject.skin.name == "main2")
				return;	
			
				
			var cubeCollider:MovingCube = event.collisionObject.skin.extra as MovingCube;
			var targetCube:MovingCube = event.currentTarget.skin.extra as MovingCube
			if (cubeCollider == null || targetCube == null)
				return;
			//trace(event.collisionObject.skin.extra)
			//trace(cubeCollider, targetCube,(cubeCollider!=null && targetCube!=null))
			if (cubeCollider!=null && targetCube!=null)
			{
				//trace((event.currentTarget.skin.extra.name))
				//trace('collision!!!!!! ',_ownerCube.hasCollided, cubeCollider.hasCollided)
				if (!targetCube.hasCollided && !cubeCollider.hasCollided) {
					var manifold:CollisionManifold = new CollisionManifold();
					manifold.colliderA = cubeCollider.name;
					manifold.colliderB = targetCube.name;
					manifold.positionA = event.manifoldPoint.localPointA;
					manifold.positionB = event.manifoldPoint.localPointB;
					manifold.forceA = cubeCollider.linearVelocityBeforeCollision.length;
					manifold.forceB = targetCube.linearVelocityBeforeCollision.length;
					//trace(manifold.forceA,manifold.forceB)
					//if (manifold.forceA > manifold.forceB) {
					//trace('DISPATCH COLLISION')
					UserInputSignals.USER_IS_COLLIDING.dispatch(manifold);
					//}
					targetCube.hasCollided = true;
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