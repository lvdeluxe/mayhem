package com.mayhem.game.powerups 
{
	import away3d.bounds.BoundingSphere;
	import away3d.containers.Scene3D;
	import away3d.core.pick.PickingCollisionVO;
	import away3d.core.pick.RaycastPicker;
	import away3d.entities.Mesh;
	import away3d.tools.utils.Ray;
	import awayphysics.collision.dispatch.AWPRay;
	import awayphysics.events.AWPEvent;
	import com.mayhem.game.GameController;
	import com.mayhem.game.GameData;
	import com.mayhem.game.MovingAICube;
	import com.mayhem.game.MovingCube;
	import com.mayhem.game.ParticlesFactory;
	import com.mayhem.signals.GameSignals;
	import com.mayhem.signals.MultiplayerSignals;
	import com.mayhem.signals.PowerUpsSignals;
	import com.mayhem.signals.UISignals;
	import com.mayhem.signals.UserInputSignals;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author availlant
	 */
	public class PowerupsManager 
	{
		
		private var _gameController:GameController;
		
		public function PowerupsManager(gameController:GameController) 
		{
			_gameController = gameController;
			PowerUpsSignals.PUP_EXPLOSION.add(triggerExplosion);
			PowerUpsSignals.PUP_INVISIBILITY.add(triggerInvisibility);
			PowerUpsSignals.PUP_RANDOM_MAYHEM.add(triggerRandomMayhem);
			PowerUpsSignals.PUP_SHIELD.add(triggerShield);
			PowerUpsSignals.PUP_BEAM.add(triggerBeam);
			GameSignals.REFILL_POWERUP.add(onPowerUpRefill);
			MultiplayerSignals.POWERUP_TRIGGERED.add(onPowerUpTriggered);
		}
		
		private function onPowerUpTriggered(mess:PowerUpMessage):void {
			if (mess.triggerdBy != _gameController.getOwnerVehicle().user.uid) {
				switch(mess.powerUpId) {
					case PowerUpMessage.POWERUP_EXPLOSION:
						_gameController.getVehicleById(mess.triggerdBy).setExplosionState();
						for each(var eData:ExplosionData in mess.targets) {
							var cube:MovingCube = _gameController.getVehicleById(eData.target);
							cube.body.applyCentralImpulse(eData.impulse);
						}
						break;
					case PowerUpMessage.POWERUP_INVISIBILITY:
						_gameController.getVehicleById(mess.triggerdBy).setInvisibilityState(0);
						break;
					case PowerUpMessage.POWERUP_SHIELD:
						_gameController.getVehicleById(mess.triggerdBy).setShieldState();
						break;
					case PowerUpMessage.POWERUP_BEAM:
						for each(var eData3:ExplosionData in mess.targets) {
							var cube3:MovingCube = _gameController.getVehicleById(eData3.target);
							cube3.body.applyCentralImpulse(eData3.impulse);
						}
						_gameController.getVehicleById(mess.triggerdBy).setBeamState();
						break;
					case PowerUpMessage.POWERUP_RANDOM_MAYHEM:
						for each(var eData2:ExplosionData in mess.targets) {
							var cube2:MovingCube = _gameController.getVehicleById(eData2.target);
							cube2.body.applyCentralImpulse(eData2.impulse);
						}
						var vehicle1:MovingCube = _gameController.getVehicleById(mess.targets[0].target);
						var vehicle2:MovingCube = _gameController.getVehicleById(mess.targets[1].target);
						var vehicle3:MovingCube = _gameController.getVehicleById(mess.targets[2].target);
						_gameController.getVehicleById(mess.triggerdBy).setRandomMayhemState(vehicle1.body.position.clone(),vehicle2.body.position.clone(),vehicle3.body.position.clone());
						break;
				}
				
			}
		}
		
		private function onPowerUpRefill(cube:MovingCube):void {
			if (cube.user.isMainUser) {
				cube.powerupRefill++;
				if (cube.powerupRefill >= GameData.POWERUP_FULL) {
					cube.powerupRefill = GameData.POWERUP_FULL;
				}
				UISignals.OWNER_POWERUP_FILL.dispatch(cube.powerupRefill);
			}else if(cube is MovingAICube && _gameController.isAIMAster){
				cube.powerupRefill++;
				if (cube.powerupRefill > GameData.POWERUP_FULL) {
					cube.powerupRefill = GameData.POWERUP_FULL;
					triggerRandomPowerup(cube);
					cube.powerupRefill = 0;
				}
			}
		}
		
		private function triggerRandomPowerup(pCube:MovingCube):void {
			triggerInvisibility(pCube);
		}
		
		
		
		private function triggerShield(pCube:MovingCube):void {
			pCube.powerupRefill = 0;
			UISignals.OWNER_POWERUP_FILL.dispatch(pCube.powerupRefill);
			pCube.setShieldState();		
			var message:PowerUpMessage = new PowerUpMessage();
			message.triggerdBy = pCube.user.uid;
			message.powerUpId = PowerUpMessage.POWERUP_SHIELD;
			UserInputSignals.POWERUP_TRIGGER.dispatch(message);
		}
		
		private function triggerInvisibility(pCube:MovingCube):void {
			pCube.powerupRefill = 0;
			UISignals.OWNER_POWERUP_FILL.dispatch(pCube.powerupRefill);
			pCube.setInvisibilityState(0.25);
			var message:PowerUpMessage = new PowerUpMessage();
			message.triggerdBy = pCube.user.uid;
			message.powerUpId = PowerUpMessage.POWERUP_INVISIBILITY;
			UserInputSignals.POWERUP_TRIGGER.dispatch(message);
		}
		
		private function triggerRandomMayhem(pCube:MovingCube):void {
			pCube.powerupRefill = 0;
			UISignals.OWNER_POWERUP_FILL.dispatch(pCube.powerupRefill);
			var vectorVehicles:Vector.<MovingCube> = new Vector.<MovingCube>();
			for each(var cube:MovingCube in _gameController.allPlayers) {
				if(pCube!=cube)vectorVehicles.push(cube);
			}
			var rnd1:uint = Math.floor(Math.random() * vectorVehicles.length);
			var vehicle1:MovingCube = vectorVehicles.splice(rnd1,1)[0];
			var rnd2:uint = Math.floor(Math.random() * vectorVehicles.length);
			var vehicle2:MovingCube = vectorVehicles.splice(rnd2,1)[0];
			var rnd3:uint = Math.floor(Math.random() * vectorVehicles.length);
			var vehicle3:MovingCube = vectorVehicles.splice(rnd3, 1)[0];
			
			var force1:Vector3D = vehicle1.body.position.subtract(pCube.body.position);
			force1.normalize();
			force1.y = 0;
			force1.scaleBy(200);
			vehicle1.body.applyCentralImpulse(force1);
			var explosion1:ExplosionData = new ExplosionData();
			explosion1.impulse = force1;
			explosion1.target = vehicle1.user.uid;			
			
			var force2:Vector3D = vehicle2.body.position.subtract(pCube.body.position);
			force2.normalize();
			force2.y = 0;
			force2.scaleBy(200);
			vehicle2.body.applyCentralImpulse(force2)
			var explosion2:ExplosionData = new ExplosionData();
			explosion2.impulse = force2;
			explosion2.target = vehicle2.user.uid;
			
			var force3:Vector3D = vehicle3.body.position.subtract(pCube.body.position);
			force3.normalize();
			force3.y = 0;
			force3.scaleBy(200);
			vehicle3.body.applyCentralImpulse(force3);
			var explosion3:ExplosionData = new ExplosionData();
			explosion3.impulse = force3;
			explosion3.target = vehicle3.user.uid;
			
			pCube.setRandomMayhemState(vehicle1.body.position,vehicle2.body.position,vehicle3.body.position)
			
			var message:PowerUpMessage = new PowerUpMessage();
			message.triggerdBy = pCube.user.uid;
			message.powerUpId = PowerUpMessage.POWERUP_RANDOM_MAYHEM;
			message.targets = new Vector.<ExplosionData>();
			message.targets.push(explosion1, explosion2, explosion3);
			UserInputSignals.POWERUP_TRIGGER.dispatch(message);
		}
		
		private function triggerBeam(pCube:MovingCube):void {
			pCube.setBeamState();
			var r:Ray = new Ray();
			var message:PowerUpMessage = new PowerUpMessage();
			message.triggerdBy = pCube.user.uid;
			message.powerUpId = PowerUpMessage.POWERUP_BEAM;
			message.targets = new Vector.<ExplosionData>();
			
			for each(var vehicle:MovingCube in _gameController.allPlayers) {
				if(pCube != vehicle){
					var sphere:BoundingSphere
					var intersect:Boolean = r.intersectsSphere(pCube.body.position, pCube.body.front, vehicle.body.position, 300);
					if (intersect) {
						var force:Vector3D = pCube.body.front.clone();
						force.scaleBy(200);
						vehicle.body.applyCentralImpulse(force);
						var explosion:ExplosionData = new ExplosionData();
						explosion.impulse = force;
						explosion.target = vehicle.user.uid;
						message.targets.push(explosion);
					}
				}
			}			
			UserInputSignals.POWERUP_TRIGGER.dispatch(message);
		}
		
		
		private function triggerExplosion(pCube:MovingCube):void {
			pCube.powerupRefill = 0;
			UISignals.OWNER_POWERUP_FILL.dispatch(pCube.powerupRefill);
			pCube.setExplosionState();
			
			var radius:Number = 2001;
			var maxForce:Number = GameData.EXPLOSION_FORCE;
			for each(var cube:MovingCube in _gameController.allPlayers) {
				if (cube != pCube)
				var dist:Number = Vector3D.distance(pCube.body.position, cube.body.position);
				if (dist <= radius) {
					var data:ExplosionData = new ExplosionData();
					data.target = cube.user.uid;
					var force:Number = ((radius - dist) * maxForce / radius);
					var forceVector:Vector3D = cube.body.position.subtract(pCube.body.position)
					forceVector.normalize();
					forceVector.scaleBy(force * 5);
					cube.body.applyCentralImpulse(forceVector);
					data.impulse = forceVector;
					message.targets.push(data);
				}
			}
			
			var message:PowerUpMessage = new PowerUpMessage();
			message.triggerdBy = pCube.user.uid;
			message.powerUpId = PowerUpMessage.POWERUP_EXPLOSION;
			UserInputSignals.POWERUP_TRIGGER.dispatch(message);
		}
	}

}