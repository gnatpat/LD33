package net.natpat.dialog 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import net.natpat.gui.Text;
	import net.natpat.GV;
	import net.natpat.Input;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class InGameQuestion 
	{
		public var x:int = 0;
		public var y:int = 0;
		
		public var width:int;
		public var height:int;
		
		private var _text:Text;
		private var _bitmapData:BitmapData;
		
		private var _selected:Boolean;
		
		private var _dialog:String;
		
		private var _rightArrow:RightArrow;
		private var _wasOver:Boolean;
		
		public function InGameQuestion(text:String, dialog:String) 
		{
			x = 40;
			_text = new Text(0, 0, text, 26, false, 0xff000000);
			_bitmapData = new BitmapData(_text.width + 2, _text.height + 2, true, 0);
			_text.render(_bitmapData);
			width = _text.width;
			height = _text.height;
			
			_dialog = dialog;
			
			_rightArrow = new RightArrow();
			_wasOver = false;
		}
		
		public function get isMouseOver():Boolean
		{
			return GV.pointInRect(Input.mouseX, Input.mouseY, x, y, width, height);
		}
		
		public function get dialog():String
		{
			return _dialog;
		}
		
		public function update():void
		{
			if (isMouseOver && !_wasOver)
			{
				_rightArrow.over();
			}
			if (!isMouseOver && _wasOver)
			{
				_rightArrow.off();
			}
			
			_wasOver = isMouseOver;
		}
		
		public function render(buffer:BitmapData):void
		{
			buffer.copyPixels(_bitmapData, _bitmapData.rect, new Point(x, y));
			_rightArrow.render(buffer, x - 30, y);
		}
		
	}

}