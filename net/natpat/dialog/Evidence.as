package net.natpat.dialog 
{
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class Evidence 
	{
		
		private var _name:String;
		private var _id:String;
		
		private var _does:Object;
		
		public function Evidence(name:String, id:String, does:Object) 
		{
			_name = name;
			_id = id;
			_does = does;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function get id():String
		{
			return _id;
		}
		
		public function doesOn(id:String):String
		{
			return _does[id];
		}
	}

}