package net.natpat.dialog.statements {
	import net.natpat.dialog.Character;
	
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class DisappearStatement implements Statement 
	{
		
		private var _who:Character;
		
		public function DisappearStatement(who:Character) 
		{
			_who = who;
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
		
	}

}