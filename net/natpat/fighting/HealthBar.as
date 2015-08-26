package net.natpat.fighting 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.display.Bitmap;
	/**
	 * ...
	 * @author Archie Evans
	 */
	public class HealthBar 
	{
		public const FULL_WIDTH:Number = 274;
		
		public var x:      Number;
		public var y:      Number;
		public var xOverlay: Number;
		public var yOverlay: Number;
		public var health: Number;
		public var full:   Number;
		public var fadeWidth: Number;
		public var width:  Number;
		public var height: Number = 42;
		
		public var fighter: Boolean;
		
		public var bitmapData: BitmapData;
		
		public function HealthBar(_health:Number, _asset:Class) 
		{
			
			bitmapData = Bitmap(new _asset).bitmapData;
			
			health = _health;
			full = _health;
			
			xOverlay = 15;
			yOverlay = 5;
			
			x = 106;
			y = 50;
			
			fadeWidth = FULL_WIDTH;
			
		}
		
		public function render(buffer:BitmapData):void
		{
			buffer.fillRect(new Rectangle(x, y, fadeWidth, height), 0xFFFFFFFF);
			
			if (health > full / 5)
			{
				buffer.fillRect(new Rectangle(x, y, width, height), 0xFF7E7B6E);
			}
			else
			{
				buffer.fillRect(new Rectangle(x, y, width, height), 0xFFE85858);
			}
			
			buffer.copyPixels(bitmapData, bitmapData.rect, new Point(xOverlay, yOverlay));
		}
		
		public function update(_health:Number):void
		{
			health = _health;
			width = health / full * FULL_WIDTH;
			
			if (width < fadeWidth)
			{
				fadeWidth -= 0.75;
			}
		}
	}

}