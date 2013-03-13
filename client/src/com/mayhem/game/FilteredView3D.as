package com.mayhem.game 
{
	import away3d.containers.View3D;
	import away3d.filters.BloomFilter3D;
	import away3d.filters.BlurFilter3D;
	import away3d.filters.Filter3DBase;
	import away3d.filters.HueSaturationFilter3D;
	import away3d.filters.MotionBlurFilter3D;
	
	/**
	 * ...
	 * @author availlant
	 */
	public class FilteredView3D extends View3D 
	{
		
		private var _filters:Array = []
		public var doFilters:Boolean = true;
		public var motionBlur:MotionBlurFilter3D;
		public var saturationFilter:BloomFilter3D;
		
		
		public function FilteredView3D() 
		{
			super();
			motionBlur = new MotionBlurFilter3D(.4);
			saturationFilter = new BloomFilter3D(0,0,0,0);			
		}
		
		public function setFilters():void {
			filters3d = [motionBlur,saturationFilter]
		}
		
		public function addFilter(filter:Filter3DBase):void {
			_filters = [filter]
		}
		
		public function removeFilters():void {
			_filters = [];
		}
		
		override public function render():void {
			super.render();
		}
		
	}

}