package com.mayhem.game 
{
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.dynamics.vehicle.AWPRaycastVehicle;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author availlant
	 */
	public class LightRigidBody 
	{
		
		public var linearDamping:Number;
		public var angularDamping:Number;
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
			lightRigidBody.angularDamping = rBody.angularDamping;
			lightRigidBody.linearDamping = rBody.linearDamping;
			lightRigidBody.position = rBody.position.clone();
			lightRigidBody.rotation = rBody.rotation.clone();
			return lightRigidBody;
		}
		
		public function applyToRigidBody(rBody:AWPRigidBody):void {
			//rBody.
			rBody.rotation = rotation;
			rBody.position = position;
			rBody.linearDamping = linearDamping;
			rBody.angularDamping = angularDamping;
			rBody.linearVelocity = linearVelocity;
			rBody.angularVelocity = angularVelocity;
		}
		
		
	}

}