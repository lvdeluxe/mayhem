package com.mayhem.game 
{
	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.AwayStats
	import away3d.lights.DirectionalLight;
	import com.mayhem.multiplayer.GameUserVO;
	import flash.display.Stage;
	import flash.geom.Vector3D;
	import com.mayhem.signals.MultiplayerSignals;
	import com.mayhem.signals.GameSignals;
	
	/**
	 * ...
	 * @author availlant
	 */
	public class ThreeDeeController 
	{
		
		private var _view3D:View3D;	
		private var _light:DirectionalLight;
		private var _stage:Stage;
		private var _gameController:GameController;
		private var _vehicleSelector:VehicleSelector;
	
		public function ThreeDeeController(stage:Stage, proxy:Stage3DProxy) 
		{
			_stage = stage;		
			MultiplayerSignals.USER_LOADED.add(onUserLoaded);
			GameSignals.REMOVE_MENU.add(cleanup);
			setView(stage,proxy);
			setLights();			
			MaterialsFactory.initialize([_light]);			
			var stats:AwayStats = new AwayStats(_view3D)
			stage.addChild(stats);			
			ParticlesFactory.instance.initialize(_view3D.scene);
			CameraManager.instance.initialize(_view3D.camera);
			//_gameController = new GameController(stage, _view3D);
		}	
		
		private function onUserLoaded(user:GameUserVO):void {
			//_vehicleSelector = new VehicleSelector(_view3D);
			_vehicleSelector = new VehicleSelector(_view3D.scene, user.vehicleId, user.textureId);
			//_vehicleSelector = new VehicleSelector(_view3D.scene, ModelsManager.instance.getVehicleByIds(user.vehicleId, user.textureId));
		}
		
		private function cleanup():void {
			_vehicleSelector.remove();
			_gameController = new GameController(_stage, _view3D);
		}
		
		private function setView(pStage:Stage, pProxy:Stage3DProxy):void{						
			_view3D = new View3D();
			_view3D.stage3DProxy = pProxy;
			_view3D.shareContext = true;
			pStage.addChild(_view3D);			
			_view3D.camera.y = 2000
			_view3D.camera.z = -5000;
			_view3D.camera.rotationX = 45;
			_view3D.camera.lens.far = 50000;
		}
		
		private function setLights():void{			
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
			_view3D.scene.addChild(_light);
		}	
		
		public function render():void {	
			if (_vehicleSelector) {
				_vehicleSelector.doStuff();
			}
			if(_gameController)_gameController.renderGame();
			_view3D.render();
			if(_gameController)_gameController.checkVehicleCollision();
		}
		
		public function get renderer():View3D {
			return _view3D;
		}		
	}
}