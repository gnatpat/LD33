package net.natpat.dialog.statements {
	import net.natpat.dialog.Evidence;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class SwitchStatement implements Statement 
	{
		
		private var _from:Evidence;
		private var _to:Evidence;
		
		public function SwitchStatement(from:Evidence, to:Evidence) 
		{
			_from = from;
			_to = to;
		}
		
		/* INTERFACE net.natpat.dialog.Statement */
		
		public function get text():String 
		{
			return "";
		}
		
		public function get from():Evidence
		{
			return _from;
		}
		
		public function get to():Evidence
		{
			return _to;
		}
		
	}

}