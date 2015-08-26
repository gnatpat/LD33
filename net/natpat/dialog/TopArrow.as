package net.natpat.dialog {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import net.natpat.Assets;
	import net.natpat.utils.Ease;
	import net.natpat.utils.TweenManager;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class TopArrow 
	{
		private var _bitmapData:BitmapData;
		private var yOffset:int;
		
		private var _fast:int;
		private var _slow:int;
		
		public function TopArrow() 
		{
			_bitmapData = Bitmap(new Assets.DOWN_ARROW).bitmapData;
			_slow = TweenManager.newTween(function(t:Number):void {
				yOffset = t * -4;
			}, 1, Ease.sine, true);
			_fast = TweenManager.newTween(function(t:Number):void {
				yOffset = t * -8;
			}, 0.5, Ease.sine, true);
			TweenManager.disable(_fast);
		}
		
		public function over():void
		{
			TweenManager.enable(_fast);
			TweenManager.disable(_slow);
		}
		
		public function off():void
		{
			TweenManager.disable(_fast);
			TweenManager.enable(_slow);
		}
		
		public function render(buffer:BitmapData, x:int, y:int):void
		{
			buffer.copyPixels(_bitmapData, buffer.rect, new Point(x - _bitmapData.width / 2, y + yOffset));
		}
		
	}

}