package com.mayhem.game 
{
	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.AwayStats
	import away3d.filters.BlurFilter3D;
	import away3d.filters.HueSaturationFilter3D;
	import away3d.lights.DirectionalLight;
	import com.mayhem.game.powerups.PowerupDefinition;
	import com.mayhem.game.powerups.PowerupSlot;
	import com.mayhem.multiplayer.CoinsPackage;
	import com.mayhem.multiplayer.GameUserVO;
	import com.mayhem.SoundsManager;
	import flash.display.Stage;
	import flash.geom.Vector3D;
	import com.mayhem.signals.MultiplayerSignals;
	import com.mayhem.signals.GameSignals;
	import away3d.filters.RadialBlurFilter3D;
	import com.mayhem.signals.UISignals;
	
	/**
	 * ...
	 * @author availlant
	 */
	public class ThreeDeeController 
	{
		
		private var _view3D:FilteredView3D;
		private var _light:DirectionalLight;
		private var _stage:Stage;
		private var _gameController:GameController;
		private var _vehicleSelector:VehicleSelector;
		private var _cameraToggleBool:Boolean;
		private var _user:GameUserVO;
		private var _allPowerups:Vector.<PowerupDefinition>;
	
		public function ThreeDeeController(stage:Stage, proxy:Stage3DProxy) 
		{
			_stage = stage;		
			MultiplayerSignals.USER_LOADED.add(onUserLoaded);
			GameSignals.REMOVE_MENU.add(startTheGame);
			setView(stage,proxy);
			setLights(_view3D);
			MaterialsFactory.initialize([_light]);			
			var stats:AwayStats = new AwayStats(_view3D, true)
			//stage.addChild(stats);		
			stats.y = 70
			ParticlesFactory.instance.initialize(_view3D.scene);
			CameraManager.instance.initialize(_view3D.camera);
			UISignals.BACK_TO_SELECTOR.add(backToSelector);
		}	
		
		private function backToSelector():void {
			_view3D.camera.lens.far = 10000;
			_gameController.remove();
			_gameController = null;
			_vehicleSelector = new VehicleSelector(_view3D.scene, _user.vehicleId, _user.textureId, _user.powerupSlots, _allPowerups);
		}
		
		private function onUserLoaded(user:GameUserVO, powerups:Vector.<PowerupDefinition>, coins:Vector.<CoinsPackage>, slots:Vector.<PowerupSlot>):void {
			SoundsManager.initialize(user.hasMusic, _view3D);
			_user = user;
			_allPowerups = powerups;
			_vehicleSelector = new VehicleSelector(_view3D.scene, user.vehicleId, user.textureId, user.powerupSlots, powerups);
			SoundsManager.startMenuLoop();
		}
		
		private function startTheGame():void {
			_view3D.camera.lens.far = 35000;
			_vehicleSelector.remove();
			_vehicleSelector = null;
			_gameController = new GameController(_stage, _view3D);
		}
		
		private function setView(pStage:Stage, pProxy:Stage3DProxy):void{						
			_view3D = new FilteredView3D();
			_view3D.stage3DProxy = pProxy;
			_view3D.shareContext = true;
			pStage.addChild(_view3D);			
			_view3D.camera.y = 2000
			_view3D.camera.z = -5000;
			_view3D.camera.rotationX = 45;
			_view3D.camera.lens.far = 35000;
			_view3D.setFilters();
			
		}
		
		private function setLights(temp_view3D:View3D):void{			
			_light = new DirectionalLight();
			_light.diffuse = 1;
			_light.color = 0xFFFFFF;
			_light.ambient = 0.5;
			_light.castsShadows = true;
			_light.ambientColor = 0xFFFFFF;
			_light.specular = 0.8;
			_light.shaderPickingDetails = true;
			_light.direction = new Vector3D(-0.07848641852943786, -0.9962904287522878, -0.035288293852277955);
			_light.name = "pointlight_0";
			temp_view3D.scene.addChild(_light);
		}	
		
		public function render():void {	
			if (_vehicleSelector) {
				_vehicleSelector.doStuff();
			}			
			//_view3D.filters3d = [new BlurFilter3D(10,10)]
			_view3D.render();
			if (_gameController) {
				_gameController.renderGame();
				_gameController.checkVehicleCollision();
			}			
		}
		
		public function get renderer():View3D {
			return _view3D;
		}		
	}
}