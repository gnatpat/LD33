package net.natpat.dialog 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.engine.EastAsianJustifier;
	import net.natpat.Assets;
	import net.natpat.GC;
	import net.natpat.GV;
	import net.natpat.SpriteSheet;
	import net.natpat.Input;
	import net.natpat.utils.Ease;
	import net.natpat.utils.TweenManager;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class InGameCharacter 
	{
		public var x:int;
		public var y:int;
		
		private var _width:int;
		private var _height:int;
		
		private var _fullWidth:int;
		private var _fullHeight:int;
		
		private var _bitmapData:BitmapData;
		private var _shadowBitmapData:BitmapData;
		private var _spritesheet:SpriteSheet;
		
		private var _character:Character;
		
		private var _facing:Number = 1;
		private var _xScale:Number = 1;
		
		private var _visible:Boolean;
		private var _alpha:Number = 0;
		private var _fading:Boolean;
		
		private var _questions:Array;
		
		private var _facingCallback:Function;
		
		private var _talking:Boolean;
		
		private var _xScaleOffet:Number = 0;
		private var _yScaleOffet:Number = 0;
		
		private var _hadFirstTimeChat:Boolean;
		
		private var _idleTween:int;
		private var _talkTween:int;
		
		private var _topArrow:TopArrow;
		private var _wasOver:Boolean;
		
		private var _canClick:Boolean;
		
		public function InGameCharacter(character:Character) 
		{
			x = character.x;
			y = character.y;
			_width = character.width * GC.CHARACTER_SCALE;
			_height = character.height * GC.CHARACTER_SCALE;
			_fullWidth = GC.CHARACTER_WIDTH * GC.CHARACTER_SCALE;
			_fullHeight = GC.CHARACTER_HEIGHT * GC.CHARACTER_SCALE;
			_visible = character.visible;
			_alpha = _visible ? 1 : 0;
			_character = character;
			_bitmapData = new BitmapData(_fullWidth, _fullHeight, true, 0);
			_shadowBitmapData = new BitmapData(_fullWidth * 2, 36, true, 0);
			_questions = new Array();
			if (!character.first)
				_hadFirstTimeChat = true;
			
			var unscaledBitmapData:BitmapData = Bitmap(new (character.asset)).bitmapData;
			var bitmapData:BitmapData = new BitmapData(_fullWidth * 3,
													   _fullHeight,
													   true,
													   0);
			var matrix:Matrix = new Matrix();
			matrix.scale(GC.CHARACTER_SCALE, GC.CHARACTER_SCALE);
			bitmapData.draw(unscaledBitmapData, matrix);
			
			var shadowBitmapData:BitmapData = Bitmap(new (character.shadow ? Assets.SHADOW_LARGE : Assets.SHADOW_SMALL)).bitmapData;
			matrix = new Matrix();
			matrix.translate(-shadowBitmapData.width / 2, -shadowBitmapData.height / 2);
			matrix.scale(GC.CHARACTER_SCALE, GC.CHARACTER_SCALE);
			matrix.translate(shadowBitmapData.width * GC.CHARACTER_SCALE / 2, shadowBitmapData.height * GC.CHARACTER_SCALE / 2);
			matrix.translate((_shadowBitmapData.width - shadowBitmapData.width * GC.CHARACTER_SCALE) / 2,
							 (_shadowBitmapData.height - shadowBitmapData.height * GC.CHARACTER_SCALE) / 2);
			_shadowBitmapData.draw(shadowBitmapData, matrix);
			
			_spritesheet = new SpriteSheet(bitmapData, _fullWidth, _fullHeight);
										   
			_spritesheet.addAnim("talk", [[0, 0, 0.1], [1, 0, 0.1], [2, 0, 0.1]]);
			
			_idleTween = TweenManager.newTween(function(t:Number):void {
				_xScaleOffet = (t - 0.5) * 0.03;
				_yScaleOffet = (t - 0.5) * -0.03;
				
			}, 2.25, Ease.sine, true);
			_talkTween = TweenManager.newTween(function(t:Number):void {
				_xScaleOffet = (t - 0.5) * 0.05;
				_yScaleOffet = (t - 0.5) * -0.05;
			}, 0.5, Ease.sine, true);
			TweenManager.disable(_talkTween);
			
			_topArrow = new TopArrow();
			_wasOver = false;
		}
		
		public function set talking(talking:Boolean):void
		{
			_talking = talking;
			if (talking)
			{
				_spritesheet.changeAnim("talk");
				TweenManager.disable(_idleTween);
				TweenManager.enable(_talkTween);
			}
			else
			{
				_spritesheet.changeAnim("default");
				TweenManager.disable(_talkTween);
				TweenManager.enable(_idleTween);
			}
		}
		
		public function get isMouseOver():Boolean
		{
			return _visible && GV.pointInRect(Input.mouseX, Input.mouseY, x + _fullWidth / 2 - _width / 2, y + _fullHeight - _height, _width, _height);
		}
		
		public function get character():Character 
		{
			return _character;
		}
		
		public function set visible(visible:Boolean):void
		{
			_visible = visible;
		}
		
		public function unlockQuestion(question:String):void
		{
			_questions.push(new InGameQuestion(character.getQuestion(question), question));
		}
		
		public function removeQuestion(question:String):void
		{
			for (var i:int = 0; i < _questions.length; i++)
			{
				if (_questions[i].dialog == question)
				{
					_questions.splice(i, 1);
					return;
				}
			}
		}
		
		public function setFacing(direction:String, callback:Function):void
		{
			_facing = (direction == "left" ? -1 : 1);
			_facingCallback = callback;
		}
		
		public function fadeIn(callback:Function):void
		{
			_visible = true;
			_fading = true;
			var tweenId:int = TweenManager.newTween(function(t:Number):void {
				_alpha = t;
			}, 1, Ease.quadOut, false, function():void {
				_fading = false;
				TweenManager.remove(tweenId);
				callback();
			});
		}
		
		public function fadeOut(callback:Function):void
		{
			_fading = true;
			var tweenId:int = TweenManager.newTween(function(t:Number):void {
				_alpha = 1-t;
			}, 1, Ease.quadOut, false, function():void {
				_fading = false;
				TweenManager.remove(tweenId);
				_visible = false;
				callback();
			});
		}
		
		public function get questions():Array
		{
			return _questions;
		}
		
		public function get hadFirstTimeChat():Boolean
		{
			return _hadFirstTimeChat;
		}
		
		public function set hadFirstTimeChat(hadFirstTimeChat:Boolean):void
		{
			_hadFirstTimeChat = hadFirstTimeChat;
		}
		
		public function update():void
		{
			_spritesheet.update();
			
			_xScale = _xScale + (_facing - _xScale) * 0.1;
			if (_facingCallback != null && Math.abs(_xScale) > 0.9)
			{
				var func:Function = _facingCallback;
				_facingCallback = null;
				func();
			}
			
			if (isMouseOver && !_wasOver)
			{
				_topArrow.over();
			}
			if (!isMouseOver && _wasOver)
			{
				_topArrow.off();
			}
			
			_wasOver = isMouseOver;
		}
		
		public function set canClick(canClick:Boolean):void
		{
			_canClick = canClick;
		}
		
		public function render(buffer:BitmapData):void
		{
			if (!_visible)
				return;
			_bitmapData.fillRect(_bitmapData.rect, 0);
			_spritesheet.render(_bitmapData, 0, 0);
			
			var matrix:Matrix = new Matrix();
			matrix.translate(-_fullWidth / 2, -_fullHeight);
			matrix.scale(_xScale + _xScaleOffet * _facing, 1 + _yScaleOffet);
			matrix.translate(_fullWidth / 2, _fullHeight);
			matrix.translate(x, y);
			
			var colourTransform:ColorTransform;
			if (_fading)
			{
				colourTransform = new ColorTransform(1, 1, 1, _alpha);
			}
			
			var shadowMatrix:Matrix = new Matrix();
			shadowMatrix.translate(x + (_fullWidth - _shadowBitmapData.width) / 2, y + _fullHeight - _shadowBitmapData.height / 2);
			buffer.draw(_shadowBitmapData, shadowMatrix, colourTransform);
			buffer.draw(_bitmapData, matrix, colourTransform, null, null, true);
			//buffer.fillRect(new Rectangle(x + _fullWidth / 2 - _width / 2, y + _fullHeight - _height, _width, _height), 0xffff0000);
			
		}
		
		public function renderArrow(buffer:BitmapData):void
		{
			if (!_visible)
				return;
			if(_canClick)
				_topArrow.render(buffer, x + _fullWidth / 2, y + _fullHeight - _height - 30);
		}
		
	}

}