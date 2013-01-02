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
	import away3d.loaders.parsers.AWDParser;
	import away3d.textures.BitmapCubeTexture;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	public class ModelsManager 
	{
		private static var _instance:ModelsManager;
		private static var _enableInstantiation:Boolean = false;
		private var _fullyLoadedCallback:Function;
		
		private var _allVehicleBitmaps:Vector.<Bitmap> = new Vector.<Bitmap>();
		private var _aiVehicleTexture:Bitmap;
		
		public var allArenaMeshes:Vector.<Mesh> = new Vector.<Mesh>();
		public var allVehicleMeshes:Vector.<Mesh> = new Vector.<Mesh>();
		
		[Embed(source = "/assets/ArenaTest.awd", mimeType = "application/octet-stream")]
		private var ArenaClass:Class;
		[Embed(source = "/assets/Vehicle.awd", mimeType = "application/octet-stream")]
		private var VehicleClass:Class;
		
		[Embed(source = "/assets/AIVehicleTexture.jpg")]
		private var Vehicle_AI_Texture:Class;
		[Embed(source = "/assets/VehicleTexture_0.jpg")]
		private var Vehicle_Texture_0:Class;
		[Embed(source = "/assets/VehicleTexture_1.jpg")]
		private var Vehicle_Texture_1:Class;
		[Embed(source = "/assets/VehicleTexture_2.jpg")]
		private var Vehicle_Texture_2:Class;
		[Embed(source = "/assets/VehicleTexture_3.jpg")]
		private var Vehicle_Texture_3:Class;
		[Embed(source = "/assets/VehicleTexture_4.jpg")]
		private var Vehicle_Texture_4:Class;		
		
		[Embed(source = "/assets/cubemap/skybox3.jpg")]
		private var cubemap_posZ:Class;		
		[Embed(source = "/assets/cubemap/skybox1.jpg")]
		private var cubemap_negZ:Class;		
		[Embed(source = "/assets/cubemap/skybox4.jpg")]
		private var cubemap_posX:Class;		
		[Embed(source = "/assets/cubemap/skybox2.jpg")]
		private var cubemap_negX:Class;	
		[Embed(source = "/assets/cubemap/skybox6.jpg")]
		private var cubemap_posY:Class;
		[Embed(source = "/assets/cubemap/skybox5.jpg")]
		private var cubemap_negY:Class;
		
		
		public function ModelsManager() 
		{
			if (!_enableInstantiation) {
				throw new Error('This class is a Singleton, should not be instanciated!');
			}
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
			_allVehicleBitmaps.push(new Vehicle_Texture_0() as Bitmap);
			_allVehicleBitmaps.push(new Vehicle_Texture_1() as Bitmap);
			_allVehicleBitmaps.push(new Vehicle_Texture_2() as Bitmap);
			_allVehicleBitmaps.push(new Vehicle_Texture_3() as Bitmap);
			_allVehicleBitmaps.push(new Vehicle_Texture_4() as Bitmap);
			_aiVehicleTexture = new Vehicle_AI_Texture() as Bitmap;
			//loadTextures();
			loadArena();
		}
		
		public function getAIVehicleTexture():BitmapData {
			return _aiVehicleTexture.bitmapData;
		}
		
		
		
		private function onVehicleComplete(event:AssetEvent):void {
			trace(event.asset.assetType)
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
			_fullyLoadedCallback();
		}
		private function onArenaFullyLoaded(event:LoaderEvent):void {
			loadVehicle();
		}
		
		public function getRandomVehicleTexture():BitmapData {
			var rnd:uint = Math.floor(Math.random() * _allVehicleBitmaps.length)
			trace(rnd);
			return _allVehicleBitmaps[rnd].bitmapData;
		}
		
		private function loadVehicle():void {
			AssetLibrary.removeEventListener(AssetEvent.ASSET_COMPLETE, onArenaComplete);
			AssetLibrary.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onArenaFullyLoaded);
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, onVehicleComplete);
			AssetLibrary.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onVehicleFullyLoaded);
			AssetLibrary.loadData(new VehicleClass())
		}
		private function loadArena():void {
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, onArenaComplete);
			AssetLibrary.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onArenaFullyLoaded);
			AssetLibrary.loadData(new ArenaClass())
		}
		
	}

}