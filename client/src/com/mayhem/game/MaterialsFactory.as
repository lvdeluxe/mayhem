package com.mayhem.game 
{
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.MaterialBase;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.materials.methods.HardShadowMapMethod;
	import away3d.materials.methods.SoftShadowMapMethod;
	import away3d.materials.methods.TripleFilteredShadowMapMethod;
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapTexture;
	import away3d.tools.commands.Weld;
	import flash.display.Bitmap;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author availlant
	 */
	public class MaterialsFactory 
	{
		public static const BUMPER_MATERIAL:String = "bumperMaterial";
		public static const WALLS_MATERIAL:String = "wallsMaterial";
		public static const AI_CUBE_MATERIAL:String = "AICubeMaterial";
		public static const OWNER_CUBE_MATERIAL:String = "ownerCubeMaterial";
		public static const OTHER_CUBE_MATERIAL:String = "otherCubeMaterial";
		public static const SHADOW_CUBE_MATERIAL:String = "shadowCubeMaterial";
		
		[Embed(source = "/assets/shadow.png")]
		private static var ShadowClass:Class;
		
		private static var _allMaterials:Dictionary = new Dictionary();		
		private static var _mainLightPicker:StaticLightPicker;
		
		public function MaterialsFactory() 
		{
			
		}
		
		
		
		public static function initialize(lights:Array):void {
			_mainLightPicker = new StaticLightPicker(lights);
		}
		
		public static function getMaterialById(id:String):MaterialBase {
			if (_allMaterials[id] == null) {
				var mat:MaterialBase = createMaterialById(id);
				_allMaterials[id] = mat;
			}
			return _allMaterials[id];
		}
		
		private static function createMaterialById(id:String):MaterialBase {
			var mat:MaterialBase;
			switch(id) {
				case BUMPER_MATERIAL:
					mat = getBumperMaterial();
					break;
				case WALLS_MATERIAL:
					mat = getWallsMaterial();
					break;
				case OWNER_CUBE_MATERIAL:
					mat = getOwnerCubeMaterial();
					break;
				case OTHER_CUBE_MATERIAL:
					mat = getOtherCubeMaterial();
					break;
				case SHADOW_CUBE_MATERIAL:
					mat = getShadowMaterial();
					break;
				case AI_CUBE_MATERIAL:
					mat = getAICubeMaterial();
					break;
			}
			return mat;
		}
		
		private static function getShadowMaterial():MaterialBase {
			var shadow:Bitmap = new ShadowClass();
			var texture:BitmapTexture = new BitmapTexture(shadow.bitmapData);
			var mat:TextureMaterial = new TextureMaterial(texture);
			mat.alphaBlending = true;
			mat.lightPicker = _mainLightPicker
			return mat;
		}
		
		private static function getBumperMaterial():MaterialBase {
			var mat:ColorMaterial = new ColorMaterial();
			mat.ambient = 0;
			mat.smooth = true;
			mat.repeat = false;
			mat.depthCompareMode = "less";
			mat.mipmap = true;
			mat.bothSides = false;
			mat.ambientColor = 0xFFFFFF;
			mat.blendMode = "normal";
			mat.alphaThreshold = 0;
			mat.gloss = 1;
			mat.alpha = 1;
			mat.alphaBlending = false;
			mat.name = "mat1";
			mat.alphaPremultiplied = true;
			mat.specularColor = 0xFFFFFF;
			mat.color = 0x666666;
			mat.specular = 0;
			mat.lightPicker = _mainLightPicker;
			return mat;
		}
		
		private static function getWallsMaterial():MaterialBase {
			var mat:ColorMaterial = new ColorMaterial();
			mat.ambient = 0;
			mat.smooth = true;
			mat.repeat = false;
			mat.depthCompareMode = "less";
			mat.mipmap = true;
			mat.bothSides = false;
			mat.ambientColor = 0xFFFFFF;
			mat.blendMode = "normal";
			mat.alphaThreshold = 0;
			mat.gloss = 1;
			mat.alpha = 1;
			mat.alphaBlending = false;
			mat.name = "mat1";
			mat.alphaPremultiplied = true;
			mat.specularColor = 0xFFFFFF;
			mat.color = 0x3E9613;
			mat.specular = 0;
			mat.lightPicker = _mainLightPicker;
			return mat;
		}
		
		private static function getAICubeMaterial():MaterialBase {
			var mat:ColorMaterial = new ColorMaterial(0x999999);
			mat.lightPicker = _mainLightPicker;
			return mat;
		}
		private static function getOwnerCubeMaterial():MaterialBase {
			var mat:ColorMaterial = new ColorMaterial(0xcc0000);
			mat.lightPicker = _mainLightPicker;
			return mat;
		}
		
		private static function getOtherCubeMaterial():MaterialBase {
			var mat:ColorMaterial = new ColorMaterial(0x0000cc);
			mat.lightPicker = _mainLightPicker;
			return mat;
		}
		
	}

}