package net.natpat.dialog.statements {
	import net.natpat.dialog.Character;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class RemoveQuestionStatement implements Statement 
	{
		
		private var _dialog:String;
		private var _who:Character;
		
		public function RemoveQuestionStatement(who:Character, dialog:String) 
		{
			_who = who;
			_dialog = dialog;
		}
		
		/* INTERFACE net.natpat.dialog.Statement */
		
		public function get text():String 
		{
			return "";
		}
		
		public function get who():Character
		{
			return _who;
		}
		
		public function get dialog():String
		{
			return _dialog;
		}
		
	}

}