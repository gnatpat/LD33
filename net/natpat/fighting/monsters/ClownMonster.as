package net.natpat.fighting.monsters 
{
	import flash.display.BitmapData;
	import flash.events.TimerEvent;
	import net.natpat.GV;
	import net.natpat.utils.Sfx;
	import net.natpat.utils.Timer;
	import net.natpat.fighting.Monster;
	import net.natpat.fighting.MonsterHealthBar;
	import net.natpat.SpriteSheet;
	import net.natpat.fighting.HealthBar;
	import net.natpat.Assets;
	import net.natpat.fighting.Attack;
	import net.natpat.fighting.FightManager;
	
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class ClownMonster extends Monster 
	{
		
		public var attackBite: Attack;
		
		private var speed:Number = 1.5;
		private var state:int = 0;
		private var stopTime:Number = 750;
		
		private static const RUNNING:int = 0;
		private static const SLIDING:int = 1;
		private static const STOPPED:int = 2;
		
		public var chompSFXarray:Array;
		
		public function ClownMonster(fightManager:FightManager, _attacks:Array) 
		{
			super(fightManager, _attacks);
			
			chompSFXarray = new Array();
			chompSFXarray.push(new Sfx(Assets.CHOMP_SFX_1));
			chompSFXarray.push(new Sfx(Assets.CHOMP_SFX_2));
			chompSFXarray.push(new Sfx(Assets.CHOMP_SFX_3));
			chompSFXarray.push(new Sfx(Assets.CHOMP_SFX_4));
			
			healthBar = new MonsterHealthBar(health, Assets.HEALTHBARCLOWN);
			spritesheet = new SpriteSheet(Assets.FIGHTCLOWN, 180, 166);
			spritesheet.addAnim("walk", [[0, 2, 0.1, function():void { chompSFXarray[0].stop(); chompSFXarray[1].stop(); chompSFXarray[2].stop(); chompSFXarray[3].stop();
																		chompSFXarray[GV.rand(chompSFXarray.length)].play() } ],
										[1, 2, 0.1], [2, 2, 0.1], [3, 2, 0.1], [4, 2, 0.1]], true);
			spritesheet.addAnim("slide", [[3, 2, 0.1]], true);
			spritesheet.addAnim("stop", [[0, 0, 0.1]], true);
			spritesheet.changeAnim("walk");
			spriteWidth = 180;
			spriteHeight = 166;
			spriteXOffset = 23;
			spriteYOffset = 33;
			bitmapData = new BitmapData(spriteWidth, spriteHeight);
			
			width = 148;
			height = 111;
			
			friction = 0.9;
			
			attackMaker();
		}
		
		public function attackMaker():void
		{
			// Bite
			//attackBite = new Attack(x, y, 27, 111, false, true, -25,  -7, 10);
			attackBite = new Attack(60, 111, 5, false, true, 30, -10);
			attackBite.setOffset(0, 0);
			attacks.push(attackBite);
		}
		
		override public function update():void
		{
			if (health <= 0)
			{
				chompSFXarray[0].stop();
				chompSFXarray[1].stop();
				chompSFXarray[2].stop();
				chompSFXarray[3].stop();
			}
			super.update();
			if (facingLeft)
			{
				attackBite.setOffset(0, 0);
			} 
			else
			{
				attackBite.setOffset(-attackBite.width + width, 0);
			}
			attackBite.update(x, y, facingLeft);
		}
		
		override public function movement():void 
		{
			if (!started)
				return;
			switch (state)
			{
				case RUNNING:
					xV += speed * (facingLeft ? -1 : 1);
					if ((player.x + player.width / 2 < x + width / 2 && !facingLeft)
					 || (player.x + player.width / 2 > x + width/2 && facingLeft))
					{
						state = SLIDING;
						spritesheet.changeAnim("slide");
					}
					break;
				case SLIDING:
					if (Math.abs(xV) < 0.25)
					{
						state = STOPPED;
						spritesheet.changeAnim("stop");
						var timer:Timer = new Timer(stopTime, 1);
						timer.addEventListener(TimerEvent.TIMER, function():void {
							state = RUNNING;
							spritesheet.changeAnim("walk");
							facingLeft = (player.x + player.width / 2 < x + width / 2)
						});
						timer.start();
					}
					break;
			}
		}
		
	}

}