package net.natpat.dialog 
{
	import net.natpat.GV;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class Character 
	{
		
		private var _name:String;
		private var _asset:Class;
		private var _id:String;
		private var _questions:Object;
		private var _unknownText:Array;
		private var _first:String
		private var _visible:Boolean;
		private var _x:int;
		private var _y:int;
		private var _width:int;
		private var _height:int;
		private var _shadow:String;
		
		public function Character(name:String, asset:Class, id:String, unknownText:Array, questions:Object, x:int, y:int, width:int, height:int, first:String = null, visible:Boolean = true, shadow:String = null) 
		{
			_name = name;
			_asset = asset;
			_id = id;
			_unknownText = unknownText;
			_visible = visible;
			_questions = questions;
			_first = first;
			_x = x;
			_y = y;
			_width = width;
			_height = height;
			_shadow = shadow;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function get asset():Class
		{
			return _asset;
		}
		
		public function get id():String
		{
			return _id;
		}
		
		public function get randomUnknownText():String
		{
			return _unknownText[GV.rand(_unknownText.length)];
		}
		
		public function get visible():Boolean
		{
			return _visible;
		}
		
		public function getQuestion(questionId:String):String
		{
			return _questions[questionId];
		}
		
		public function get first():String
		{
			return _first;
		}
		
		public function get x():int
		{
			return _x;
		}
		
		public function get y():int
		{
			return _y;
		}
		
		public function get width():int
		{
			return _width;
		}
		
		public function get height():int
		{
			return _height;
		}
		
		public function get shadow():String
		{
			return _shadow;
		}
	}

}