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
	import away3d.primitives.PlaneGeometry;
	import awayphysics.collision.dispatch.AWPGhostObject;
	import awayphysics.collision.shapes.AWPBvhTriangleMeshShape;
	import awayphysics.collision.shapes.AWPStaticPlaneShape;
	import awayphysics.data.AWPCollisionFlags;
	import awayphysics.dynamics.AWPDynamicsWorld;
	import away3d.entities.Mesh;
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.dynamics.AWPRigidBody;
	import away3d.primitives.CubeGeometry;
	import awayphysics.events.AWPEvent;
	import com.mayhem.multiplayer.Connector;
	import com.mayhem.signals.MultiplayerSignals;
	import com.mayhem.signals.UserInputSignals;
	import flash.geom.Vector3D;
	import away3d.library.AssetLibrary;
	import away3d.events.AssetEvent;
	import away3d.loaders.parsers.AWDParser;
	import flash.net.URLRequest;
	import com.mayhem.signals.GameSignals;
	/**
	 * ...
	 * @author availlant
	 */
	public class ArenaFactory 
	{
		
		public static const FALL_FROM_ARENA:String = "fallFromArena";
		
		[Embed(source = "/assets/Arena1.awd", mimeType = "application/octet-stream")]
		private var ArenaClass:Class;
		
		private static var _instance:ArenaFactory;
		private static var _enableInstantiation:Boolean = false;
		private var _physicsWorld:AWPDynamicsWorld;
		private var _mainContainer:ObjectContainer3D;
		public var allSpawnPoints:Vector.<Mesh> = new Vector.<Mesh>(Connector.MAX_USER_PER_ROOM);
		
		public function ArenaFactory() 
		{
			if (!_enableInstantiation) {
				throw new Error('This class is a Singleton, should not be instanciated!');
			}
		}
		
		public function initialize(pPhysics:AWPDynamicsWorld):void {
			_physicsWorld = pPhysics;
		}
		
		public static function get instance():ArenaFactory {
			if (!_instance) {
				_enableInstantiation = true
				_instance = new ArenaFactory();
				_enableInstantiation = false;
			}
			return _instance;
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
				trace(allSpawnPoints[i].position, pos)
				if (allSpawnPoints[i].position.x == pos.x && allSpawnPoints[i].position.z == pos.z)
					return i;
			}
			return index;
		}
		
		public function getSpawnPoint(index:int):Vector3D {
			var pos:Vector3D = allSpawnPoints[index].position.clone();
			allSpawnPoints[index].extra.occupied = true;
			pos.y += 50;
			return pos;
		}
		
		public function getDefaultArena():ObjectContainer3D {
			_mainContainer = new ObjectContainer3D();
			for each(var mesh:Mesh in ModelsManager.instance.allArenaMeshes) {
				trace(mesh.name)
				var prefix:String = mesh.name.split("_")[0];
				if (prefix == "start") {
					var pos:int = mesh.name.split("_")[1];
					mesh.extra = new Object();
					mesh.extra.occupied = false;
					if(pos < allSpawnPoints.length	)
						allSpawnPoints[pos] = mesh;
					
				}else {
					mesh.material.bothSides = true;
					mesh.material.lightPicker = MaterialsFactory.mainLightPicker;
					ColorMaterial(mesh.material).shadowMethod = new FilteredShadowMapMethod(MaterialsFactory.mainLightPicker.lights[0]);
					var shape:AWPBvhTriangleMeshShape = new AWPBvhTriangleMeshShape(mesh.geometry);
					var body:AWPRigidBody = new AWPRigidBody(shape, mesh);
					_physicsWorld.addRigidBody(body);
					_mainContainer.addChild(mesh);
					if (prefix == "refill") {
						body.collisionFlags = AWPCollisionFlags.CF_NO_CONTACT_RESPONSE;
						body.addEventListener(AWPEvent.COLLISION_ADDED, onRefillPowerUp);
					}
					
				}
			}
			
			var fallingShape : AWPStaticPlaneShape = new AWPStaticPlaneShape(new Vector3D(0, 1, 0));
			var fallingRigidbody : AWPGhostObject = new AWPGhostObject(fallingShape);
			fallingRigidbody.addEventListener(AWPEvent.COLLISION_ADDED, onFallingCollision);
			fallingRigidbody.y = -200;
			fallingRigidbody.collisionFlags |= AWPCollisionFlags.CF_NO_CONTACT_RESPONSE;
			_physicsWorld.addCollisionObject(fallingRigidbody);
			
			return _mainContainer;
		}
		
		private function onRefillPowerUp(event:AWPEvent):void {
			var fallingCube:MovingCube = event.collisionObject.skin.extra as MovingCube;
			if (fallingCube) {
				GameSignals.REFILL_POWERUP.dispatch(fallingCube);
			}
		}
		private function onFallingCollision(event:AWPEvent):void {
			var fallingCube:MovingCube = event.collisionObject.skin.extra as MovingCube;
			if (fallingCube && !fallingCube.hasFelt) {
				fallingCube.hasFelt = true;
				UserInputSignals.USER_IS_FALLING.dispatch(fallingCube);
			}
		}
	}

}