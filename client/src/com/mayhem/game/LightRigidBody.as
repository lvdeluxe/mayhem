package com.mayhem.game 
{
	//import awayphysics.dynamics.AWPRigidBody;
	import flare.physics.core.RigidBody;
	import flash.geom.Matrix3D;
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
		public var rotation:Matrix3D;
		public var totalForce:Vector3D;
		public var totalTorque:Vector3D;
		
		public function LightRigidBody() 
		{
			
		}
		
		public static function fromAWPRigidBody(rBody:RigidBody):LightRigidBody {
			var lightRigidBody:LightRigidBody = new LightRigidBody();
			lightRigidBody.linearVelocity = rBody.getVelocity().clone();
			lightRigidBody.angularVelocity = rBody.getAngularVelocity().clone();
			lightRigidBody.position = rBody.currentPosition.clone();
			lightRigidBody.rotation = rBody.currentOrientation.clone();
			lightRigidBody.totalForce = rBody.force.clone();
			lightRigidBody.totalTorque = rBody.torque.clone();
			return lightRigidBody;
		}
		
		public function applyToRigidBody(rBody:RigidBody):void {
			rBody.setOrientation(rotation.clone());
			rBody.setPosition(position.x,position.y,position.z);
			rBody.setLinearVelocity(linearVelocity.clone());
			rBody.setAngularVelocity(angularVelocity.clone());
			rBody.addForce(totalForce, new Vector3D());
			rBody.addTorque(totalTorque);
		}
		
		
	}

}