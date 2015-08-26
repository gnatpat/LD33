package net.natpat.dialog.statements 
{
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class InfoStatement implements Statement
	{
		
		private var _text:String;
		
		public function InfoStatement(text:String) 
		{
			_text = text;
		}
		
		public function get text():String
		{
			return _text;
		}
	}

}