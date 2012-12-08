package com.mayhem.game 
{
	//import away3d.containers.ObjectContainer3D;
	//import away3d.materials.MaterialBase;
	//import awayphysics.dynamics.AWPDynamicsWorld;
	//import away3d.entities.Mesh;
	//import awayphysics.collision.shapes.AWPBoxShape;
	//import awayphysics.dynamics.AWPRigidBody;
	//import away3d.primitives.CubeGeometry;
	import flare.core.Pivot3D;
	import flare.materials.Shader3D;
	import flare.physics.core.PhysicsBox;
	import flare.physics.core.RigidBody;
	import flare.primitives.Cube;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author availlant
	 */
	public class ArenaFactory 
	{
		
		private static var _instance:ArenaFactory;
		private static var _enableInstantiation:Boolean = false;
		//private var _physicsWorld:AWPDynamicsWorld;
		
		public function ArenaFactory() 
		{
			if (!_enableInstantiation) {
				throw new Error('This class is a Singleton, should not be instanciated!');
			}
		}
		
		public function initialize(pPhysics:*):void {
			//_physicsWorld = pPhysics;
		}
		
		public static function get instance():ArenaFactory {
			if (!_instance) {
				_enableInstantiation = true
				_instance = new ArenaFactory();
				_enableInstantiation = false;
			}
			return _instance;
		}
		
		public function getDefaultArena():Pivot3D {
			var container:Pivot3D = new Pivot3D();
			var mat:Shader3D = MaterialsFactory.getMaterialById(MaterialsFactory.WALLS_MATERIAL);
			
			var groundMesh:Cube = new Cube("",5000, 50, 5000, 1, mat);			
			//var groundShape : AWPBoxShape = new AWPBoxShape(5000, 50, 5000);
			var groundRigidbody : PhysicsBox = new PhysicsBox();
			groundMesh.y = -25;
			groundMesh.addComponent(groundRigidbody);
			//_physicsWorld.addRigidBody(groundRigidbody);
			container.addChild(groundMesh);
			
			var bottomWallMesh1:Cube = new Cube("",1900, 200, 50,1, mat);
			//var bottomWallShape1 : AWPBoxShape = new AWPBoxShape(1900, 200, 50);
			var bottomWallRigidbody1 : PhysicsBox = new PhysicsBox();
			bottomWallMesh1.x = (5000/2) - (2500/2) - 100;
			bottomWallMesh1.y = 100;
			bottomWallMesh1.z = -2475;
			bottomWallMesh1.addComponent(bottomWallRigidbody1);
			//_physicsWorld.addRigidBody(bottomWallRigidbody1);
			container.addChild(bottomWallMesh1);
			
			var bottomWallMesh2:Cube = new Cube("",1900, 200, 50,1, mat);
			//var bottomWallShape2 : AWPBoxShape = new AWPBoxShape(1900, 200, 50);
			var bottomWallRigidbody2 : PhysicsBox = new PhysicsBox();
			bottomWallMesh2.x =  - ((5000/2) - (2500/2)) + 100;
			bottomWallMesh2.y = 100;
			bottomWallMesh2.z = -2475;
			bottomWallMesh2.addComponent(bottomWallRigidbody2);
			//_physicsWorld.addRigidBody(bottomWallRigidbody2);
			container.addChild(bottomWallMesh2);
			
			var frontWallMesh:Cube = new Cube("",4000, 200, 50,1, mat);
			//var frontWallShape : AWPBoxShape = new AWPBoxShape(4000, 200, 50);
			var frontWallRigidbody : PhysicsBox = new PhysicsBox();
			frontWallMesh.y = 100;
			frontWallMesh.z = 2475;
			frontWallMesh.addComponent(frontWallRigidbody);
			//_physicsWorld.addRigidBody(frontWallRigidbody);
			container.addChild(frontWallMesh);
			
			var leftWallMesh:Cube = new Cube("",50, 200, 4000,1, mat);
			//var leftWallShape : AWPBoxShape = new AWPBoxShape(50, 200, 4000);
			var leftWallRigidbody : PhysicsBox = new PhysicsBox();
			leftWallMesh.y = 100;
			leftWallMesh.x = -2475;
			leftWallMesh.addComponent(leftWallRigidbody);
			container.addChild(leftWallMesh);			
			
			var rightWallMesh:Cube = new Cube("",50, 200, 4000,1, mat);
			//var rightWallShape : AWPBoxShape = new AWPBoxShape(50, 200, 4000);
			var rightWallRigidbody : PhysicsBox = new PhysicsBox();
			rightWallMesh.y = 100;
			rightWallMesh.x = 2475;
			rightWallMesh.addComponent(rightWallRigidbody);
			container.addChild(rightWallMesh);
			
			var nwBumper:Bumper = new Bumper(new Vector3D(-1000, 0, 1000),"northWestBumper");
			nwBumper.addToWorld(null, container);
			
			var neBumper:Bumper = new Bumper(new Vector3D(1000, 0, 1000),"northEastBumper");
			neBumper.addToWorld(null, container);
			
			var swBumper:Bumper = new Bumper(new Vector3D(-1000, 0, -1000),"southWestBumper");
			swBumper.addToWorld(null, container);
			
			var seBumper:Bumper = new Bumper(new Vector3D(1000, 0, -1000),"southEastBumper");
			seBumper.addToWorld(null, container);
			
			var landingPlatformMesh:Cube = new Cube("",400, 50, 500,1, mat);
			//var landingPlatformShape:AWPBoxShape = new AWPBoxShape(400, 50, 500);
			var landingPlatformBody:PhysicsBox = new PhysicsBox();
			//landingPlatformBody.rotationX = 30;
			landingPlatformMesh.z = -2500 - 250 //- ((Math.sin(60 * Math.PI / 180) * 500) / 2)
			landingPlatformMesh.y = -25//((Math.cos(60 * Math.PI / 180) * 500) / 2)
			landingPlatformMesh.addComponent(landingPlatformBody);
			container.addChild(landingPlatformMesh);
			
			return container;
		}
	}

}