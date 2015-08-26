package net.natpat.dialog.statements 
{
	import net.natpat.dialog.Character;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class CancelFirstStatement implements Statement 
	{
		
		private var _who:Character;
		
		public function CancelFirstStatement(character:Character) 
		{
			_who = character;
		}
		
		/* INTERFACE net.natpat.dialog.statements.Statement */
		
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