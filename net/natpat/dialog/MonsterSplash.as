package net.natpat.dialog 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import net.natpat.Assets;
	import net.natpat.GameManager;
	import net.natpat.GC;
	import net.natpat.GV;
	import net.natpat.utils.Ease;
	import net.natpat.utils.Sfx;
	import net.natpat.utils.TweenManager;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class MonsterSplash 
	{
		
		private var _gameManager:GameManager;
		private var _bitmapData:BitmapData;
		private var _movement:int = 200;
		private var _xOffset:int = 0;
		private var _yOffset:int = 0;
		
		private var _startXOffset:int;
		private var _startYOffset:int;
		
		public var appearSFX:Sfx;
		
		public function MonsterSplash(gameManager:GameManager, episodeProvider:EpisodeProvider) 
		{
			_gameManager = gameManager;
			
			_startXOffset = episodeProvider.splashXOffset;
			_startYOffset = episodeProvider.splashYOffset;
			
			appearSFX = new Sfx(Assets[episodeProvider.splash + "_SFX"]);
			appearSFX.play();
			
			var bitmapData:BitmapData = Bitmap(new Assets[episodeProvider.splash]).bitmapData;
			
			_bitmapData = new BitmapData(GC.SCREEN_WIDTH *2 + _movement * 2, GC.SCREEN_HEIGHT * 2 + _movement * 2);
			
			var matrix:Matrix = new Matrix();
			matrix.translate( -bitmapData.width / 2, -bitmapData.height / 2);
			matrix.scale(GC.CHARACTER_SCALE - 0.5, GC.CHARACTER_SCALE - 0.5);
			matrix.translate(bitmapData.width / 2, bitmapData.height / 2);
			matrix.translate((_bitmapData.width - bitmapData.width) / 2, (_bitmapData.height - bitmapData.height) / 2);
			_bitmapData.draw(bitmapData, matrix);
			
			var tween:int = TweenManager.newTween(function(t:Number):void {
				_xOffset = t * _movement;
				_yOffset = t * -_movement;
			}, 4, Ease.quadOut, false, function():void {
				TweenManager.remove(tween);
				done();
			});
			GV.shake(4, 10);
		}
		
		public function render(buffer:BitmapData):void
		{
			buffer.copyPixels(_bitmapData, _bitmapData.rect, 
							  new Point((GC.SCREEN_WIDTH - _bitmapData.width) / 2 + _xOffset + _startXOffset, (GC.SCREEN_HEIGHT - _bitmapData.height) / 2 + _yOffset + _startYOffset));
		}
		
		public function update():void
		{
			
		}
		
		public function done():void
		{
			_gameManager.finishedMonsterSplash();
		}
	}

}