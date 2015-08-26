package net.natpat.dialog.statements 
{
	import net.natpat.dialog.Choice;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class ChoiceStatement implements Statement
	{
		
		private var _choices:Array;
		
		public function ChoiceStatement(choices:Array) 
		{
			_choices = choices;
		}
		
		public function get choices():Array
		{
			return _choices;
		}
		
		public function get text():String
		{
			return "";
		}
	}

}