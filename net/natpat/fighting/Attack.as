package net.natpat.fighting 
{
	import flash.display.BitmapData;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import net.natpat.utils.Timer;
	import net.natpat.utils.Key;
	import net.natpat.Input;
	import net.natpat.GC;
	import net.natpat.GV;
	import net.natpat.utils.TweenManager;
	/**
	 * ...
	 * @author Archie Evans
	 */
	public class Attack 
	{
		public var x:      Number;
		public var y:      Number;
		public var width:  Number;
		public var height: Number;
		public var damage: Number;
		public var xOffset:Number;
		public var yOffset:Number;
		
		public var _xKnockbackStrength: Number;
		public var _yKnockbackStrength: Number;
		
		public var debugColour: uint = 0xFFFF0000;
		
		public var friendly:  Boolean = false;
		public var knockback: Boolean = false;
		
		public var facingLeft:Boolean = false;
		
		public function Attack(_width:Number, _height:Number, _damage:Number, _friendly:Boolean = true, 
							   _knockback:Boolean = false, _xKnockbackStrength:Number = 0, _yKnockbackStrength:Number = 0)
		{
			width = _width;
			height = _height;
			friendly = _friendly;
			knockback = _knockback;
			this._xKnockbackStrength = _xKnockbackStrength;
			this._yKnockbackStrength = _yKnockbackStrength;
			damage = _damage;
		}
		
		public function setOffset(x:Number, y:Number):void
		{
			xOffset = x;
			yOffset = y;
		}
		
		public function render(buffer:BitmapData):void
		{
			if (GV.debug)
			{
				buffer.fillRect(new Rectangle(x, y, width, height), debugColour);
			}
		}
		
		public function update(_x:Number, _y:Number, facingLeft:Boolean):void
		{
			x = _x + xOffset;
			y = _y + yOffset;
			this.facingLeft = facingLeft;
		}
		
		public function get xKnockbackStrength():Number
		{
			return _xKnockbackStrength * (facingLeft ? -1 : 1);
		}
		
		public function get yKnockbackStrength():Number
		{
			return _yKnockbackStrength;
		}
	}

}