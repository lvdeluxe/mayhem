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
	
	public class ModelsManager 
	{
		private static var _instance:ModelsManager;
		private static var _enableInstantiation:Boolean = false;
		private var _fullyLoadedCallback:Function;
		
		public var allArenaMeshes:Vector.<Mesh> = new Vector.<Mesh>();
		public var allVehicleMeshes:Vector.<Mesh> = new Vector.<Mesh>();
		
		[Embed(source = "/assets/ArenaTest.awd", mimeType = "application/octet-stream")]
		private var ArenaClass:Class;
		[Embed(source = "/assets/Vehicle.awd", mimeType = "application/octet-stream")]
		private var VehicleClass:Class;
		
		
		public function ModelsManager() 
		{
			if (!_enableInstantiation) {
				throw new Error('This class is a Singleton, should not be instanciated!');
			}
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
			loadArena();
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