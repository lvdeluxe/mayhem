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
		
		private var _visible:Boolean = true;
		private var _gManager:GameManager;
		private var _container:Sprite;
		
		public function VehiclePropertiesMenu(stage:Stage, gManager:GameManager, pt:Point) 
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
			sliderGravity.maximum = -100;
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
			sliderLinSpeed.minimum = 50;
			sliderLinSpeed.maximum = 5000;
			sliderLinSpeed.value = GameData.VEHICLE_LIN_VELOCITY;
			
			stage.addChild(_container);	
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
			_gManager.getOwnerVehicle().body.linearFactor = new Vector3D(slider.value, 1, slider.value);
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