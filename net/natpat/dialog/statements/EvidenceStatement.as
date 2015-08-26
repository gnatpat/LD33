package net.natpat.dialog.statements {
	import net.natpat.dialog.Evidence;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class EvidenceStatement implements Statement 
	{
		
		private var _evidence:Evidence;
		private var _text:String;
		
		public function EvidenceStatement(evidence:Evidence, text:String) 
		{
			_evidence = evidence;
			_text = text;
		}
		
		/* INTERFACE net.natpat.dialog.Statement */
		
		public function get text():String 
		{
			return (_text ? _text : "You gained " + _evidence.name + ".");
		}
		
		public function get evidence():Evidence
		{
			return _evidence;
		}
		
	}

}