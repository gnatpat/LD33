package net.natpat.dialog.statements {
	import net.natpat.dialog.Character;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class TurnStatement implements Statement 
	{
		
		private var _direction:String;
		private var _character:Character;
		
		public function TurnStatement(direction:String, character:Character) 
		{
			_direction = direction;
			_character = character;
		}
		
		public function get text():String
		{
			return "";
		}
		
		public function get direction():String
		{
			return _direction;
		}
		
		public function get character():Character
		{
			return _character;
		}
		
	}

}