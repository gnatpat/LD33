package net.natpat.fighting.monsters 
{
	import net.natpat.fighting.Monster;
	import flash.display.BitmapData;
	import flash.events.TimerEvent;
	import net.natpat.utils.Sfx;
	import net.natpat.utils.Timer;
	import net.natpat.GC;
	import net.natpat.GV;
	import net.natpat.SpriteSheet;
	import net.natpat.fighting.MonsterHealthBar;
	import net.natpat.Assets;
	import net.natpat.fighting.Attack;
	import net.natpat.fighting.FightManager;
	
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class DoctorMonster extends Monster 
	{
		
		private var speed:Number = 1.2;
		private var slamAttack:Attack;
		private var slamAttackDown1:Attack;
		private var slamAttackDown2:Attack;
		private var slamAttackDown3:Attack;
		private var slamAttackOffset:int;
		private var slamAttackDown1Offset:int;
		private var slamAttackDown2Offset:int;
		private var slamAttackDown3Offset:int;
		private var passiveAttack:Attack;
		private var currentAttack:Attack;
		
		private static const MOVING:int = 0;
		private static const WAITING:int = 1;
		private static const ATTACKING:int = 2;
		
		private var state:int = 0;
		
		public var attackSlamSFX: Sfx;
		public var attackSquelchSFX: Sfx;
		public var attackSwingSFX: Sfx;
		
		public function DoctorMonster(fightManager:FightManager, _attacks:Array) 
		{
			super(fightManager, _attacks);
			facingLeft = true;
			healthBar = new MonsterHealthBar(health, Assets.HEALTHBARDOCTOR);
			spriteWidth = 460;
			spriteHeight = 400;
			spritesheet = new SpriteSheet(Assets.FIGHTDOCTOR, spriteWidth, spriteHeight);
			attackSlamSFX = new Sfx(Assets.DOCTOR_ATTACK_SLAM);
			attackSquelchSFX = new Sfx(Assets.DEATH_SPLAT_1);
			attackSwingSFX = new Sfx(Assets.DOCTOR_ATTACK_SWING);
			spritesheet.addAnim("attacking", [[0, 1, 0.075, function():void { setOffsets(177, 283); } ], 
			                                  [1, 1, 0.075, function():void { setOffsets(178, 284); }], 
											  [2, 1, 0.075, function():void { setOffsets(172, 276); }], 
											  [3, 1, 0.075, function():void { setOffsets(188, 268); }], 
											  [4, 1, 0.075, function():void { setOffsets(217, 252); }], 
											  [5, 1, 0.075, function():void { setOffsets(246, 248); }], 
											  [6, 1, 0.075, function():void { setOffsets(258, 247); }], 
											  [7, 1, 0.075, function():void { addAttack(slamAttackDown3); setOffsets(253, 236); }], 
											  [8, 1, 0.075, function():void { addAttack(slamAttackDown1); setOffsets(240, 245); } ],
											  [9, 1, 0.075, function():void { addAttack(slamAttackDown2); setOffsets(244, 252); }], 
											  [10, 1, 0.075, function():void { 
																				addAttack(slamAttack);
																				GV.shake(0.5, 15);
																				attackSlamSFX.play();
																				attackSquelchSFX.play();
																				setOffsets(262, 264);
																			 }], 
											  [11, 1, 0.5, function():void { removeAttack(slamAttack); setOffsets(258, 261); }], 
											  [12, 1, 0.075, function():void { setOffsets(234, 266); }], 
											  [13, 1, 0.075, function():void { setOffsets(203, 273); }], 
											  [14, 1, 0.075, function():void { finishAttacking(); }]], true);
			spritesheet.addAnim("floating", [[3, 0, 0.2], [2, 0, 0.3], [1, 0, 0.2], [0, 0, 0.3]], true);
			spritesheet.addAnim("slap", [[12, 1, 0.1]], true);
			spritesheet.changeAnim("floating");
			bitmapData = new BitmapData(spriteWidth, spriteHeight);
			width = 60;
			height = 115;
			spriteXOffset = 165;
			spriteYOffset = 270;
			
			slamAttack = new Attack(205, 40, 10, false, true, 50, -5);
			slamAttackDown1 = new Attack(100, 100, 10, false, true, 50, 5);
			slamAttackDown2 = new Attack(100, 180, 10, false, true, 50, 5);
			slamAttackDown3 = new Attack(200, 100, 10, false, true, 50, 5);
			
			slamAttackOffset = -160;
			slamAttackDown1Offset = -20;
			slamAttackDown2Offset = -130;
			slamAttackDown3Offset = 60;
			
			passiveAttack = new Attack(40, height, 10, false, true, 50, -5);
			attacks.push(passiveAttack);
			passiveAttack.setOffset(10, 0);
			friction = 0.7;
		}
		
		private function setOffsets(x:int, y:int):void
		{
			if (facingLeft)
				hitboxOffsetX = x - spriteXOffset;
			else 
				hitboxOffsetX = - x + spriteXOffset;
			hitboxOffsetY = y - spriteYOffset;
		}
		
		private function resetOffsets():void
		{
			hitboxOffsetX = hitboxOffsetY = 0;
		}
		
		private function AI():void
		{
			switch(state)
			{
				case MOVING:
					var offset:int = (slamAttackOffset * -1);
					//trace(Math.abs((player.x + player.width / 2) - (x + width / 2)));
					if (Math.abs((player.x + player.width / 2) - (x + width / 2)) < offset)
					{
						state = WAITING;
						var timer:Timer = new Timer(500, 1);
						timer.addEventListener(TimerEvent.TIMER, function():void {
							state = ATTACKING;
							attackSwingSFX.play();
							spritesheet.changeAnim("attacking");
						});
						timer.start();
					}
			}
		}
		
		override public function update():void 
		{
			if (started)
				AI();
			
			super.update();
			
			if (facingLeft)
			{
				slamAttack.setOffset(slamAttackOffset, 90);
				slamAttackDown1.setOffset(slamAttackDown1Offset, -200);
				slamAttackDown2.setOffset(slamAttackDown2Offset, -180);
				slamAttackDown3.setOffset(slamAttackDown3Offset, -200);
			}
			else 
			{
				slamAttack.setOffset(width - slamAttackOffset - slamAttack.width, 90);
				slamAttackDown1.setOffset(width - slamAttackDown1Offset - slamAttackDown1.width, -200);
				slamAttackDown2.setOffset(width - slamAttackDown2Offset - slamAttackDown2.width, -180);
				slamAttackDown3.setOffset(width - slamAttackDown3Offset - slamAttackDown3.width, -200);
			}
			slamAttack.update(x, y, facingLeft);
			slamAttackDown1.update(x, y, facingLeft);
			slamAttackDown2.update(x, y, facingLeft);
			slamAttackDown3.update(x, y, facingLeft);
			passiveAttack.update(x, y, facingLeft);
		}
		
		override public function movement():void 
		{
			if (state != MOVING || !started)
				return;
			if (player.x + player.width / 2 < x + width / 2)
			{
				facingLeft = true;
				xV -= speed;
			} 
			else
			{
				facingLeft = false;
				xV += speed;
				
			}
		}
		
		public function finishAttacking():void
		{
			state = MOVING;
			resetOffsets();
			spritesheet.changeAnim("floating");
			if (player.x + player.width / 2 < x + width / 2)
			{
				facingLeft = true;
			} 
			else
			{
				facingLeft = false;
				
			}
		}
		
		public function addAttack(attack:Attack):void
		{
			if (currentAttack)
				removeAttack(currentAttack);
			attacks.push(attack);
			currentAttack = attack;
		}
		
		public function removeAttack(attack:Attack):void
		{
			var index:int = attacks.indexOf(attack);
			if (index != -1)
				attacks.splice(index, 1);
		}
	}

}