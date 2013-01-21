package com.mayhem.game 
{
	/**
	 * ...
	 * @author availlant
	 */
	import away3d.events.AssetEvent;
	import away3d.library.AssetLibrary;
	import away3d.events.LoaderEvent;
	import away3d.entities.Mesh;
	import away3d.library.assets.AssetType;
	import away3d.library.assets.BitmapDataAsset;
	import away3d.loaders.parsers.AWDParser;
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapCubeTexture;
	import away3d.textures.BitmapTexture;
	import away3d.textures.Texture2DBase;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	public class ModelsManager 
	{
		private static var _instance:ModelsManager;
		private static var _enableInstantiation:Boolean = false;
		private var _fullyLoadedCallback:Function;
		
		private var _allVehicleBitmaps:Vector.<Vector.<Bitmap>> = new Vector.<Vector.<Bitmap>>();
		private var _aiVehicleTexture:Bitmap;
		
		public var allArenaMeshes:Vector.<Mesh> = new Vector.<Mesh>();
		public var allVehicleMeshes:Vector.<Mesh> = new Vector.<Mesh>();
		
		[Embed(source = "/assets/Arena4.awd", mimeType = "application/octet-stream")]
		private var ArenaClass:Class;
		[Embed(source = "/assets/vehicles/vehicle_0/Vehicle.awd", mimeType = "application/octet-stream")]
		private var VehicleClass_0:Class;
		[Embed(source = "/assets/vehicles/vehicle_1/Vehicle.awd", mimeType = "application/octet-stream")]
		private var VehicleClass_1:Class;
		[Embed(source = "/assets/vehicles/vehicle_2/Vehicle.awd", mimeType = "application/octet-stream")]
		private var VehicleClass_2:Class;
		
		[Embed(source = "/assets/vehicles/AIVehicleTexture.jpg")]
		private var Vehicle_AI_Texture:Class;
		
		
		[Embed(source = "/assets/vehicles/vehicle_0/textures/VehicleTexture_0.jpg")]
		private var Vehicle_0_Texture_0:Class;
		[Embed(source = "/assets/vehicles/vehicle_0/textures/VehicleTexture_1.jpg")]
		private var Vehicle_0_Texture_1:Class;
		[Embed(source = "/assets/vehicles/vehicle_0/textures/VehicleTexture_2.jpg")]
		private var Vehicle_0_Texture_2:Class;
		[Embed(source = "/assets/vehicles/vehicle_0/textures/VehicleTexture_3.jpg")]
		private var Vehicle_0_Texture_3:Class;
		[Embed(source = "/assets/vehicles/vehicle_0/textures/VehicleTexture_4.jpg")]
		private var Vehicle_0_Texture_4:Class;		
		
		[Embed(source = "/assets/vehicles/vehicle_1/textures/VehicleTexture_0.jpg")]
		private var Vehicle_1_Texture_0:Class;
		[Embed(source = "/assets/vehicles/vehicle_1/textures/VehicleTexture_1.jpg")]
		private var Vehicle_1_Texture_1:Class;
		[Embed(source = "/assets/vehicles/vehicle_1/textures/VehicleTexture_2.jpg")]
		private var Vehicle_1_Texture_2:Class;
		[Embed(source = "/assets/vehicles/vehicle_1/textures/VehicleTexture_3.jpg")]
		private var Vehicle_1_Texture_3:Class;
		[Embed(source = "/assets/vehicles/vehicle_1/textures/VehicleTexture_4.jpg")]
		private var Vehicle_1_Texture_4:Class;		
		
		[Embed(source = "/assets/vehicles/vehicle_2/textures/VehicleTexture_0.jpg")]
		private var Vehicle_2_Texture_0:Class;
		[Embed(source = "/assets/vehicles/vehicle_2/textures/VehicleTexture_1.jpg")]
		private var Vehicle_2_Texture_1:Class;
		[Embed(source = "/assets/vehicles/vehicle_2/textures/VehicleTexture_2.jpg")]
		private var Vehicle_2_Texture_2:Class;
		[Embed(source = "/assets/vehicles/vehicle_2/textures/VehicleTexture_3.jpg")]
		private var Vehicle_2_Texture_3:Class;
		[Embed(source = "/assets/vehicles/vehicle_2/textures/VehicleTexture_4.jpg")]
		private var Vehicle_2_Texture_4:Class;		
		
		[Embed(source = "/assets/cubemap/skybox_2.jpg")]
		private var cubemap_posZ:Class;		
		[Embed(source = "/assets/cubemap/skybox_4.jpg")]
		private var cubemap_negZ:Class;		
		[Embed(source = "/assets/cubemap/skybox_3.jpg")]
		private var cubemap_posX:Class;		
		[Embed(source = "/assets/cubemap/skybox_1.jpg")]
		private var cubemap_negX:Class;	
		[Embed(source = "/assets/cubemap/skybox_top.jpg")]
		private var cubemap_posY:Class;
		[Embed(source = "/assets/cubemap/skybox_bottom.jpg")]
		private var cubemap_negY:Class;
		
		private var numVehicles:uint = 0;
		public var maxVehicles:uint = 3;
		
		
		public function ModelsManager() 
		{
			if (!_enableInstantiation) {
				throw new Error('This class is a Singleton, should not be instanciated!');
			}
		}
		
		public function getMaterialById(vehicleId:uint, textureId:uint):TextureMaterial {
			var bmp:Bitmap = _allVehicleBitmaps[vehicleId][textureId];
			var texture:BitmapTexture = new BitmapTexture(bmp.bitmapData)
			return new TextureMaterial(texture);
		}
		
		public function getVehicleByIds(vehicle_id:uint, texture_id:uint):Mesh {
			var mesh:Mesh = allVehicleMeshes[vehicle_id];
			var bmp:Bitmap = _allVehicleBitmaps[vehicle_id][texture_id];
			var texture:BitmapTexture = new BitmapTexture(bmp.bitmapData)
			mesh.material = new TextureMaterial(texture);
			return mesh;
		}
		
		public function getSkyboxTexture():BitmapCubeTexture {
			var posX:Bitmap = new cubemap_posX();
			var negX:Bitmap = new cubemap_negX();
			var posZ:Bitmap = new cubemap_posZ();
			var negZ:Bitmap = new cubemap_negZ();
			var posY:Bitmap = new cubemap_posY();
			var negY:Bitmap = new cubemap_negY();
			var bmpCubeText:BitmapCubeTexture = new BitmapCubeTexture(posX.bitmapData, negX.bitmapData, posY.bitmapData, negY.bitmapData, posZ.bitmapData, negZ.bitmapData);
			return bmpCubeText;
		}
		public static function get instance():ModelsManager {
			if (!_instance) {
				_enableInstantiation = true
				_instance = new ModelsManager();
				_enableInstantiation = false;
			}
			return _instance;
		}
		
		public function loadAllModels(pCallback:Function):void {
			_fullyLoadedCallback = pCallback;
			AssetLibrary.enableParser(AWDParser);
			_allVehicleBitmaps.push(new Vector.<Bitmap>());
			_allVehicleBitmaps.push(new Vector.<Bitmap>());
			_allVehicleBitmaps.push(new Vector.<Bitmap>());
			
			_allVehicleBitmaps[0].push(new Vehicle_0_Texture_0() as Bitmap);
			_allVehicleBitmaps[0].push(new Vehicle_0_Texture_1() as Bitmap);
			_allVehicleBitmaps[0].push(new Vehicle_0_Texture_2() as Bitmap);
			_allVehicleBitmaps[0].push(new Vehicle_0_Texture_3() as Bitmap);
			_allVehicleBitmaps[0].push(new Vehicle_0_Texture_4() as Bitmap);
			
			_allVehicleBitmaps[1].push(new Vehicle_1_Texture_0() as Bitmap);
			_allVehicleBitmaps[1].push(new Vehicle_1_Texture_1() as Bitmap);
			_allVehicleBitmaps[1].push(new Vehicle_1_Texture_2() as Bitmap);
			_allVehicleBitmaps[1].push(new Vehicle_1_Texture_3() as Bitmap);
			_allVehicleBitmaps[1].push(new Vehicle_1_Texture_4() as Bitmap);
			
			_allVehicleBitmaps[2].push(new Vehicle_2_Texture_0() as Bitmap);
			_allVehicleBitmaps[2].push(new Vehicle_2_Texture_1() as Bitmap);
			_allVehicleBitmaps[2].push(new Vehicle_2_Texture_2() as Bitmap);
			_allVehicleBitmaps[2].push(new Vehicle_2_Texture_3() as Bitmap);
			_allVehicleBitmaps[2].push(new Vehicle_2_Texture_4() as Bitmap);
			
			_aiVehicleTexture = new Vehicle_AI_Texture() as Bitmap;
			//loadTextures();
			loadArena();
		}
		
		public function getAIVehicleTexture():BitmapData {
			return _aiVehicleTexture.bitmapData;
		}
		
		public function getVehicleTextureByIds(vId:uint, tId:uint):BitmapData {
			return _allVehicleBitmaps[vId][tId].bitmapData;
		}
		
		private function onVehicleComplete(event:AssetEvent):void {
			if (event.asset.assetType == AssetType.MESH) {
				allVehicleMeshes.push(event.asset as Mesh);
			}
		}
		
		private function onArenaComplete(event:AssetEvent):void {
			if (event.asset.assetType == AssetType.MESH) {
				allArenaMeshes.push(event.asset as Mesh);
			}
		}
		private function onVehicleFullyLoaded(event:LoaderEvent):void {
			numVehicles++;
			switch(numVehicles) {
				case 1:
					loadVehicle_1();
					break;
				case 2:
					loadVehicle_2();
					break;
				case 3:
					AssetLibrary.removeEventListener(AssetEvent.ASSET_COMPLETE, onVehicleComplete);
					AssetLibrary.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onVehicleFullyLoaded);
					_fullyLoadedCallback();
					break;
			}
		}
		private function onArenaFullyLoaded(event:LoaderEvent):void {
			loadVehicle_0();
		}
		
		public function getRandomVehicleTexture():BitmapData {
			var rnd:uint = Math.floor(Math.random() * _allVehicleBitmaps.length)
			trace(rnd);
			return _allVehicleBitmaps[0][rnd].bitmapData;
		}
		
		private function loadVehicle_0():void {
			AssetLibrary.removeEventListener(AssetEvent.ASSET_COMPLETE, onArenaComplete);
			AssetLibrary.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onArenaFullyLoaded);
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, onVehicleComplete);
			AssetLibrary.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onVehicleFullyLoaded);
			AssetLibrary.loadData(new VehicleClass_0());
		}
		
		private function loadVehicle_1():void {
			AssetLibrary.loadData(new VehicleClass_1());
		}
		
		private function loadVehicle_2():void {
			AssetLibrary.loadData(new VehicleClass_2());
		}
		
		private function loadArena():void {
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, onArenaComplete);
			AssetLibrary.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onArenaFullyLoaded);
			AssetLibrary.loadData(new ArenaClass());
		}
		
	}

}