package com.mayhem.game 
{
	import away3d.containers.ObjectContainer3D;
	import away3d.events.LoaderEvent;
	import away3d.library.assets.AssetType;
	import away3d.loaders.misc.AssetLoaderContext;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.tools.utils.Bounds;
	import awayphysics.collision.dispatch.AWPCollisionObject;
	import awayphysics.collision.dispatch.AWPCollisionWorld;
	import awayphysics.collision.dispatch.AWPGhostObject;
	import awayphysics.collision.shapes.AWPBvhTriangleMeshShape;
	import awayphysics.collision.shapes.AWPCylinderShape;
	import awayphysics.collision.shapes.AWPStaticPlaneShape;
	import awayphysics.data.AWPCollisionFlags;
	import awayphysics.data.AWPCollisionShapeType;
	import awayphysics.dynamics.AWPDynamicsWorld;
	import away3d.entities.Mesh;
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.dynamics.AWPRigidBody;
	import away3d.primitives.CubeGeometry;
	import awayphysics.events.AWPEvent;
	import com.mayhem.multiplayer.Connector;
	import com.mayhem.signals.MultiplayerSignals;
	import com.mayhem.signals.UISignals;
	import com.mayhem.signals.UserInputSignals;
	import flash.geom.Vector3D;
	import away3d.library.AssetLibrary;
	import away3d.events.AssetEvent;
	import away3d.loaders.parsers.AWDParser;
	import flash.net.URLRequest;
	import com.mayhem.signals.GameSignals;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author availlant
	 */
	public class ArenaFactory 
	{
		
		public static const FALL_FROM_ARENA:String = "fallFromArena";
		
		private static var _instance:ArenaFactory;
		private static var _enableInstantiation:Boolean = false;
		private var _physicsWorld:AWPDynamicsWorld;
		private var _mainContainer:ObjectContainer3D;
		public var allSpawnPoints:Vector.<Mesh> = new Vector.<Mesh>(Connector.MAX_USER_PER_ROOM);
		private var _allDoors:Dictionary = new Dictionary();
		public var mainBody:AWPRigidBody;
		private var _rampRigidBody:AWPRigidBody;
		private var _rampRotation:Number = 0;
		
		public function ArenaFactory() 
		{
			if (!_enableInstantiation) {
				throw new Error('This class is a Singleton, should not be instanciated!');
			}
		}
		
		public function initialize(pPhysics:AWPDynamicsWorld):void {
			_physicsWorld = pPhysics;
			GameSignals.OPEN_DOOR.add(openDoor);
		}
		
		public static function get instance():ArenaFactory {
			if (!_instance) {
				_enableInstantiation = true
				_instance = new ArenaFactory();
				_enableInstantiation = false;
			}
			return _instance;
		}
		
		private function openDoor(doorIndex:uint):void {
			_allDoors[doorIndex].y = 600;
		}
	
		public function getAvailableSlots():uint {
			var slotsAvail:uint = 0;
			for (var i:uint = 0 ; i < Connector.MAX_USER_PER_ROOM ; i++ ) {
				if (!allSpawnPoints[i].extra.occupied)
					slotsAvail++;
			}
			return slotsAvail;
		}
		
		public function getSpawnIndexByPosition(pos:Vector3D):int {
			var index:int = -1
			for (var i:uint = 0 ; i < allSpawnPoints.length ; i++ ) {
				if (allSpawnPoints[i].position.x == pos.x && allSpawnPoints[i].position.z == pos.z)
					return i;
			}
			return index;
		}
		
		public function getSpawnPoint(index:int):Vector3D {
			var pos:Vector3D = allSpawnPoints[index].position.clone();
			allSpawnPoints[index].extra.occupied = true;
			pos.y += 100;
			return pos;
		}
		
		
		private function meshDoorIndex(meshName:String):int {
			for (var i:uint = 0 ; i < 12 ; i++ ) {
				var mappingName:String = MeshMapping["DOOR_" + i.toString()];
				if (mappingName == meshName)
					return i;	
			}
			return -1;
		}
		
		private function meshSpawnPointIndex(meshName:String):int {
			for (var i:uint = 0 ; i < 12 ; i++ ) {
				var mappingName:String = MeshMapping["SPAWN_POINT_" + i.toString()];
				if (mappingName == meshName)
					return i;	
			}
			return -1;
		}
		
		public function rotateRamp():void {
			if (_rampRigidBody) {
				_rampRotation+=0.2;
				//_rampRigidBody.rotation = new Vector3D(0,_rampRotation,0);
			}
		}
		
		
		private function meshIsBumper(meshName:String):Boolean {
			for (var i:uint = 0 ; i < MeshMapping.ALL_BUMPERS.length ; i++ ) {
				if(MeshMapping.ALL_BUMPERS[i] == meshName)
					return true;	
			}
			return false;
		}
		
		public function getDefaultArena():ObjectContainer3D {
			_mainContainer = new ObjectContainer3D();
			var body:AWPRigidBody
			for each(var mesh:Mesh in ModelsManager.instance.allArenaMeshes) {
				var prefix:String = mesh.name.split("_")[0];
				var index:int = meshSpawnPointIndex(mesh.name);
				if (index >= 0) {
					mesh.name = "start_" + index.toString();
					mesh.extra = new Object();
					mesh.extra.occupied = false;
					if(index < allSpawnPoints.length)
						allSpawnPoints[index] = mesh;
					
				}else{
					mesh.material.bothSides = true;
					mesh.material.lightPicker = MaterialsFactory.mainLightPicker;
					TextureMaterial(mesh.material).shadowMethod = new FilteredShadowMapMethod(MaterialsFactory.mainLightPicker.lights[0]);
					
					if (meshIsBumper(mesh.name)) {
						var b:Bumper = new Bumper(mesh);
						body = b.body;
					}else {
						if (mesh.name == MeshMapping.INNER_FLOOR) {
							var planeShape:AWPStaticPlaneShape = new AWPStaticPlaneShape();
							body = new AWPRigidBody(planeShape, mesh);
						}else if (mesh.name == MeshMapping.OUTTER_FLOOR) {
							
						}else{
							var shape:AWPBvhTriangleMeshShape = new AWPBvhTriangleMeshShape(mesh.geometry, true);
							body = new AWPRigidBody(shape, mesh);
							body.friction = 1
							body.position = mesh.position;
							var doorIndex:int = meshDoorIndex(mesh.name);
							if (prefix == "refill") {
								body.collisionFlags = AWPCollisionFlags.CF_NO_CONTACT_RESPONSE;
								body.addEventListener(AWPEvent.COLLISION_ADDED, onRefillPowerUp);
							}else  if (doorIndex != -1) {
								
								var m:ColorMaterial =  new ColorMaterial(0xcc0000,0);
								var planeMesh:Mesh = new Mesh(new PlaneGeometry(200, 200), m);
								planeMesh.name = "doorTrigger" + doorIndex.toString();
								var pShape:AWPBvhTriangleMeshShape = new AWPBvhTriangleMeshShape(planeMesh.geometry);
								var boxBody:AWPRigidBody = new AWPRigidBody(pShape, planeMesh);
								boxBody.position = body.position.clone();
								boxBody.rotationX = 90;
								boxBody.rotationY = (doorIndex * (360 / 12));
								boxBody.collisionFlags = AWPCollisionFlags.CF_DISABLE_VISUALIZE_OBJECT;
								boxBody.collisionFlags |= AWPCollisionFlags.CF_NO_CONTACT_RESPONSE;
								_physicsWorld.addRigidBody(boxBody);
								_mainContainer.addChild(planeMesh);
								planeMesh.extra = new Object();
								planeMesh.extra.door = body;
								planeMesh.extra.index = doorIndex;
								boxBody.addEventListener(AWPEvent.COLLISION_ADDED, onDoorPassed);
								body.y = 600;
								_allDoors[doorIndex] = body;
							}else {
								mainBody = body;
								body.friction = GameData.ARENA_FRICTION;
								body.restitution = GameData.ARENA_RESTITUTION;
							}
						}
					}
					if (mesh.name == MeshMapping.RAMP) {
						_rampRigidBody = body;		
						//var rBody:AWPCollisionObject = new AWPCollisionObject();
					}
					if(body != null)_physicsWorld.addRigidBody(body);
					_mainContainer.addChild(mesh);
				}
			}
			
			var dangerShape:AWPCylinderShape = new AWPCylinderShape(3000, 500);
			var mat:ColorMaterial = new ColorMaterial(0xcc0000, 0.1);
			mat.bothSides = true;
			var dangerMesh:Mesh = new Mesh(new CylinderGeometry(3000, 3000, 500, 16, 1, false, false), mat);
			dangerMesh.castsShadows = false;
			var dangerRigidBody:AWPRigidBody = new AWPRigidBody(dangerShape, dangerMesh);
			dangerRigidBody.y = 250;
			dangerRigidBody.collisionFlags = AWPCollisionFlags.CF_NO_CONTACT_RESPONSE;
			_physicsWorld.addRigidBody(dangerRigidBody);
			_mainContainer.addChild(dangerMesh);
			ParticlesFactory.instance.getDangerParticles(null);
			dangerRigidBody.addEventListener(AWPEvent.COLLISION_ADDED, onDangerCollision);
			
			var fallingShape : AWPStaticPlaneShape = new AWPStaticPlaneShape(new Vector3D(0, 1, 0));
			var fallingRigidbody : AWPGhostObject = new AWPGhostObject(fallingShape);
			fallingRigidbody.addEventListener(AWPEvent.COLLISION_ADDED, onFallingCollision);
			fallingRigidbody.y = -200;
			fallingRigidbody.collisionFlags |= AWPCollisionFlags.CF_NO_CONTACT_RESPONSE;
			_physicsWorld.addCollisionObject(fallingRigidbody);
			
			return _mainContainer;
		}
		
		private function onDoorPassed(event:AWPEvent):void {
			if(event.collisionObject.skin){
				var vehicle:MovingCube = event.collisionObject.skin.extra as MovingCube;
				if (vehicle && event.currentTarget.skin.extra.index == vehicle.user.spawnIndex) {
					var doorBody:AWPRigidBody = event.currentTarget.skin.extra.door;
					setTimeout(function():void {
						doorBody.y = 193.81425380706787;
						vehicle.enableBehavior = true;
						if (vehicle is MovingAICube) {
							GameSignals.SET_AI_TARGET.dispatch(vehicle);
						}
					},250);
				}
			}
		}
		
		private function onRefillPowerUp(event:AWPEvent):void {
			var fallingCube:MovingCube = event.collisionObject.skin.extra as MovingCube;
			if (fallingCube) {
				GameSignals.REFILL_POWERUP.dispatch(fallingCube);
			}
		}
		private function onDangerCollision(event:AWPEvent):void {
			if(event.collisionObject.skin){
				var vehicle:MovingCube = event.collisionObject.skin.extra as MovingCube;
				if (vehicle) {
					if(!vehicle.hasShield)
						GameSignals.DANGER_ZONE_COLLISION.dispatch(vehicle);					
				}
			}
		}
		private function onFallingCollision(event:AWPEvent):void {
			if(event.collisionObject.skin){
				var fallingCube:MovingCube = event.collisionObject.skin.extra as MovingCube;
				if (fallingCube && !fallingCube.hasFelt) {
					fallingCube.hasFelt = true;
					UserInputSignals.USER_IS_FALLING.dispatch(fallingCube);
				}
			}
		}
	}

}