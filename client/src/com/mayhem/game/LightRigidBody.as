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
		
		public var steering:Number;
		public var engineForce:Number;
		
		
		
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
			lightRigidBody.totalForce = rBody.totalForce.clone();
			lightRigidBody.totalTorque = rBody.totalTorque.clone();
			return lightRigidBody;
		}
		
		public static function fromVehicle(vehicle:AWPRaycastVehicle):LightRigidBody {
			var body:AWPRigidBody = vehicle.getRigidBody();
			var lightRigidBody:LightRigidBody = new LightRigidBody();
			lightRigidBody.linearVelocity = body.linearVelocity.clone();
			lightRigidBody.angularVelocity = body.angularVelocity.clone();
			lightRigidBody.angularDamping = body.angularDamping;
			lightRigidBody.linearDamping = body.linearDamping;
			lightRigidBody.position = body.position.clone();
			lightRigidBody.rotation = body.rotation.clone();
			lightRigidBody.totalForce = body.totalForce.clone();
			lightRigidBody.totalTorque = body.totalTorque.clone();
			lightRigidBody.steering = vehicle.getSteeringValue(0);
			//lightRigidBody.steering = vehicle.(0);
			return lightRigidBody;
		}
		
		public function applyToVehicle(vehicle:AWPRaycastVehicle):void {
			var body:AWPRigidBody = vehicle.getRigidBody();
			body.position = position;
			body.linearVelocity;
			vehicle.setSteeringValue(steering,0)
			vehicle.setSteeringValue(steering,1)
		}
		
		
		public function applyToRigidBody(rBody:AWPRigidBody):void {
			//rBody.
			//rBody.rotation = rotation;
			rBody.position = position;
			//rBody.linearDamping = linearDamping;
			//rBody.angularDamping = angularDamping;
			//rBody.linearVelocity = linearVelocity;
			//rBody.angularVelocity = angularVelocity;
			//rBody.applyCentralForce(totalForce);
			//rBody.applyTorque(totalTorque);
		}
		
		
	}

}