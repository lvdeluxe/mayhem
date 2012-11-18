package com.mayhem.game 
{
	import awayphysics.dynamics.AWPRigidBody;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author availlant
	 */
	public class LightRigidBody 
	{
		
		public var linearVelocity:Vector3D;
		public var angularVelocity:Vector3D;
		public var position:Vector3D;
		public var rotation:Vector3D;
		public var totalForce:Vector3D;
		public var totalTorque:Vector3D;
		
		public function LightRigidBody() 
		{
			
		}
		
		public static function fromAWPRigidBody(rBody:AWPRigidBody):LightRigidBody {
			var lightRigidBody:LightRigidBody = new LightRigidBody();
			lightRigidBody.linearVelocity = rBody.linearVelocity.clone();
			lightRigidBody.angularVelocity = rBody.angularVelocity.clone();
			lightRigidBody.position = rBody.position.clone();
			lightRigidBody.rotation = rBody.rotation.clone();
			lightRigidBody.totalForce = rBody.totalForce.clone();
			lightRigidBody.totalTorque = rBody.totalTorque.clone();
			return lightRigidBody;
		}
		
		public function applyToRigidBody(rBody:AWPRigidBody):void {
			rBody.rotation = rotation;
			rBody.position = position;
			rBody.linearVelocity = linearVelocity;
			rBody.angularVelocity = angularVelocity;
			rBody.applyCentralForce(totalForce);
			rBody.applyTorque(totalTorque);
		}
		
		
	}

}