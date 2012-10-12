package com.pranks.game 
{
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.AwayStats
	import away3d.entities.Mesh;
	import away3d.lights.DirectionalLight;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.HardShadowMapMethod;
	import away3d.materials.methods.SoftShadowMapMethod;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.WireframePlane;
	import away3d.textures.BitmapTexture;
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.collision.shapes.AWPStaticPlaneShape;
	import awayphysics.dynamics.AWPDynamicsWorld;
	import awayphysics.dynamics.AWPRigidBody;
	import flare.primitives.Cube;
	import flash.display.Stage;
	import flash.display.BitmapData
	import away3d.materials.TextureMaterial;
	import com.pranks.signals.MultiplayerSignals;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
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
		private var _ownerBody:AWPRigidBody;
		private var _light:PointLight;
		private var _lightPicker:StaticLightPicker;
		private var _physicsWorld:AWPDynamicsWorld;
		private var _timeStep : Number = 1.0 / 60;
		
		public function GameManager(stage:Stage, proxy:Stage3DProxy) 
		{
			_allPlayers = new Dictionary();
			_view3D = new View3D();
			stage.addChild(_view3D);
			_view3D.stage3DProxy = proxy;
			_view3D.shareContext = true;
			_view3D.camera.y = 1200
			_view3D.camera.z = -1750;
			_view3D.camera.rotationX = 45;
			_view3D.camera.lens.far = 10000;
			
			_light = new PointLight();
			_light.color = 0x2ef5c6;
			_light.y = 5000;
			_light.z = 0;
			_view3D.scene.addChild(_light);
			
			_lightPicker = new StaticLightPicker([_light]);
			
			_physicsWorld = AWPDynamicsWorld.getInstance();
			_physicsWorld.initWithDbvtBroadphase();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
 
			stage.addChild(new AwayStats(_view3D));
			
			MultiplayerSignals.USER_CREATED.add(onUserCreated);
			MultiplayerSignals.USER_REMOVED.add(onUserRemoved);
			UserInputSignals.USER_HAS_MOVED.add(onUserMoved);
			//_view3D.scene.addChild(new WireframePlane(2500, 2500, 20, 20, 0xcc0000, 1, WireframePlane.ORIENTATION_XZ));
			
			var material : ColorMaterial = new ColorMaterial(0x252525);
			material.lightPicker = _lightPicker;
			material.ambientColor = 0x0000cc;
			var mesh:Mesh = new Mesh(new PlaneGeometry(2500, 2500), material);
			
			var groundShape : AWPStaticPlaneShape = new AWPStaticPlaneShape(new Vector3D(0, 1, 0));
			var groundRigidbody : AWPRigidBody = new AWPRigidBody(groundShape, mesh, 0);
			_physicsWorld.addRigidBody(groundRigidbody);
			//material.shadowMethod = new HardShadowMapMethod(_light);
			//mesh.castsShadows = true;
			
			//mesh.mouseEnabled = true;
			//mesh.addEventListener(MouseEvent3D.MOUSE_UP, onMouseUp);
			_view3D.scene.addChild(mesh);
		}
		
		public function renderPhysics():void {
			_physicsWorld.step(_timeStep, 1, _timeStep);
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
					_ZForce = -10;
					break;
			}
			//_ownerCube.x += _XForce;
			//_ownerCube.z += _ZForce;
			_ownerBody.applyCentralForce(new Vector3D(_XForce,0,_ZForce));
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
			var cubeMaterial:ColorMaterial = new ColorMaterial(color);
			cubeMaterial.lightPicker = _lightPicker;
			
			var cG:CubeGeometry = new CubeGeometry(100, 100, 100);
			var cube:Mesh = new Mesh(cG, cubeMaterial);
			cube.x = coords.x;
			cube.z = coords.y;
			cube.y = 500;			
			
			var boxShape : AWPBoxShape = new AWPBoxShape(100, 100, 100);
			var body:AWPRigidBody = new AWPRigidBody(boxShape, cube, 1);
			body.gravity = new Vector3D(0,-1,0);
			body.friction = .9;
			body.ccdSweptSphereRadius = 0.5;
			body.ccdMotionThreshold = 1;
			body.position = new Vector3D(coords.x, 1000,coords.y);
			_physicsWorld.addRigidBody(body);
			
			_view3D.scene.addChild(cube);		
			if (isMainUser){
				_ownerCube = cube;
				_ownerBody = body;
			}
			return cube;
		}
		
		public function get renderer():View3D {
			return _view3D;
		}
		
		
		
	}

}