package com.mayhem.game 
{
	import away3d.containers.ObjectContainer3D;
	import away3d.events.LoaderEvent;
	import away3d.library.assets.AssetType;
	import away3d.loaders.misc.AssetLoaderContext;
	import away3d.materials.MaterialBase;
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
		
		[Embed(source = "/assets/Arena2.awd", mimeType = "application/octet-stream")]
		private var ArenaClass:Class;
		
		private static var _instance:ArenaFactory;
		private static var _enableInstantiation:Boolean = false;
		private var _physicsWorld:AWPDynamicsWorld;
		private var _mainContainer:ObjectContainer3D;
		private var _allSpawnPoints:Vector.<Mesh> = new Vector.<Mesh>(Connector.MAX_USER_PER_ROOM);
		
		public function ArenaFactory() 
		{
			if (!_enableInstantiation) {
				throw new Error('This class is a Singleton, should not be instanciated!');
			}
		}
		
		public function initialize(pPhysics:AWPDynamicsWorld):void {
			_physicsWorld = pPhysics;
			
			AssetLibrary.enableParser(AWDParser);
		}
		
		public static function get instance():ArenaFactory {
			if (!_instance) {
				_enableInstantiation = true
				_instance = new ArenaFactory();
				_enableInstantiation = false;
			}
			return _instance;
		}
		
		private function onAssetFullyLoaded(event:LoaderEvent):void {
			GameSignals.ARENA_READY.dispatch(_allSpawnPoints);
		}
		
		public function getAvailableSlots():uint {
			var slotsAvail:uint = 0;
			for (var i:uint = 0 ; i < Connector.MAX_USER_PER_ROOM ; i++ ) {
				if (!_allSpawnPoints[i].extra.occupied)
					slotsAvail++;
			}
			return slotsAvail;
		}
		
		public function getSpawnPoint(index:int):Vector3D {
			var pos:Vector3D = _allSpawnPoints[index].position.clone();
			_allSpawnPoints[index].extra.occupied = true;
			pos.y += 50;
			return pos;
		}
		
		
		private function onAssetComplete(event:AssetEvent):void {
			if (event.asset.assetType == AssetType.MESH) {
				
				var mesh:Mesh = event.asset as Mesh;
				trace(mesh.name)
				var prefix:String = mesh.name.split("_")[0];
				if (prefix == "start") {
					var pos:int = mesh.name.split("_")[1];
					mesh.extra = new Object();
					mesh.extra.occupied = false;
					_allSpawnPoints[pos] = mesh;
					
				}else {
					mesh.material.bothSides = true;
					mesh.material.lightPicker = MaterialsFactory.mainLightPicker;
					var shape:AWPBvhTriangleMeshShape = new AWPBvhTriangleMeshShape(mesh.geometry);
					var body:AWPRigidBody = new AWPRigidBody(shape, mesh);
					_physicsWorld.addRigidBody(body);
					_mainContainer.addChild(mesh);
					if (prefix == "refill") {
						body.collisionFlags = AWPCollisionFlags.CF_NO_CONTACT_RESPONSE;
					}
					
				}
				
			}
			//var mesh:Mesh = event.asset as Mesh;
			//trace(event.asset)
			//trace(event.asset.assetType)
			//trace(event.type)
			//_mainContainer.addChild(mesh);
		}
		
		
		public function getDefaultArena():ObjectContainer3D {
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			AssetLibrary.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onAssetFullyLoaded);
			//AssetEvent.ENTITY_COMPLETE
			AssetLibrary.loadData(new ArenaClass())//new URLRequest("assets/Arena1.awd"));
			
			_mainContainer = new ObjectContainer3D();
			
			var mat:MaterialBase = MaterialsFactory.getMaterialById(MaterialsFactory.WALLS_MATERIAL);
			
			//var groundMesh:Mesh = new Mesh(new CubeGeometry(5000, 50, 5000), mat);	
			//var groundShape : AWPBoxShape = new AWPBoxShape(5000, 50, 5000);
			//var groundRigidbody : AWPRigidBody = new AWPRigidBody(groundShape,groundMesh, 0);
			//groundRigidbody.y = -25;
			//_physicsWorld.addRigidBody(groundRigidbody);
			//_mainContainer.addChild(groundMesh);
			//
			//var bottomWallMesh1:Mesh = new Mesh(new CubeGeometry(1900, 200, 50), mat);
			//var bottomWallShape1 : AWPBoxShape = new AWPBoxShape(1900, 200, 50);
			//var bottomWallRigidbody1 : AWPRigidBody = new AWPRigidBody(bottomWallShape1,bottomWallMesh1, 0);
			//bottomWallRigidbody1.x = (5000/2) - (2500/2) - 100;
			//bottomWallRigidbody1.y = 100;
			//bottomWallRigidbody1.z = -2475;
			//_physicsWorld.addRigidBody(bottomWallRigidbody1);
			//_mainContainer.addChild(bottomWallMesh1);
			//
			//var bottomWallMesh2:Mesh = new Mesh(new CubeGeometry(1900, 200, 50), mat);
			//var bottomWallShape2 : AWPBoxShape = new AWPBoxShape(1900, 200, 50);
			//var bottomWallRigidbody2 : AWPRigidBody = new AWPRigidBody(bottomWallShape2,bottomWallMesh2, 0);
			//bottomWallRigidbody2.x =  - ((5000/2) - (2500/2)) + 100;
			//bottomWallRigidbody2.y = 100;
			//bottomWallRigidbody2.z = -2475;
			//_physicsWorld.addRigidBody(bottomWallRigidbody2);
			//_mainContainer.addChild(bottomWallMesh2);
			//
			//var frontWallMesh:Mesh = new Mesh(new CubeGeometry(4000, 200, 50), mat);
			//var frontWallShape : AWPBoxShape = new AWPBoxShape(4000, 200, 50);
			//var frontWallRigidbody : AWPRigidBody = new AWPRigidBody(frontWallShape,frontWallMesh, 0);
			//frontWallRigidbody.y = 100;
			//frontWallRigidbody.z = 2475;
			//_physicsWorld.addRigidBody(frontWallRigidbody);
			//_mainContainer.addChild(frontWallMesh);
			//
			//var leftWallMesh:Mesh = new Mesh(new CubeGeometry(50, 200, 4000), mat);
			//var leftWallShape : AWPBoxShape = new AWPBoxShape(50, 200, 4000);
			//var leftWallRigidbody : AWPRigidBody = new AWPRigidBody(leftWallShape,leftWallMesh, 0);
			//leftWallRigidbody.y = 100;
			//leftWallRigidbody.x = -2475;
			//_physicsWorld.addRigidBody(leftWallRigidbody);
			//_mainContainer.addChild(leftWallMesh);			
			//
			//var rightWallMesh:Mesh = new Mesh(new CubeGeometry(50, 200, 4000), mat);
			//var rightWallShape : AWPBoxShape = new AWPBoxShape(50, 200, 4000);
			//var rightWallRigidbody : AWPRigidBody = new AWPRigidBody(rightWallShape,rightWallMesh, 0);
			//rightWallRigidbody.y = 100;
			//rightWallRigidbody.x = 2475;
			//_physicsWorld.addRigidBody(rightWallRigidbody);
			//_mainContainer.addChild(rightWallMesh);
			//
			//var nwBumper:Bumper = new Bumper(new Vector3D(-1000, 0, 1000),"northWestBumper");
			//nwBumper.addToWorld(_physicsWorld, _mainContainer);
			//
			//var neBumper:Bumper = new Bumper(new Vector3D(1000, 0, 1000),"northEastBumper");
			//neBumper.addToWorld(_physicsWorld, _mainContainer);
			//
			//var swBumper:Bumper = new Bumper(new Vector3D(-1000, 0, -1000),"southWestBumper");
			//swBumper.addToWorld(_physicsWorld, _mainContainer);
			//
			//var seBumper:Bumper = new Bumper(new Vector3D(1000, 0, -1000),"southEastBumper");
			//seBumper.addToWorld(_physicsWorld, _mainContainer);
			//
			//var landingPlatformMesh:Mesh = new Mesh(new CubeGeometry(400, 50, 500), mat);
			//var landingPlatformShape:AWPBoxShape = new AWPBoxShape(400, 50, 500);
			//var landingPlatformBody:AWPRigidBody = new AWPRigidBody(landingPlatformShape, landingPlatformMesh, 0);
			//landingPlatformBody.rotationX = 30;
			//landingPlatformBody.z = -2500 - 250 //- ((Math.sin(60 * Math.PI / 180) * 500) / 2)
			//landingPlatformBody.y = -25//((Math.cos(60 * Math.PI / 180) * 500) / 2)
			//_physicsWorld.addRigidBody(landingPlatformBody);
			//_mainContainer.addChild(landingPlatformMesh);
			
			var fallingShape : AWPStaticPlaneShape = new AWPStaticPlaneShape(new Vector3D(0, 1, 0));
			var fallingRigidbody : AWPGhostObject = new AWPGhostObject(fallingShape);
			fallingRigidbody.addEventListener(AWPEvent.COLLISION_ADDED, onFallingCollision);
			fallingRigidbody.y = -50;
			fallingRigidbody.collisionFlags |= AWPCollisionFlags.CF_NO_CONTACT_RESPONSE;
			_physicsWorld.addCollisionObject(fallingRigidbody);
			
			return _mainContainer;
		}
		
		private function onFallingCollision(event:AWPEvent):void {
			var fallingCube:MovingCube = event.collisionObject.skin.extra as MovingCube;
			if (fallingCube && !fallingCube.hasFelt) {
				fallingCube.hasFelt = true;
				//fallingCube.car..linearDamping = 0;
				UserInputSignals.USER_IS_FALLING.dispatch(fallingCube);
			}
		}
	}

}