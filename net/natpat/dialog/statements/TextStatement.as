package net.natpat.dialog.statements {
	import net.natpat.dialog.Character;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class TextStatement implements Statement 
	{
		
		private var _who:Character;
		private var _text:String;
		private var _shake:Number;
		
		public function TextStatement(who:Character, text:String, shake:Number) 
		{
			_who = who;
			_text = text;
			_shake = shake;
		}
		
		/* INTERFACE net.natpat.dialog.Statement */
		
		public function get text():String
		{
			return _who.name + ": " + _text;
		}
		
		public function get who():Character
		{
			return _who;
		}
		
		public function get shake():Number
		{
			return _shake;
		}
		
	}

}