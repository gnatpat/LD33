package net.natpat 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import net.natpat.utils.Sfx;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class LevelSelect 
	{
		
		
		private var gameManager:GameManager;
		public var bitmapData:BitmapData;
		
		public var levelSelectMusic:Sfx;
		
		public function LevelSelect(gameManager:GameManager) 
		{
			levelSelectMusic = new Sfx(Assets.MUSIC_TITLE);
			levelSelectMusic.play(true);
			
			bitmapData = Bitmap(new Assets.LEVELSELECT).bitmapData;
			this.gameManager = gameManager;
		}
		
		public function render(buffer:BitmapData):void
		{
			buffer.draw(bitmapData);
		}
		
		public function update():void
		{
			if (Input.mousePressed)
			{
				if (GV.pointInRect(Input.mouseX, Input.mouseY, 45, 250, 180, 264))
				{
					levelSelectMusic.stop();
					gameManager.finishLevelSelect(1);
				}
				if(GV.pointInRect(Input.mouseX, Input.mouseY, 274, 238, 209, 279))
				{
					levelSelectMusic.stop();
					gameManager.finishLevelSelect(2);
				}
				if(GV.pointInRect(Input.mouseX, Input.mouseY, 524, 276, 193, 257))
				{
					levelSelectMusic.stop();
					gameManager.finishLevelSelect(3);
				}
			}
		}
		
	}

}