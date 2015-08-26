package net.natpat.fighting.monsters 
{
	import net.natpat.fighting.Monster;
	import flash.display.BitmapData;
	import flash.events.TimerEvent;
	import net.natpat.fighting.MonsterHealthBar;
	import net.natpat.utils.Sfx;
	import net.natpat.utils.Timer;
	import net.natpat.GC;
	import net.natpat.GV;
	import net.natpat.SpriteSheet;
	import net.natpat.Assets;
	import net.natpat.fighting.Attack;
	import net.natpat.fighting.FightManager;
	
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class ButlerMonster extends Monster 
	{
		private var falling:Boolean;
		
		private var state:int;
		private var turns:int = 0;
		private var xGoal:int;
		private var stopTime:Number = 500;
		private var landTime:Number = 500;
		private var numberOfTurns:int = 3;
		private var speed:int = 3;
		private var walkFriction:int;
		
		private static const RUNNING:int = 0;
		private static const STOPPING:int = 1;
		private static const JUMPING:int = 2;
		private static const STARTJUMP:int = 3;
		private static const LANDED:int = 4;
		private static const PAUSE:int = 5;
		
		private var jumpAttack:Attack;
		private var passiveAttack:Attack;
		
		public var scuttleSFXarray:Array;
		
		public var jumpUpSFX: Sfx;
		public var jumpDownSFX: Sfx;
		
		public function ButlerMonster(fightManager:FightManager, _attacks:Array) 
		{
			super(fightManager, _attacks);
			health = 80;
			
			scuttleSFXarray = new Array();
			scuttleSFXarray.push(new Sfx(Assets.SPIDER_SCUTTLE_1));
			scuttleSFXarray.push(new Sfx(Assets.SPIDER_SCUTTLE_2));
			scuttleSFXarray.push(new Sfx(Assets.SPIDER_SCUTTLE_3));
			scuttleSFXarray.push(new Sfx(Assets.SPIDER_SCUTTLE_4));
			
			jumpUpSFX = new Sfx(Assets.SPIDER_JUMP_UP);
			jumpDownSFX = new Sfx(Assets.SPIDER_JUMP_DOWN);
			
			
			
			healthBar = new MonsterHealthBar(health, Assets.HEALTHBARBUTLER);
			spriteWidth = 360;
			spriteHeight = 280;
			spritesheet = new SpriteSheet(Assets.FIGHTBUTLER, spriteWidth, spriteHeight);
			spritesheet.addAnim("running", [[0, 1, 0.1, function():void { stopScuttle(); scuttleSFXarray[GV.rand(scuttleSFXarray.length)].play() } ], [1, 1, 0.1], [2, 1, 0.1], [3, 1, 0.1]], true);
			spritesheet.addAnim("stand", [[0, 0, 0.1, function():void { stopScuttle() } ]], true);
			spritesheet.addAnim("jumpstart", [[1, 2, 0.3, function():void { stopScuttle() } ], [1, 2, 0.1, jump]], true);
			spritesheet.addAnim("jumpup", [[2, 2, 0.1]], true);
			spritesheet.addAnim("jumpdown", [[3, 2, 0.1]], true);
			spritesheet.changeAnim("running");
			width = 120;
			height = 135;
			spriteXOffset = 140;
			spriteYOffset = 133;
			bitmapData = new BitmapData(spriteWidth, spriteHeight);
			state = RUNNING;
			setToRunning();
			
			jumpAttack = new Attack(240, 30, 10, false, true, 10, -10);
			passiveAttack = new Attack(40, height - 20, 5, false, true, 7, -10);
			attacks.push(passiveAttack);
			
			state = STOPPING;
		}
		
		private function stopScuttle():void
		{
			scuttleSFXarray[0].stop();
			scuttleSFXarray[1].stop();
			scuttleSFXarray[2].stop();
			scuttleSFXarray[3].stop();
		}
		
		private function getNewGoal():void
		{
			xGoal = GV.rand(GC.SCREEN_WIDTH - spriteWidth - 20) + 10 + spriteXOffset;
		}
		
		private function setToRunning():void
		{
			state = RUNNING;
			getNewGoal();
			facingLeft = (xGoal < x);
			friction = GC.FRICTION;
			spritesheet.changeAnim("running");
		}
		
		private function jump():void
		{
			state = JUMPING;
			yV = -20;
			xV = (x - player.x)/(2*-20/GC.GRAVITY)
			friction = 1;
			jumpUpSFX.play();
		}
		
		private function AI():void
		{
			switch(state)
			{
				case RUNNING:
					if ((facingLeft && x < xGoal) || (!facingLeft && x > xGoal))
					{
						turns++
						state = STOPPING;
						var timer:Timer = new Timer(stopTime, 1);
						timer.addEventListener(TimerEvent.TIMER, function():void {
							//trace(turns);
							//trace(numberOfTurns);
							if (turns == numberOfTurns)
							{
								state = STARTJUMP;
								spritesheet.changeAnim("jumpstart");
							}
							else
							{
								setToRunning();
							}
						});
						timer.start();
					}
					break;
				case STOPPING:
					spritesheet.changeAnim("stand");
					break;
				case JUMPING:
					if (yV < 0)
						spritesheet.changeAnim("jumpup");
					else if (yV > 0 && !falling)
					{
						spritesheet.changeAnim("jumpdown");
						falling = true;
						jumpDownSFX.play();
					}
					if (y == 500 - height && yV == 0)
					{
						falling = false;
						spritesheet.changeAnim("stand");
						state = LANDED;
						GV.shake(landTime / 1000, 10);
						addJumpAttack();
						
						var jumpAttackTimer:Timer = new Timer(landTime / 4, 1)
						jumpAttackTimer.addEventListener(TimerEvent.TIMER, function():void {
							removeJumpAttack();
						});
						jumpAttackTimer.start();
						
						var landTimer:Timer = new Timer(landTime, 1);
						landTimer.addEventListener(TimerEvent.TIMER, function():void {
							state = STOPPING;
							var stopTimer:Timer = new Timer(stopTime, 1);
							stopTimer.addEventListener(TimerEvent.TIMER, function():void {
								turns = 0;
								setToRunning();
							});
							stopTimer.start();
						});
						landTimer.start();
					}
					break;
				case LANDED:
					friction = GC.FRICTION;
					break;
				case STOPPING:
					break;
				
			}
		}
		
		override public function update():void 
		{
			if (started)
				AI();
			//trace(friction);
			super.update();
			
			if (health <= 0) 
			{
				stopScuttle();
				jumpDownSFX.stop();
				jumpUpSFX.stop();
			}
			
			var jumpAttackOffset:int = (spriteWidth - jumpAttack.width) / 2;
			var passiveAttackOffset:int = (width - passiveAttack.width) / 2;
			
			if (facingLeft)
				jumpAttack.setOffset(-spriteXOffset + jumpAttackOffset, height - jumpAttack.height);
			else
				jumpAttack.setOffset(width + spriteXOffset - spriteWidth + jumpAttackOffset, height - jumpAttack.height);
			
			if (facingLeft)
				passiveAttack.setOffset(passiveAttackOffset, 20);
			else
				passiveAttack.setOffset(width - passiveAttackOffset - passiveAttack.width, 20);
			
			
			jumpAttack.update(x, y, facingLeft);
			passiveAttack.update(x, y, facingLeft);
		}
		
		override public function start():void 
		{
			super.start();
			
			state = RUNNING;
			spritesheet.changeAnim("running");
		}
		
		override public function movement():void 
		{
			switch (state) {
				case RUNNING:
					if (facingLeft)
						xV -= speed;
					else
						xV += speed;
					break;
			}
		}
		
		public function addJumpAttack():void
		{
			attacks.push(jumpAttack);
		}
		public function removeJumpAttack():void
		{
			attacks.splice(attacks.indexOf(jumpAttack), 1);
		}
	}

}