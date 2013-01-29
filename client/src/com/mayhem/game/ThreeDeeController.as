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
	import away3d.filters.RadialBlurFilter3D;
	import com.mayhem.signals.UISignals;
	
	/**
	 * ...
	 * @author availlant
	 */
	public class ThreeDeeController 
	{
		
		private var _view3D:View3D;
		/*private var _first_view3D:View3D;
		private var _second_view3D:View3D;*/
		private var _light:DirectionalLight;
		private var _stage:Stage;
		private var _gameController:GameController;
		private var _vehicleSelector:VehicleSelector;
		private var _cameraToggleBool:Boolean;
	
		public function ThreeDeeController(stage:Stage, proxy:Stage3DProxy) 
		{
			_stage = stage;		
			MultiplayerSignals.USER_LOADED.add(onUserLoaded);
			GameSignals.REMOVE_MENU.add(startTheGame);
			setView(stage,proxy);
			/*setFirstView(stage,proxy);
			setSecondView(stage,proxy);*/
			setLights(_view3D);
			/*setLights(_first_view3D);
			setLights(_second_view3D);	*/		
			MaterialsFactory.initialize([_light]);			
			var stats:AwayStats = new AwayStats(_view3D)
			stage.addChild(stats);			
			ParticlesFactory.instance.initialize(_view3D.scene);
			CameraManager.instance.initialize(_view3D.camera);
			UISignals.CAMERA_TOGGLE.add(changeCameraView);
		}	
		
		private function setNewCamera(temp_view3D:View3D):void{
			ParticlesFactory.instance.initialize(temp_view3D.scene);
			CameraManager.instance.initialize(temp_view3D.camera);
		}
		
		private function changeCameraView(bool:Boolean):void{
			/*trace("received msg from ui: " + bool);
			_cameraToggleBool = bool;
			if(bool){
				setNewCamera(_view3D);
			}else{
				setNewCamera(_first_view3D);
			}*/
		}
		
		private function onUserLoaded(user:GameUserVO):void {
			_vehicleSelector = new VehicleSelector(_view3D.scene, user.vehicleId, user.textureId);
		}
		
		private function startTheGame():void {
			_view3D.camera.lens.far = 35000;
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
			_view3D.camera.lens.far = 35000;
		}
		
		/*private function setFirstView(pStage:Stage, pProxy:Stage3DProxy):void{						
				_first_view3D = new View3D();
				_first_view3D.stage3DProxy = pProxy;
				_first_view3D.shareContext = true;
				pStage.addChild(_first_view3D);			
				_first_view3D.camera.y = 2000
				_first_view3D.camera.z = -5000;
				_first_view3D.camera.rotationX = 45;
				_first_view3D.camera.lens.far = 35000;
			}
			
			private function setSecondView(pStage:Stage, pProxy:Stage3DProxy):void{						
				_second_view3D = new View3D();
				_second_view3D.stage3DProxy = pProxy;
				_second_view3D.shareContext = true;
				pStage.addChild(_second_view3D);			
				_second_view3D.camera.y = 2000
				_second_view3D.camera.z = -5000;
				_second_view3D.camera.rotationX = 45;
				_second_view3D.camera.lens.far = 35000;
				_second_view3D.filters3d = [ new RadialBlurFilter3D(2) ];
			}*/
		
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
			if(_gameController)_gameController.renderGame();
			/*if(_cameraToggleBool)*/_view3D.render();
			//if(!_cameraToggleBool)_first_view3D.render();
			if(_gameController)_gameController.checkVehicleCollision();
		}
		
		public function get renderer():View3D {
			//if(_cameraToggleBool){
			return _view3D;
			/*}else{
				return _first_view3D;
			}*/
		}		
	}
}