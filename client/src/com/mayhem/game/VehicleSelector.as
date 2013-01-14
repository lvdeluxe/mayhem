package com.mayhem.game 
{
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.materials.methods.TripleFilteredShadowMapMethod;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.CylinderGeometry;
	import com.mayhem.signals.UISignals;
	/**
	 * ...
	 * @author availlant
	 */
	public class VehicleSelector 
	{
		
		private var _scene:Scene3D;
		private var _support:Mesh;
		private var _vehicle:Mesh;
		private var _container:ObjectContainer3D;
		private var _textureId:uint;
		private var _vehicleId:uint;
		
		public function VehicleSelector(scene:Scene3D, vId:uint, tId:uint) 
		{
			_scene = scene;
			_textureId = tId;
			_vehicleId = vId;
			_vehicle = ModelsManager.instance.getVehicleByIds(vId, tId);
			_container = new ObjectContainer3D();
			_scene.addChild(_container);
			setVehicle();
			UISignals.SET_TEXTURE.add(updateTexture);
			UISignals.SET_VEHICLE.add(updateVehicle);
		}
		
		public function remove():void {
			_scene.removeChild(_container);
			UISignals.SET_TEXTURE.remove(updateTexture);
			UISignals.SET_VEHICLE.remove(updateVehicle);
		}
		
		private function updateVehicle(vehicleId:uint):void {
			_container.removeChild(_vehicle);
			_vehicle = ModelsManager.instance.getVehicleByIds(vehicleId, _textureId);
			_vehicle.rotationY = 180;
			_vehicle.material.lightPicker = MaterialsFactory.mainLightPicker;
			_container.addChild(_vehicle);
		}
		
		private function updateTexture(textureId:uint):void {
			_textureId = textureId;
			var mat:TextureMaterial = ModelsManager.instance.getMaterialById(_vehicleId, textureId);
			mat.lightPicker = MaterialsFactory.mainLightPicker;	
			mat.shadowMethod = new TripleFilteredShadowMapMethod(MaterialsFactory.mainLightPicker.lights[0]);
			_vehicle.material = mat;
		}
		
		public function doStuff():void {
			_container.rotationY++;
		}
		
		private function setVehicle():void {
			var supportGeometry:CylinderGeometry = new CylinderGeometry(500, 500, 10,32);
			var supportMaterial:ColorMaterial = new ColorMaterial(0x999999);
			supportMaterial.lightPicker = MaterialsFactory.mainLightPicker;	
			supportMaterial.shadowMethod = new TripleFilteredShadowMapMethod(MaterialsFactory.mainLightPicker.lights[0]);
			_support = new Mesh(supportGeometry, supportMaterial);
			_support.y = -150
			_container.addChild(_vehicle);
			_container.addChild(_support);
			_vehicle.rotationY = 180;
			_vehicle.material.lightPicker = MaterialsFactory.mainLightPicker;
			CameraManager.instance.setCameraPosition(_container.position);
			
		}
		
	}

}