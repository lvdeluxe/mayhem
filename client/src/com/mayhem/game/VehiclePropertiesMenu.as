package com.mayhem.game 
{
	import com.bit101.components.HUISlider;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author availlant
	 */
	public class VehiclePropertiesMenu 
	{
		
		private var _visible:Boolean = false;
		private var _gManager:GameController;
		private var _container:Sprite;
		
		public function VehiclePropertiesMenu(stage:Stage, gManager:GameController, pt:Point) 
		{
			_gManager = gManager;
			_container = new Sprite();
			_container.x = pt.x;
			_container.y = pt.y;
			
			var sliderFriction:HUISlider = new HUISlider(_container, 10, 10, 'friction', onSlideFriction);
			sliderFriction.minimum = 0;
			sliderFriction.maximum = 1;
			sliderFriction.value = GameData.VEHICLE_FRICTION;
			
			var sliderGravity:HUISlider = new HUISlider(_container, 10, 22, 'gravity', onSlideGravity);
			sliderGravity.minimum = 0;
			sliderGravity.maximum = -500;
			sliderGravity.value = GameData.VEHICLE_GRAVITY;
			
			var sliderRestitution:HUISlider = new HUISlider(_container, 10, 34, 'restitution', onSlideRestitution);
			sliderRestitution.minimum = 0;
			sliderRestitution.maximum = 10;
			sliderRestitution.value = GameData.VEHICLE_RESTITUTION;
			
			var sliderAngularFactor:HUISlider = new HUISlider(_container, 10, 46, 'angular F', onSlideAngular);
			sliderAngularFactor.minimum = 0;
			sliderAngularFactor.maximum = 1;
			sliderAngularFactor.value = GameData.VEHICLE_ANG_FACTOR;
			
			var sliderMass:HUISlider = new HUISlider(_container, 10, 58, 'mass', onSlideMass);
			sliderMass.minimum = 0;
			sliderMass.maximum = 100;
			sliderMass.value = GameData.VEHICLE_MASS;
			
			var sliderLinearF:HUISlider = new HUISlider(_container, 10, 70, 'linear F', onSlideLinear);
			sliderLinearF.minimum = 0;
			sliderLinearF.maximum = 1;
			sliderLinearF.value = GameData.VEHICLE_LIN_FACTOR;
			
			var sliderAngSpeed:HUISlider = new HUISlider(_container, 10, 82, 'Angular Speed', onSlideAngSpeed);
			sliderAngSpeed.minimum = 50;
			sliderAngSpeed.maximum = 500;
			sliderAngSpeed.value = GameData.VEHICLE_ANG_VELOCITY;
			
			var sliderLinSpeed:HUISlider = new HUISlider(_container, 10, 94, 'Linear Speed', onSlideLinSpeed);
			sliderLinSpeed.minimum = 10000;
			sliderLinSpeed.maximum = 20000;
			sliderLinSpeed.value = GameData.VEHICLE_LIN_VELOCITY;			
			
			var camOffsetY:HUISlider = new HUISlider(_container, 10, 106, 'Camera Y Offset', onCamOffsetY);
			camOffsetY.minimum = 100;
			camOffsetY.maximum = 2000;
			camOffsetY.value = GameData.CAMERA_OFFSET_Y;
			
			var camOffsetZ:HUISlider = new HUISlider(_container, 10, 118, 'Camera Z Offset', onCamOffsetZ);
			camOffsetZ.minimum = 100;
			camOffsetZ.maximum = 5000;
			camOffsetZ.value = GameData.CAMERA_OFFSET_Z;
			
			var camRotateX:HUISlider = new HUISlider(_container, 10, 130, 'Camera X Rotation', onCamRotateX);
			camRotateX.minimum = Math.PI / 16;
			camRotateX.maximum = Math.PI / 2;
			camRotateX.value = GameData.CAMERA_ROTATION_X;
			
			var arenaFriction:HUISlider = new HUISlider(_container, 10, 142, 'Arena Friction', onArenaFriction);
			arenaFriction.minimum = 0;
			arenaFriction.maximum = 1;
			arenaFriction.value = GameData.ARENA_FRICTION;
			
			var arenaRestitution:HUISlider = new HUISlider(_container, 10, 154, 'Arena Restitution', onArenaRestitution);
			arenaRestitution.minimum = 0;
			arenaRestitution.maximum = 10;
			arenaRestitution.value = GameData.ARENA_RESTITUTION;
			
			stage.addChild(_container);				
			visible = _visible;
		}
		
		private function onArenaFriction(e:Event):void {
			var slider:HUISlider = e.currentTarget as HUISlider;
			ArenaFactory.instance.mainBody.friction = slider.value;
		}
		
		private function onArenaRestitution(e:Event):void {
			var slider:HUISlider = e.currentTarget as HUISlider;
			ArenaFactory.instance.mainBody.restitution = slider.value;
		}
		
		private function onCamRotateX(e:Event):void {
			var slider:HUISlider = e.currentTarget as HUISlider;
			GameData.CAMERA_ROTATION_X = slider.value
		}
		
		private function onCamOffsetY(e:Event):void {
			var slider:HUISlider = e.currentTarget as HUISlider;
			GameData.CAMERA_OFFSET_Y = slider.value
		}
		
		private function onCamOffsetZ(e:Event):void {
			var slider:HUISlider = e.currentTarget as HUISlider;
			GameData.CAMERA_OFFSET_Z = slider.value
		}
		
		private function onSlideFriction(e:Event):void {
			var slider:HUISlider = e.currentTarget as HUISlider;
			_gManager.getOwnerVehicle().body.friction = slider.value
		}
		private function onSlideRestitution(e:Event):void {
			var slider:HUISlider = e.currentTarget as HUISlider;
			_gManager.getOwnerVehicle().body.restitution = slider.value
		}
		private function onSlideMass(e:Event):void {
			var slider:HUISlider = e.currentTarget as HUISlider;
			_gManager.getOwnerVehicle().body.mass = slider.value
		}
		private function onSlideAngSpeed(e:Event):void {
			var slider:HUISlider = e.currentTarget as HUISlider;
			GameData.VEHICLE_ANG_VELOCITY= slider.value;
		}
		private function onSlideLinSpeed(e:Event):void {
			var slider:HUISlider = e.currentTarget as HUISlider;
			GameData.VEHICLE_LIN_VELOCITY = slider.value;
		}
		private function onSlideGravity(e:Event):void {
			var slider:HUISlider = e.currentTarget as HUISlider;
			_gManager.getOwnerVehicle().body.gravity = new Vector3D(0, slider.value, 0);
		}
		private function onSlideAngular(e:Event):void {
			var slider:HUISlider = e.currentTarget as HUISlider;
			_gManager.getOwnerVehicle().body.angularFactor = new Vector3D(slider.value, 1, slider.value);
		}
		private function onSlideLinear(e:Event):void {
			var slider:HUISlider = e.currentTarget as HUISlider;
			_gManager.getOwnerVehicle().body.linearFactor = new Vector3D(1, slider.value, 1);
		}
		
		
		public function set visible(value:Boolean):void {
			_visible = value;
			_container.visible = _visible;
		}
		
		public function get visible():Boolean {
			return _visible;
		}
		
	}

}