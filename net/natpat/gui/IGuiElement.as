package net.natpat.gui 
{
	import flash.display.BitmapData;
	
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public interface IGuiElement
	{
		function render(buffer:BitmapData):void;
		
		function update():void;
		
		function add():void;
		
		function remove():void;
		
	}
	
}