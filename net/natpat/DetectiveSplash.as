package net.natpat 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import net.natpat.gui.Text;
	import net.natpat.utils.Timer;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class DetectiveSplash 
	{
		
		private var _bitmapData:BitmapData;
		
		private var _text:String = "I'm a private detective. I've been solving the toughest cases for years.\nThis city is filled with monsterous vermin. Someone's got to clean them out.\nWhy shouldn't it be me?"
		private var _textBox:Text;
		private var _clickToContinue:Text;
		private var characters:int = 0;
		
		private var _gameManager:GameManager;
		
		public function DetectiveSplash(gameManager:GameManager) 
		{
			_bitmapData = Bitmap(new Assets.DETECTIVE_SPLASH).bitmapData;
			_textBox = new Text(350, 100, "", 18, false, 0xffffff, true, 400);
			var timer:Timer = new Timer(1000 / GC.TEXT_SPEED, _text.length);
			timer.addEventListener(TimerEvent.TIMER, function(e:Event):void {
				characters++;
				_textBox = new Text(350, 100, _text.slice(0, characters), 18, false, 0xffffff, true, 400);
			});
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:Event):void {
				_clickToContinue = new Text(500, 550, "Click to continue...", 26, false);
			});
			timer.start();
			
			_gameManager = gameManager;
		}
		
		public function update():void
		{
			if (Input.mousePressed)
			{
				if (_clickToContinue)
					_gameManager.finishedDetectiveSplash();
				else
				{
					_clickToContinue = new Text(500, 550, "Click to continue...", 26, false);
					characters = _text.length;
				}
			}
		}
		
		public function render(buffer:BitmapData):void
		{
			var matrix:Matrix = new Matrix();
			matrix.scale(4, 4);
			matrix.translate( -260, -150);
			buffer.draw(_bitmapData, matrix);
			_textBox.render(buffer);
			if (_clickToContinue)
				_clickToContinue.render(buffer)
		}
	}

}