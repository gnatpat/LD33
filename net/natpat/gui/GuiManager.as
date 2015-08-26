package net.natpat.gui 
{
	import flash.display.BitmapData;
	import flash.text.engine.ElementFormat;
	
	import net.natpat.gui.IGuiElement
	
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class GuiManager 
	{
		
		private static var elements:Vector.<IGuiElement> = new Vector.<IGuiElement>();
		
		public function GuiManager() 
		{
			
		}
		
		public static function add(element:IGuiElement, depth:int = 0):IGuiElement
		{
			if (depth == 0)
			{
				elements.push(element);
			} 
			else if (depth == -1)
			{
				elements.unshift(element);
			}
			element.add();
			return element;
		}
		
		public static function remove(element:IGuiElement):IGuiElement
		{
			var index:int = elements.indexOf(element);
			if (index == -1)
			{
				trace("No element to remove");
				return element;
			}
			elements[index].remove();
			elements.splice(index, 1);
			return element;
		}
		
		public static function update():void
		{
			for (i = 0; i < elements.length; i++)
			{
				elements[i].update();
			}
		}
		
		public static function render(buffer:BitmapData):void
		{
			for (i = 0; i < elements.length; i++)
			{
				elements[i].render(buffer)
			}
		}
		
		private static var i:int;
		
	}

}