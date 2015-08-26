package net.natpat.dialog 
{
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class Choice 
	{
		
		private var _dialog:String;
		private var _text:String;
		
		public function Choice(dialog:String, text:String) 
		{
			_dialog = dialog;
			_text = text;
		}
		
		public function get dialog():String
		{
			return _dialog;
		}
		
		public function get text():String
		{
			return _text;
		}
		
	}

}