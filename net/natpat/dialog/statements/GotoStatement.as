package net.natpat.dialog.statements 
{
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class GotoStatement implements Statement 
	{
		
		private var _dialog:String;
		
		public function GotoStatement(dialog:String) 
		{
			_dialog = dialog;
		}
		
		/* INTERFACE net.natpat.dialog.statements.Statement */
		
		public function get text():String 
		{
			return "";
		}
		
		public function get dialog():String
		{
			return _dialog;
		}
		
	}

}