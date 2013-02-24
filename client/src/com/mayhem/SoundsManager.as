package com.mayhem 
{
	import away3d.audio.drivers.SimplePanVolumeDriver;
	import away3d.audio.Sound3D;
	import away3d.cameras.Camera3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import caurina.transitions.properties.SoundShortcuts;
	import caurina.transitions.Tweener;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	/**
	 * ...
	 * @author availlant
	 */
	public class SoundsManager 
	{
		[Embed(source='/assets/sounds/game_loop.mp3')]
		private static var GameLoop:Class;
		[Embed(source='/assets/sounds/menu_loop.mp3')]
		private static var MenuLoop:Class;
		[Embed(source='/assets/sounds/sfx/explosion.mp3')]
		public static var Explosion:Class;
		[Embed(source='/assets/sounds/sfx/collision.mp3')]
		public static var Collision:Class;
		[Embed(source='/assets/sounds/sfx/powerup.mp3')]
		public static var Powerup:Class;
		
		public static var HAS_MUSIC:Boolean = true;
		public static var HAS_SFX:Boolean = true;
		
		private static var soundTransform:SoundTransform;
		private static var gameLoopSoundChannel:SoundChannel;
		private static var menuLoopSoundChannel:SoundChannel;
		private static var _currentLoop:String;
		private static const _MENU_LOOP:String = "menuLoop";
		private static const _GAME_LOOP:String = "gameLoop";
		private static const _EXPLOSION_SFX:String = "explosion";
		private static const _COLLISION_SFX:String = "collision";
		private static const _POWERUP_SFX:String = "powerup";
		
		private static var _soundDriver:SimplePanVolumeDriver;
		private static var _scene:Scene3D;
		private static var _camera:Camera3D;
		
		
		public static function initialize(hasMusic:Boolean, view:View3D):void {
			HAS_MUSIC = hasMusic;
			_scene = view.scene;
			_camera = view.camera;
			_soundDriver = new SimplePanVolumeDriver();
			SoundShortcuts.init();
		}
		
		public static function startMenuLoop():void {
			_currentLoop = _MENU_LOOP;
			if(HAS_MUSIC){
				menuLoopSoundChannel = new MenuLoop().play(0, 9999);
				var sTrans:SoundTransform = new SoundTransform(0);
				menuLoopSoundChannel.soundTransform = sTrans;
				Tweener.addTween(menuLoopSoundChannel, { _sound_volume:1, time:50 } );
				if (gameLoopSoundChannel) {
					Tweener.addTween(gameLoopSoundChannel, { _sound_volume:0, time:10, onComplete:function():void
					{
						gameLoopSoundChannel = null;
					}
					} );
				}
			}
		}
		
		public static function playCollisionSFX(position:Vector3D):void {
			if(HAS_MUSIC){
				var s3d:Sound3D = new Sound3D(new Collision(), _camera, _soundDriver, 1, 30000);
				s3d.position = position;
				_scene.addChild(s3d);
				s3d.addEventListener(Event.SOUND_COMPLETE, onComplete);
				s3d.play();
			}
		}
		public static function playExplosionSFX(position:Vector3D):void {
			if(HAS_MUSIC){
				var s3d:Sound3D = new Sound3D(new Explosion(), _camera, _soundDriver, 1, 30000);
				s3d.position = position;
				_scene.addChild(s3d);
				s3d.addEventListener(Event.SOUND_COMPLETE, onComplete);
				s3d.play();
			}
		}
	
		public static function playPowerupSFX(position:Vector3D):void {
			if(HAS_MUSIC){
				var s3d:Sound3D = new Sound3D(new Powerup(), _camera, _soundDriver, 1, 30000);
				s3d.position = position;
				_scene.addChild(s3d);
				s3d.addEventListener(Event.SOUND_COMPLETE, onComplete);
				s3d.play();
			}
		}
		
		private static function onComplete(event:Event):void {
			var sound3d:Sound3D = event.currentTarget as Sound3D;
			if (sound3d.parent) {
				_scene.removeChild(sound3d);
			}
		}
		
		public static function startAllSounds():void {
			HAS_MUSIC = true;
			if (_currentLoop == _GAME_LOOP) {
				startGameLoop();
			}else if (_currentLoop == _MENU_LOOP) {
				startMenuLoop();
			}
		}
		
		public static function stopAllSounds():void {
			HAS_MUSIC = false;
			if (gameLoopSoundChannel) {
				gameLoopSoundChannel.stop();
			}
			if (menuLoopSoundChannel) {
				menuLoopSoundChannel.stop();
			}
		}
		
		public static function startGameLoop():void {
			_currentLoop = _GAME_LOOP;
			if(HAS_MUSIC){
				gameLoopSoundChannel = new GameLoop().play(0, 9999);
				var sTrans:SoundTransform = new SoundTransform(0);
				gameLoopSoundChannel.soundTransform = sTrans;
				Tweener.addTween(gameLoopSoundChannel, { _sound_volume:1, time:50 } );
				if (menuLoopSoundChannel) {
					Tweener.addTween(menuLoopSoundChannel, { _sound_volume:0, time:10, onComplete:function():void
					{
						menuLoopSoundChannel = null;
					}
					} );
				}
			}
		}
		
	}

}