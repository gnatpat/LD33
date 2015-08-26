package net.natpat.dialog.statements {
	import net.natpat.dialog.Evidence;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class RemoveStatement implements Statement 
	{
		
		private var _evidence:Evidence;
		private var _text:String;
		
		public function RemoveStatement(evidence:Evidence, text:String) 
		{
			_evidence = evidence;
			_text = text;
		}
		
		/* INTERFACE net.natpat.dialog.Statement */
		
		public function get text():String 
		{
			return _text;
		}
		
		public function get evidence():Evidence
		{
			return _evidence;
		}
		
	}

}