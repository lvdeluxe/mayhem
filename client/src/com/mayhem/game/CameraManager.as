package com.mayhem.game 
{
	/**
	 * ...
	 * @author availlant
	 */
	
	import away3d.cameras.Camera3D;
	import away3d.core.math.Quaternion;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	 
	public class CameraManager 
	{
		private static var _instance:CameraManager;
		private static var _enableInstantiation:Boolean = false;
		private var _camera:Camera3D;
		private var _targetQuaternion:Quaternion = new Quaternion();
		private var _cameraQuaternion:Quaternion = new Quaternion();
		private var _axisQuaternion:Quaternion = new Quaternion();
		private var _rotateAxis:Vector3D = Vector3D.X_AXIS;
		
		public function CameraManager() 
		{
			if (!_enableInstantiation) {
				throw new Error('This class is a Singleton, should not be instanciated!');
			}
		}
		
		public function initialize(pCam:Camera3D):void {
			_camera = pCam;
		}
		
		public static function get instance():CameraManager {
			if (!_instance) {
				_enableInstantiation = true
				_instance = new CameraManager();
				_enableInstantiation = false;
			}
			return _instance;
		}
		
		public function updateCamera(pTransform:Matrix3D, pPos:Vector3D):void {
			_axisQuaternion.fromAxisAngle(_rotateAxis, Math.PI / 4);
			
			_targetQuaternion.fromMatrix(pTransform);
			_targetQuaternion.multiply(_targetQuaternion, _axisQuaternion);
			
			var cameraTransform:Matrix3D = _camera.transform.clone();
			
			_cameraQuaternion.fromMatrix(cameraTransform);
			
			_cameraQuaternion.lerp(_cameraQuaternion, _targetQuaternion,0.1);
			
			var newTransform:Matrix3D = _cameraQuaternion.toMatrix3D().clone();
			
			_camera.transform = newTransform;
			
			_camera.position = pPos;
			_camera.moveBackward(3000);
			_camera.moveDown(500); 
		}
		
	}

}