package net.natpat.dialog.statements {
	import net.natpat.dialog.Character;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class QuestionStatement implements Statement 
	{
		
		private var _who:Character;
		private var _question:String;
		
		public function QuestionStatement(who:Character, question:String) 
		{
			_who = who;
			_question = question;
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
		
		public function get question():String
		{
			return _question;
		}
	}

}