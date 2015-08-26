package net.natpat.dialog.statements {
	import net.natpat.dialog.Character;
	
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class AppearStatement implements Statement 
	{
		
		private var _who:Character;
		private var _when:String;
		
		public function AppearStatement(who:Character, when:String) 
		{
			_who = who;
			_when = when;
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
		
		public function get when():String
		{
			return _when;
		}
		
	}

}