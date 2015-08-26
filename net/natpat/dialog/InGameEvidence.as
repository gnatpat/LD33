package net.natpat.dialog 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import net.natpat.GC;
	import net.natpat.gui.Text;
	import net.natpat.GV;
	import net.natpat.Input;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class InGameEvidence 
	{
		public var x:int = 0;
		public var y:int = 0;
		
		private var _width:int;
		private var _height:int;
		
		private var _text:Text;
		private var _bitmapData:BitmapData;
		
		private var _selected:Boolean;
		
		private var _evidence:Evidence;
		
		private var _rightArrow:RightArrow;
		private var _wasOver:Boolean;
		
		private var _canClick:Boolean;
		
		public function InGameEvidence(evidence:Evidence) 
		{
			x = GC.EVIDENCE_BOX_X + 40;
			_text = new Text(0, 0, evidence.name, 26, false, 0xff000000, true, 190);
			_bitmapData = new BitmapData(_text.width + 2, _text.height + 2, true, 0);
			_text.render(_bitmapData);
			_width = _text.width;
			_height = _text.height;
			
			_evidence = evidence;
			
			_rightArrow = new RightArrow();
			_wasOver = false;
		}
		
		public function get isMouseOver():Boolean
		{
			return GV.pointInRect(Input.mouseX, Input.mouseY, x, y, _width, _height);
		}
		
		public function set selected(s:Boolean):void
		{
			_selected = s;
			var colour:uint = (_selected ? 0xffff0000 : 0xff000000);
			_text = new Text(0, 0, evidence.name, 26, false, colour, true, 190);
			_text.updateGraphic();
			_bitmapData.fillRect(_bitmapData.rect, 0);
			_text.render(_bitmapData);
		}
		
		public function get evidence():Evidence
		{
			return _evidence;
		}
		
		public function get height():int
		{
			return _height;
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
		
		public function set canClick(canClick:Boolean):void
		{
			_canClick = canClick;
		}
		
		public function render(buffer:BitmapData):void
		{
			buffer.copyPixels(_bitmapData, _bitmapData.rect, new Point(x, y));
			if (_canClick)
				_rightArrow.render(buffer, x - 30, y);
		}
		
	}

}