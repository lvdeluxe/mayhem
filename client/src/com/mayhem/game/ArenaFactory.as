package com.mayhem.game 
{
	import away3d.containers.ObjectContainer3D;
	import away3d.materials.MaterialBase;
	import awayphysics.dynamics.AWPDynamicsWorld;
	import away3d.entities.Mesh;
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.dynamics.AWPRigidBody;
	import away3d.primitives.CubeGeometry;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author availlant
	 */
	public class ArenaFactory 
	{
		
		private static var _instance:ArenaFactory;
		private static var _enableInstantiation:Boolean = false;
		private var _physicsWorld:AWPDynamicsWorld;
		
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
		
		public function getDefaultArena():ObjectContainer3D {
			var container:ObjectContainer3D = new ObjectContainer3D();
			var mat:MaterialBase = MaterialsFactory.getMaterialById(MaterialsFactory.WALLS_MATERIAL);
			
			var groundMesh:Mesh = new Mesh(new CubeGeometry(5000, 50, 5000), mat);			
			var groundShape : AWPBoxShape = new AWPBoxShape(5000, 50, 5000);
			var groundRigidbody : AWPRigidBody = new AWPRigidBody(groundShape,groundMesh, 0);
			groundRigidbody.y = -25;
			_physicsWorld.addRigidBody(groundRigidbody);
			container.addChild(groundMesh);
			
			var bottomWallMesh1:Mesh = new Mesh(new CubeGeometry(1900, 200, 50), mat);
			var bottomWallShape1 : AWPBoxShape = new AWPBoxShape(1900, 200, 50);
			var bottomWallRigidbody1 : AWPRigidBody = new AWPRigidBody(bottomWallShape1,bottomWallMesh1, 0);
			bottomWallRigidbody1.x = (5000/2) - (2500/2) - 100;
			bottomWallRigidbody1.y = 100;
			bottomWallRigidbody1.z = -2475;
			_physicsWorld.addRigidBody(bottomWallRigidbody1);
			container.addChild(bottomWallMesh1);
			
			var bottomWallMesh2:Mesh = new Mesh(new CubeGeometry(1900, 200, 50), mat);
			var bottomWallShape2 : AWPBoxShape = new AWPBoxShape(1900, 200, 50);
			var bottomWallRigidbody2 : AWPRigidBody = new AWPRigidBody(bottomWallShape2,bottomWallMesh2, 0);
			bottomWallRigidbody2.x =  - ((5000/2) - (2500/2)) + 100;
			bottomWallRigidbody2.y = 100;
			bottomWallRigidbody2.z = -2475;
			_physicsWorld.addRigidBody(bottomWallRigidbody2);
			container.addChild(bottomWallMesh2);
			
			var frontWallMesh:Mesh = new Mesh(new CubeGeometry(4000, 200, 50), mat);
			var frontWallShape : AWPBoxShape = new AWPBoxShape(4000, 200, 50);
			var frontWallRigidbody : AWPRigidBody = new AWPRigidBody(frontWallShape,frontWallMesh, 0);
			frontWallRigidbody.y = 100;
			frontWallRigidbody.z = 2475;
			_physicsWorld.addRigidBody(frontWallRigidbody);
			container.addChild(frontWallMesh);
			
			var leftWallMesh:Mesh = new Mesh(new CubeGeometry(50, 200, 4000), mat);
			var leftWallShape : AWPBoxShape = new AWPBoxShape(50, 200, 4000);
			var leftWallRigidbody : AWPRigidBody = new AWPRigidBody(leftWallShape,leftWallMesh, 0);
			leftWallRigidbody.y = 100;
			leftWallRigidbody.x = -2475;
			_physicsWorld.addRigidBody(leftWallRigidbody);
			container.addChild(leftWallMesh);			
			
			var rightWallMesh:Mesh = new Mesh(new CubeGeometry(50, 200, 4000), mat);
			var rightWallShape : AWPBoxShape = new AWPBoxShape(50, 200, 4000);
			var rightWallRigidbody : AWPRigidBody = new AWPRigidBody(rightWallShape,rightWallMesh, 0);
			rightWallRigidbody.y = 100;
			rightWallRigidbody.x = 2475;
			_physicsWorld.addRigidBody(rightWallRigidbody);
			container.addChild(rightWallMesh);
			
			var nwBumper:Bumper = new Bumper(new Vector3D(-1000, 0, 1000),"northWestBumper");
			nwBumper.addToWorld(_physicsWorld, container);
			
			var neBumper:Bumper = new Bumper(new Vector3D(1000, 0, 1000),"northEastBumper");
			neBumper.addToWorld(_physicsWorld, container);
			
			var swBumper:Bumper = new Bumper(new Vector3D(-1000, 0, -1000),"southWestBumper");
			swBumper.addToWorld(_physicsWorld, container);
			
			var seBumper:Bumper = new Bumper(new Vector3D(1000, 0, -1000),"southEastBumper");
			seBumper.addToWorld(_physicsWorld, container);
			
			var landingPlatformMesh:Mesh = new Mesh(new CubeGeometry(400, 50, 500), mat);
			var landingPlatformShape:AWPBoxShape = new AWPBoxShape(400, 50, 500);
			var landingPlatformBody:AWPRigidBody = new AWPRigidBody(landingPlatformShape, landingPlatformMesh, 0);
			//landingPlatformBody.rotationX = 30;
			landingPlatformBody.z = -2500 - 250 //- ((Math.sin(60 * Math.PI / 180) * 500) / 2)
			landingPlatformBody.y = -25//((Math.cos(60 * Math.PI / 180) * 500) / 2)
			_physicsWorld.addRigidBody(landingPlatformBody);
			container.addChild(landingPlatformMesh);
			
			return container;
		}
	}

}