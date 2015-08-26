package net.natpat 
{
	/**
	 * ...
	 * @author ...
	 */
	public class Fighter 
	{
		public var spritesheet:SpriteSheet;
		
		public function Fighter() 
		{
			spritesheet = new SpriteSheet(Assets.FIGHTER, 180, 140);
			spritesheet.addAnim("stand", [[0, 0, 0.2], [1, 0, 0.2], [2, 0, 0.2], [3, 0, 0.2]], true);
			spritesheet.changeAnim("stand");
		}
		
		public function update()
		{
			spritesheet.update();
		}
		
		public function render(buffer)
		{
			spritesheet.render(buffer, 450, 450);
		}
		
	}

}