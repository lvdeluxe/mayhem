package com.mayhem.game 
{
	import away3d.containers.ObjectContainer3D;
	import away3d.core.math.Quaternion;
	import away3d.debug.Trident;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import awayphysics.collision.dispatch.AWPCollisionObject;
	import awayphysics.data.AWPCollisionFlags;
	import awayphysics.dynamics.AWPDynamicsWorld;
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.collision.shapes.AWPCylinderShape;
	import awayphysics.events.AWPEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import away3d.primitives.CylinderGeometry;
	import caurina.transitions.Tweener;
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author availlant
	 */
	public class Bumper 
	{
		public var mesh	:Mesh;
		public var body:AWPRigidBody;
		private var _material:ColorMaterial;
		private var _radius:Number = 200;
		public var name:String;
		private var _lastCollided:AWPCollisionObject;
		
		public function Bumper(pMesh:Mesh) 
		{
			name = pMesh.name;
			mesh = pMesh;
			mesh.extra = this;
			var height:Number = (pMesh.bounds.max.y - pMesh.bounds.min.y);
			var radius:Number = (pMesh.bounds.max.z - pMesh.bounds.min.z) / 2
			var shape : AWPCylinderShape = new AWPCylinderShape(radius,height);
			body = new AWPRigidBody(shape, mesh, 0);
			body.position = pMesh.position;
			body.addEventListener(AWPEvent.COLLISION_ADDED,collisionDetectionHandler);
		}
		
		private function collisionDetectionHandler(event:AWPEvent):void {
			if(event.collisionObject.skin){
				var cubeCollider:MovingCube = event.collisionObject.skin.extra as MovingCube;
				if (cubeCollider && (_lastCollided == null || _lastCollided != event.collisionObject)) {
					var subs:Vector3D = body.position.subtract(cubeCollider.body.position);
					subs.negate();
					subs.normalize();
					subs.y = 0;
					subs.scaleBy(GameData.BUMPER_FORCE);
					cubeCollider.body.applyCentralImpulse(subs);
					var particlesPosition:Vector3D = mesh.transform.transformVector(event.manifoldPoint.localPointA);
					setBumpingAnimation(particlesPosition);
					_lastCollided = event.collisionObject;				
				}
			}
		}
		
		private function removeLastCollided():void {
			_lastCollided = null
		}
		
		public function setBumpingAnimation(position:Vector3D):void {
			ParticlesFactory.instance.getSparksParticles(position,removeLastCollided);
			bumpOut();
		}
		
		public function addToWorld(physics:AWPDynamicsWorld, container:ObjectContainer3D):void {
			physics.addRigidBody(body);
			container.addChild(mesh);
		}
		
		private function bumpOut():void {
			Tweener.addTween(body.scale, { x:1.5, z:1.5, time:.3, transition:"easeoutquad", onComplete:bumpIn } );
		}
		
		private function bumpIn():void {
			Tweener.addTween(body.scale, {x:1,z:1,time:.2, transition:"easeinquad" } );
		}		
	}

}