package com.mayhem.game 
{
	import awayphysics.collision.dispatch.AWPCollisionObject;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author availlant
	 */
	public class CollisionData 
	{
		
		public var collider:AWPCollisionObject;
		public var collided:AWPCollisionObject;
		public var position:Vector3D;
		
		public function CollisionData(pCollider:AWPCollisionObject, pCollided:AWPCollisionObject, position:Vector3D) 
		{
			collider = pCollider;
			collided = pCollided;
			position = position;
		}
		
		public function equals(collisionData:CollisionData):Boolean {
			return collider == collisionData.collider && collided == collisionData.collided && collisionPosition.nearEquals(collisionData.collisionPosition, 0.00001);
		}
		
	}

}