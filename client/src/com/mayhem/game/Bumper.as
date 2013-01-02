package com.mayhem.game 
{
	import away3d.containers.ObjectContainer3D;
	import away3d.core.math.Quaternion;
	import away3d.debug.Trident;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import awayphysics.collision.dispatch.AWPCollisionObject;
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
		
		public function Bumper(pos:Vector3D, pName:String) 
		{
			name = pName;
			mesh = new Mesh(new CylinderGeometry(_radius, _radius, _radius), MaterialsFactory.getMaterialById(MaterialsFactory.BUMPER_MATERIAL));
			mesh.extra = this;
			var shape : AWPCylinderShape = new AWPCylinderShape(_radius,_radius);
			body = new AWPRigidBody(shape,mesh, 0);
			body.x = pos.x;			
			body.y = _radius / 2;
			body.z = pos.z;
			body.addEventListener(AWPEvent.COLLISION_ADDED,collisionDetectionHandler);
		}
		
		private function collisionDetectionHandler(event:AWPEvent):void {
			var cubeCollider:MovingCube = event.collisionObject.skin.extra as MovingCube;
			if (cubeCollider && (_lastCollided == null || _lastCollided != event.collisionObject)) {
				var subs:Vector3D = cubeCollider.mesh.position.subtract(mesh.position);
				var t:Trident = new Trident()
				
				var a:Number = event.manifoldPoint.localPointA.z;
				var b:Number = event.manifoldPoint.localPointA.x;
				var rads:Number = Math.atan2(a, b);
				t.rotationY = -(rads * 180 / Math.PI) + 90; 
			
				t.position = event.manifoldPoint.localPointA;
				
				mesh.addChild(t)
				setTimeout(function():void {
					mesh.removeChild(t);
				},2000);
				
				var r:Number = t.rotationY;
				if (r < 0)
				r += 180
				trace(r)
				
				//subs.normalize();
				//subs.scaleBy(20);
				//cubeCollider.velocityLenght += subs.length;
				//cubeCollider.body.applyCentralImpulse(subs);
				//cubeCollider.bumpingVelocity = cubeCollider.bumpingVelocity.add(subs);
				//trace(subs)
				//trace(cubeCollider.bumpingVelocity)
				trace("//////////////////")
				var particlesPosition:Vector3D = mesh.transform.transformVector(event.manifoldPoint.localPointA);
				setBumpingAnimation(particlesPosition);
				_lastCollided = event.collisionObject;
				
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