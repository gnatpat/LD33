package net.natpat 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import net.natpat.utils.Sfx;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class TitleScreen 
	{
		
		private var _gameManager:GameManager;
		public var titleMusic:Sfx;
		
		public var _bitmapData:BitmapData;
		
		public var spritesheet:SpriteSheet;
		
		public function TitleScreen(gameManager:GameManager)
		{
			_gameManager = gameManager;
			titleMusic = new Sfx(Assets.MUSIC_TITLE);
			titleMusic.play(true);
			_bitmapData = Bitmap(new Assets.TITLE).bitmapData;
			var bitmapData:BitmapData = new BitmapData(540 * 4, 420,  true, 0);
			var matrix:Matrix = new Matrix();
			matrix.scale(3, 3);
			bitmapData.draw(Bitmap(new Assets.FIGHTER).bitmapData, matrix);
			spritesheet = new SpriteSheet(bitmapData, 540, 420);
			spritesheet.addAnim("standing", [[0, 0, 0.1], [1, 0, 0.1], [2, 0, 0.1], [3, 0, 0.1]], true);
			
			spritesheet.changeAnim("standing");
		}
		
		public function render(buffer:BitmapData):void
		{
			buffer.draw(_bitmapData);
			spritesheet.render(buffer, 50, 100);
		}
		
		public function update():void
		{
			if (Input.mouseReleased)
			{
				titleMusic.stop();
				_gameManager.finishedTitleScreen();
			}
			spritesheet.update();
		}
		
	}

}