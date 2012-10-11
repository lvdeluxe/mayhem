package com.pranks.game 
{
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.AwayStats
	import away3d.entities.Mesh;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.WireframePlane;
	import away3d.textures.BitmapTexture;
	import flare.primitives.Cube;
	import flash.display.Stage;
	import flash.display.BitmapData
	import away3d.materials.TextureMaterial;
	import com.pranks.signals.MultiplayerSignals;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.events.Event;
	import com.pranks.signals.UserInputSignals;
	
	/**
	 * ...
	 * @author availlant
	 */
	public class GameManager 
	{
		
		private var _view3D:View3D
		private var _hoverController:HoverController;
		private var _allPlayers:Dictionary;
		private var _ZForce:Number = 0;
		private var _XForce:Number = 0;
		private var _ownerCube:Mesh;	
		
		public function GameManager(stage:Stage, proxy:Stage3DProxy) 
		{
			_allPlayers = new Dictionary();
			_view3D = new View3D();
			stage.addChild(_view3D);
			_view3D.stage3DProxy = proxy;
			_view3D.shareContext = true;
			_view3D.camera.y = 3000
			_view3D.camera.z = 0;
			_view3D.camera.rotationX = 90;
			trace(_view3D.camera.z)
			_view3D.camera.lens.far = 10000;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
 
			stage.addChild(new AwayStats(_view3D));
			
			MultiplayerSignals.USER_CREATED.add(onUserCreated);
			MultiplayerSignals.USER_REMOVED.add(onUserRemoved);
			UserInputSignals.USER_HAS_MOVED.add(onUserMoved);
			_view3D.scene.addChild(new WireframePlane(2500, 2500, 20, 20, 0xcc0000, 1, WireframePlane.ORIENTATION_XZ));
		}
		
		private function onKeyUp(event:KeyboardEvent):void {
			switch(event.keyCode) {
				case Keyboard.LEFT:
					_XForce = 0;
					break;
				case Keyboard.RIGHT:
					_XForce = 0;
					break;
				case Keyboard.UP:
					_ZForce = 0;
					break;
				case Keyboard.DOWN:
					_ZForce = 0
					break;
			}
		}
		private function onKeyDown(event:KeyboardEvent):void {
			switch(event.keyCode) {
				case Keyboard.LEFT:
					_XForce = -10;
					break;
				case Keyboard.RIGHT:
					_XForce = 10;
					break;
				case Keyboard.UP:
					_ZForce = 10;
					break;
				case Keyboard.DOWN:
					_ZForce = -10
					break;
			}
			_ownerCube.x += _XForce;
			_ownerCube.z += _ZForce;
			UserInputSignals.USER_IS_MOVING.dispatch(_ownerCube.position);
		}
		
		private function onUserMoved(userId:String, newCoords:Point):void {
			var cube:Mesh = _allPlayers[userId];
			if(cube != _ownerCube){
				cube.x = newCoords.x;
				cube.z = newCoords.y;
			}
		}
		private function onUserRemoved(userId:String):void {
			trace("yo2",userId)
			_view3D.scene.removeChild(_allPlayers[userId]);
			delete _allPlayers[userId];
		}
		private function onUserCreated(dataObject:Object):void {
			_allPlayers[dataObject.uid] = createCube(dataObject.coords,dataObject.isMainUser);
		}
		
		private function createCube(coords:Point, isMainUser:Boolean):Mesh {
			var color:Number = isMainUser ? 0xcc0000 : 0x0000cc;
			var cubeBmd:BitmapData = new BitmapData(128, 128, false, color);
			//cubeBmd.perlinNoise(7, 7, 5, 12345, true, true, 7, !isMainUser);
			var cubeMaterial:TextureMaterial = new TextureMaterial(new BitmapTexture(cubeBmd));
			
			var cG:CubeGeometry = new CubeGeometry(100, 100, 100);
			var cube:Mesh = new Mesh(cG, cubeMaterial);
			cube.x = coords.x;
			cube.z = coords.y;
			cube.y = 50;			
			_view3D.scene.addChild(cube);		
			if (isMainUser)
				_ownerCube = cube;
			return cube;
		}
		
		public function get renderer():View3D {
			return _view3D;
		}
		
		
		
	}

}