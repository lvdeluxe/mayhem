package com.mayhem.game 
{
	//import away3d.containers.ObjectContainer3D;
	//import away3d.entities.Mesh;
	//import away3d.materials.ColorMaterial;
	//import awayphysics.collision.dispatch.AWPCollisionObject;
	//import awayphysics.dynamics.AWPDynamicsWorld;
	//import awayphysics.dynamics.AWPRigidBody;
	//import awayphysics.collision.shapes.AWPCylinderShape;
	//import awayphysics.events.AWPEvent;
	import flare.core.Pivot3D;
	import flare.materials.Shader3D;
	import flare.physics.core.PhysicsMesh;
	import flare.primitives.Cylinder;
	import flash.geom.Vector3D;
	//import away3d.primitives.CylinderGeometry;
	import caurina.transitions.Tweener;
	/**
	 * ...
	 * @author availlant
	 */
	public class Bumper 
	{
		public var mesh	:Cylinder;
		public var body:PhysicsMesh;
		private var _material:Shader3D;
		private var _radius:Number = 200;
		public var name:String;
		//private var _lastCollided:AWPCollisionObject;
		
		public function Bumper(pos:Vector3D, pName:String) 
		{
			name = pName;
			mesh = new Cylinder("",_radius, _radius, 12, MaterialsFactory.getMaterialById(MaterialsFactory.BUMPER_MATERIAL));
			//mesh.extra = this;
			mesh.userData = this
			//var shape : PhysicsMesh = new AWPCylinderShape(_radius,_radius);
			//body = new PhysicsMesh(mesh);
			mesh.x = pos.x;			
			mesh.y = _radius / 2;
			mesh.z = pos.z;
			//mesh.addComponent(body);
			//body.addEventListener(AWPEvent.COLLISION_ADDED,collisionDetectionHandler);
		}
		
		private function collisionDetectionHandler(event:*):void {
			//var cubeCollider:MovingCube = event.collisionObject.skin.extra as MovingCube;
			//if (cubeCollider && (_lastCollided == null || _lastCollided != event.collisionObject)) {
				//var subs:Vector3D = cubeCollider.mesh.position.subtract(mesh.position);
				//subs.normalize();
				//subs.scaleBy(20);
				//cubeCollider.body.applyCentralImpulse(subs);
				//var particlesPosition:Vector3D = mesh.transform.transformVector(event.manifoldPoint.localPointA);
				//setBumpingAnimation(particlesPosition);
				//_lastCollided = event.collisionObject;
				//
			//}
		}
		
		private function removeLastCollided():void {
			//_lastCollided = null
		}
		
		public function setBumpingAnimation(position:Vector3D):void {
			ParticlesFactory.instance.getSparksParticles(position,removeLastCollided);
			bumpOut();
		}
		
		public function addToWorld(physics:*, container:Pivot3D):void {
			//physics.addRigidBody(body);
			container.addChild(mesh);
		}
		
		private function bumpOut():void {
			Tweener.addTween(mesh, { scaleX:1.5, scaleZ:1.5, time:.3, transition:"easeoutquad", onComplete:bumpIn } );
		}
		
		private function bumpIn():void {
			Tweener.addTween(mesh, {scaleX:1,scaleZ:1,time:.2, transition:"easeinquad" } );
		}		
	}

}