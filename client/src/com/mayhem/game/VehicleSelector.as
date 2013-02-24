package com.mayhem.game 
{
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.materials.ColorMaterial;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.materials.methods.TripleFilteredShadowMapMethod;
	import away3d.materials.SkyBoxMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapCubeTexture;
	import away3d.textures.BitmapTexture;
	import away3d.textures.Texture2DBase;
	import com.mayhem.game.powerups.PowerupDefinition;
	import com.mayhem.multiplayer.GameUserVO;
	import com.mayhem.signals.MultiplayerSignals;
	import com.mayhem.signals.UISignals;
	import com.mayhem.ui.TexturesManager;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.utils.Dictionary;
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
		private var _numSlots:int
		private var _powerups:Vector.<PowerupDefinition>;
		private var _slotMeshes:Vector.<Mesh>;
		
		public function VehicleSelector(scene:Scene3D, vId:uint, tId:uint, numSlots:int,powerups:Vector.<PowerupDefinition>) 
		{
			_powerups = powerups;
			_numSlots = numSlots;
			_slotMeshes = new Vector.<Mesh>();
			_scene = scene;
			_textureId = tId;
			_vehicleId = vId;
			_vehicle = ModelsManager.instance.getVehicleByIds(vId, tId);
			_container = new ObjectContainer3D();
			_scene.addChild(_container);
			setVehicle();
			UISignals.SET_TEXTURE.add(updateTexture);
			UISignals.SET_VEHICLE.add(updateVehicle);
			UISignals.ADD_POWERUP_TO_SLOT.add(addPowerToSlot);
			UISignals.REMOVE_POWERUP_FROM_SLOT.add(removePowerup);
			MultiplayerSignals.SLOT_UNLOCKED.add(onSlotUnlocked);
			UISignals.ADD_POPUP.add(disableAllClicks);
			UISignals.REMOVE_POPUP.add(enableAllClicks);
			setPowerupSlots();
		}
		
		private function onSlotUnlocked(mainUser:GameUserVO, slot_id:String):void 
		{
			for (var i:uint = 0 ; i < _slotMeshes.length ; i++ ) {
				var mesh:Mesh = _slotMeshes[i];
				if (mesh.extra.index == slot_id.split("_")[1]) {
					mesh.material = new TextureMaterial(new BitmapTexture(Bitmap(new TexturesManager.EmptySlot()).bitmapData));
					return;
				}
			}
		}
		
		private function removePowerup(powerup_id:String):void {
			for each(var slot:Mesh in _slotMeshes) {
				if (slot.extra.assigned == powerup_id) {
					slot.material = new TextureMaterial(new BitmapTexture(Bitmap(new TexturesManager.EmptySlot()).bitmapData));
					slot.extra.assigned = "";
					return;
				}
			}
		}
		
		private function addPowerToSlot(powerup_id:String, position:Point):void {
			for (var i:uint = 0 ; i < _slotMeshes.length ; i++ ) {
				var mesh:Mesh = _slotMeshes[i];
				trace("mesh.extra.assigned",mesh.extra.assigned)
				if (mesh.extra.assigned == "") {
					mesh.extra.assigned = powerup_id;
					mesh.material = new TextureMaterial(new BitmapTexture(TexturesManager.getPowerupBitmapDataById(powerup_id)));
					return;
				}
			}
		}
		
		private function setPowerupSlots():void {
			var ang:Number = (90 / (_powerups.length - 1));
			var ang_inc:Number = -135
			var radius:Number = 450;
			for (var i:uint = 0 ; i < _powerups.length ; i++ ) {
				var bmp:Bitmap;
				if (i >= _numSlots) {
					bmp = new TexturesManager.LockedSlot() as Bitmap;
					bmp.smoothing = true;
				}else {
					bmp = new TexturesManager.EmptySlot() as Bitmap;
					bmp.smoothing = true;
				}
				var mesh:Mesh = new Mesh(new PlaneGeometry(), new TextureMaterial(new BitmapTexture(bmp.bitmapData)));
				mesh.extra = new Object()
				mesh.extra.index = i;
				mesh.extra.assigned = "";
				mesh.mouseEnabled = true;
				mesh.rotationX = -25
				mesh.addEventListener(MouseEvent3D.MOUSE_DOWN, onClickPowerupSlot);
				mesh.x = radius * Math.sin(ang_inc * Math.PI / 180);
				mesh.y = -100
				mesh.z = radius * Math.cos(ang_inc * Math.PI / 180);
				ang_inc -= ang;
				_slotMeshes.push(mesh);
				_scene.addChild(mesh);
			}
		}
		
		private function onClickPowerupSlot(e:MouseEvent3D):void 
		{
			var mesh:Mesh = e.currentTarget as Mesh;
			UISignals.POWERUP_SLOT_CLICKED.dispatch(mesh.extra.index, mesh.extra.assigned);
		}
		
		private function disableAllClicks():void {
			for (var i:uint = 0 ; i < _slotMeshes.length ; i++ ) {
				if (_slotMeshes[i].hasEventListener(MouseEvent3D.MOUSE_DOWN))
					_slotMeshes[i].removeEventListener(MouseEvent3D.MOUSE_DOWN, onClickPowerupSlot);
			}
		}
		
		private function enableAllClicks():void {
			for (var i:uint = 0 ; i < _slotMeshes.length ; i++ ) {
				if (!_slotMeshes[i].hasEventListener(MouseEvent3D.MOUSE_DOWN))
					_slotMeshes[i].addEventListener(MouseEvent3D.MOUSE_DOWN, onClickPowerupSlot);
			}
		}
		
		public function remove():void {
			_scene.removeChild(_container);
			
			UISignals.SET_TEXTURE.remove(updateTexture);
			UISignals.SET_VEHICLE.remove(updateVehicle);
			UISignals.ADD_POWERUP_TO_SLOT.remove(addPowerToSlot);
			UISignals.REMOVE_POWERUP_FROM_SLOT.remove(removePowerup);
			MultiplayerSignals.SLOT_UNLOCKED.remove(onSlotUnlocked);
			UISignals.ADD_POPUP.remove(disableAllClicks);
			UISignals.REMOVE_POPUP.remove(enableAllClicks);
		}
		
		private function updateVehicle(vehicleId:uint):void {
			_vehicleId = vehicleId;
			_container.removeChild(_vehicle);
			_vehicle = ModelsManager.instance.getVehicleByIds(vehicleId, _textureId);
			_vehicle.rotationY = 180;
			_vehicle.material.lightPicker = MaterialsFactory.mainLightPicker;
			_vehicle.material.bothSides = true;
			_container.addChild(_vehicle);
		}
		
		private function updateTexture(textureId:uint):void {
			_textureId = textureId;
			var mat:TextureMaterial = ModelsManager.instance.getMaterialById(_vehicleId, textureId);
			mat.bothSides = true;
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
			_vehicle.material.bothSides = true;
			CameraManager.instance.setCameraPosition(_container.position);
			
		}
		
	}

}