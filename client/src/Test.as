package  
{
	import away3d.containers.View3D;
	import away3d.debug.Trident;
	import away3d.entities.Mesh;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.LightPickerBase;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.PlaneGeometry;
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.collision.shapes.AWPStaticPlaneShape;
	import awayphysics.dynamics.AWPRigidBody;
	import flash.display.Sprite;
	import awayphysics.dynamics.AWPDynamicsWorld;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author availlant
	 */
	public class Test extends Sprite
	{
		private var _view3D:View3D;
		private var _cube:AWPRigidBody;
		private var _light:PointLight;
		private var _lightPicker:LightPickerBase;
		private var _physicsWorld:AWPDynamicsWorld;
		
		private var downPressed:Boolean = false;
		private var upPressed:Boolean = false;
		private var rightPressed:Boolean = false;
		private var leftPressed:Boolean = false;
		
		public function Test() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			setScene();
			setLights();
			setPhysics();
			setControls();
			setObjects();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function setScene():void {
			_view3D = new View3D();
			stage.addChild(_view3D);
			//_view3D.stage3DProxy = pProxy;
			//_view3D.shareContext = true;

			_view3D.camera.y = 2000
			_view3D.camera.z = -5000;
			_view3D.camera.rotationX = 45;
			_view3D.camera.lens.far = 10000;
		}
		
		private function setLights():void{			
			_light = new PointLight();
			_light.specular = 0.8;
			_light.y = 1000;
			_light.color = 0xFFFFFF;
			_light.z = 0;
			_light.x = 0;
			_light.castsShadows = false;
			_light.shaderPickingDetails = false;
			_light.ambientColor = 0xFFFFFF;
			_light.radius = Number.MAX_VALUE ;
			_light.fallOff = Number.MAX_VALUE ;
			_light.ambient = 0.5;
			_light.diffuse = 1;
			_light.name = "pointlight_0";
			_lightPicker = new StaticLightPicker([_light]);
		}
		
		private function setPhysics():void{			
			_physicsWorld = AWPDynamicsWorld.getInstance();					
			_physicsWorld.initWithDbvtBroadphase();
			//_physicsWorld.collisionCallbackOn = true;			
			//_debugDraw = new AWPDebugDraw(_view3D, _physicsWorld);
		}
		
		
		private function setControls():void {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
		}
		private function setObjects():void {			
			var cG:CubeGeometry = new CubeGeometry(100, 100, 100);
			var mat:ColorMaterial = new ColorMaterial(0xcc0000);
			mat.lightPicker = _lightPicker;
			var mesh:Mesh = new Mesh(cG, mat);
			mesh.addChild(new Trident(100));
			
			var carShape : AWPBoxShape = new AWPBoxShape(100, 100, 100);
			
			_cube = new AWPRigidBody(carShape, mesh, 1);
			_cube.gravity = new Vector3D(0,-1,0);
			_cube.friction = 1;
			_cube.restitution = 0.1
			_cube.ccdSweptSphereRadius = 0.5;
			_cube.ccdMotionThreshold = 1;
			
			_cube.anisotropicFriction = new Vector3D()
			
			_cube.angularDamping = 0.99
			_cube.angularFactor= new Vector3D(0.25,1,0.25);
			_cube.position = new Vector3D(0, 50, 0);
			
			_view3D.scene.addChild(mesh);
			_physicsWorld.addRigidBody(_cube)
			
			var floorMat:ColorMaterial = new ColorMaterial(0x0000cc);
			floorMat.lightPicker = _lightPicker;
			var floorMesh:Mesh=new Mesh(new PlaneGeometry(50000, 50000),floorMat);
			_view3D.scene.addChild(floorMesh);
			
			var groundShape : AWPStaticPlaneShape = new AWPStaticPlaneShape(new Vector3D(0, 1, 0));
			var groundRigidbody : AWPRigidBody = new AWPRigidBody(groundShape, floorMesh, 0);
			_physicsWorld.addRigidBody(groundRigidbody);
			
			
		}
		
		private function onKeyDown(event:KeyboardEvent):void {
			switch(event.keyCode) {
				case Keyboard.LEFT:
					leftPressed = true;
					break;
				case Keyboard.RIGHT:
					rightPressed = true;
					break;
				case Keyboard.UP:
					upPressed = true;
					break;
				case Keyboard.DOWN:
					downPressed = true;
					break;
			}
		}
		
		private function onKeyUp(event:KeyboardEvent):void {
			switch(event.keyCode) {
				case Keyboard.LEFT:
					leftPressed = false;
					break;
				case Keyboard.RIGHT:
					rightPressed = false;
					break;
				case Keyboard.UP:
					upPressed = false;
					break;
				case Keyboard.DOWN:
					downPressed = false;
					break;
			}
		}
		
		private function onEnterFrame(event:Event):void {
			if (_cube) {
				var f:Vector3D = _cube.front;
				if (upPressed) {
					_cube.linearDamping = 0
					f.scaleBy(20);
					_cube.applyCentralForce(f);
				}else if (downPressed) {
					_cube.linearDamping = 0
					f.scaleBy(-20);
					_cube.applyCentralForce(f);
				}else {
					_cube.linearDamping = 0.98
				}
				
				var totalForce:Number = _cube.linearVelocity.clone().normalize();
				
				if (leftPressed) {
					_cube.angularVelocity = new Vector3D(0,-1 * (totalForce / 2),0);
				}else if (rightPressed) {
					_cube.angularVelocity = new Vector3D(0,1 * (totalForce / 2),0);
				}else {
					_cube.angularVelocity = new Vector3D(0,0,0);
				}
			}
			_physicsWorld.step(1 / 60, 1, 1 / 60);
			_view3D.render();
			
		}
		
	}

}