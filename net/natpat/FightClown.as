package net.natpat 
{
	import flash.display.BitmapData;
	/**
	 * ...
	 * @author ...
	 */
	public class FightClown 
	{
		
		public var spritesheet:SpriteSheet;
		
		public function FightClown() 
		{
			spritesheet = new SpriteSheet(Assets.FIGHTCLOWN, 180, 166);
			spritesheet.addAnim("walk", [[0, 2, 0.1], [1, 2, 0.1], [2, 2, 0.1], [3, 2, 0.1], [4, 2, 0.1]], true);
			spritesheet.changeAnim("walk");
		}
		
		public function update():void
		{
			spritesheet.update();
		}
		
		public function render(buffer:BitmapData):void
		{
			spritesheet.render(buffer, 450, 250);
		}
		
	}

}