package net.natpat.fighting 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import net.natpat.particles.Emitter;
	import net.natpat.utils.Sfx;
	import net.natpat.utils.Timer;
	import net.natpat.Assets;
	import net.natpat.SpriteSheet;
	import net.natpat.utils.Key;
	import net.natpat.Input;
	import net.natpat.GC;
	import net.natpat.GV;
	import net.natpat.utils.TweenManager;
	import org.flashdevelop.utils.FlashConnect;
	/**
	 * ...
	 * @author Archie Evans
	 */
	public class FightPlayer 
	{
		public var x:          Number =  100;
		public var y:          Number = 500;
		public var width:      Number =  30;
		public var height:     Number = 102;
		public var faceWidth:  Number =  20;
		public var faceHeight: Number =  20;
		public var spriteWidth:Number = 180;
		public var spriteHeight:Number = 140;
		public var spriteXOffset:Number = 70;
		public var spriteYOffset:Number = 39;
		public var xV:         Number =   0;
		public var yV:         Number =   0;
		public var health:     Number = 50;
		public var damage:     Number =   5;
		private var speed:     Number = 2;
		public var yDiff: Number;
		public var xDiff: Number;
		
		public var invincibleTime: Number = 1000;
		public var stopTime:       Number =  250;
		public var punchTime:      Number =  500;
		
		public var numberOfFlashes:Number = 7;
		
		public var fighterColour: uint;
		public var deadColour:    uint;
		public var faceColour:    uint;
		public var hitColour:     uint;
		
		public var dead:        Boolean = false;
		public var facingLeft:  Boolean = false;
		public var hit:         Boolean = false;
		public var stopped:     Boolean = false;
		private var punching:   Boolean = false;
		private var moving:     Boolean = false;
		private var jumping:    Boolean = false;
		public var keyPressed:Boolean = false;

		private var visible:Boolean = true;
		
		public var healthBar: HealthBar;
		public var monster: Monster;
		
		public var attacks: Array;
		public var punchSfxArray: Array;
		private var hitSFXarray:Array;
		
		private var punchAttack:Attack;
		
		public var spritesheet:SpriteSheet;
		private var bitmapData:BitmapData;
		private var animOn:   String;			
		
		private var fightManager:FightManager;
		
		
		public var jumpSFX1:Sfx;
		public var jumpSFX2:Sfx;
		public var deathSFX:Sfx;
		public var squish1SFX:Sfx;
		public var squish2SFX:Sfx;
		//public var crunchSFX:Sfx;
		
		public var started:Boolean = false;
		
		private var emitters:Array;
		private var blood:BitmapData;
		
		public function FightPlayer(fightManager:FightManager, _attacks:Array, _monster:Monster) 
		{
			this.fightManager = fightManager;
			attacks = _attacks;
			monster = _monster;
			
			fighterColour = 0xFF00FF00;
			deadColour = 0xFFC6F2E9;
			faceColour = 0xFF0C8400;
			hitColour = 0xFFE48484;
			
			healthBar = new HealthBar(health, Assets.HEALTHBARFIGHTER);
			spritesheet = new SpriteSheet(Assets.FIGHTER, 180, 140);
			spritesheet.addAnim("standing", [[0, 0, 0.1], [1, 0, 0.1], [2, 0, 0.1], [3, 0, 0.1]], true);
			spritesheet.addAnim("running", [[0, 1, 0.1], [1, 1, 0.1], [2, 1, 0.1]], true);
			spritesheet.addAnim("punching", [[0, 2, 0.05], [1, 2, 0.05], [2, 2, 0.1, addPunch], [3, 2, 0.3], [3, 2, 0.1, stopPunching]], true);
			
			spritesheet.addAnim("jumpup", [[0, 3, 0.1]], true);
			spritesheet.addAnim("float", [[1, 3, 0.1]], true);
			spritesheet.addAnim("jumpdown", [[2, 3, 0.1]], true);
			
			changeAnim("standing");
			bitmapData = new BitmapData(spriteWidth, spriteHeight, true, 0);
			
			punchSfxArray = new Array();
			punchSfxArray.push(new Sfx(Assets.FIGHTER_PUNCH_2));
			punchSfxArray.push(new Sfx(Assets.FIGHTER_PUNCH_3));
			punchSfxArray.push(new Sfx(Assets.FIGHTER_PUNCH_4));
			punchSfxArray.push(new Sfx(Assets.FIGHTER_PUNCH_5));
			punchSfxArray.push(new Sfx(Assets.FIGHTER_PUNCH_6));
			
			hitSFXarray = new Array();
			hitSFXarray.push(new Sfx(Assets.HIT_SOUND_1));
			hitSFXarray.push(new Sfx(Assets.HIT_SOUND_2));
			hitSFXarray.push(new Sfx(Assets.HIT_SOUND_3));
			hitSFXarray.push(new Sfx(Assets.HIT_SOUND_4));
			//crunchSFX = new Sfx(Assets.MUNCH_SFX);
			
			attackMaker();
			emitters = new Array();
			blood = Bitmap(new Assets.BLOOD).bitmapData;
			for (var i:int = 0; i < 5; i++)
			{
				var bloodBitmapData:BitmapData = new BitmapData(25, 25, true, 0);
				bloodBitmapData.copyPixels(blood, new Rectangle(i * 25, 0, 25, 25), GC.ZERO);
				emitters.push(new Emitter(bloodBitmapData, 25, 25));
				emitters[i].setMotion(0, 500, 8, 180, 700, 0.25);
				emitters[i].setGravity(8000);
			}
			
		}
		
		public function render(buffer:BitmapData):void
		{
			if (hit)
			{
				drawFighter(hitColour, buffer);
			}
			else
			{
				if (!dead)
				{
					drawFighter(fighterColour, buffer);
				}
				else
				{
					drawFighter(deadColour, buffer);
				}
			}
			
			healthBar.render(buffer);
			
			bitmapData.fillRect(bitmapData.rect, 0);
			spritesheet.render(bitmapData, 0, 0);
			var matrix:Matrix = new Matrix();
			matrix.translate(-spriteWidth / 2, -spriteHeight / 2);
			matrix.scale((facingLeft ? -1 : 1), 1);
			matrix.translate(spriteWidth / 2, spriteHeight / 2);
			
			if(facingLeft)
				matrix.translate(x - spriteXOffset, y - spriteYOffset);
			else
				matrix.translate(x + width + spriteXOffset - spriteWidth, y - spriteYOffset);
			
			if (visible && !dead)
				buffer.draw(bitmapData, matrix);
			
			for each(var emitter:Emitter in emitters)
				emitter.render(buffer);
		}
		
		public function drawFighter(_colour:uint, buffer:BitmapData):void
		{
			if (GV.debug)
			{
				// Draw Body
				
				buffer.fillRect(new Rectangle(x, y, width, height), _colour);
				
				// Draw Face
				
				if (facingLeft)
				{
					buffer.fillRect(new Rectangle(x, y, faceWidth, faceHeight), faceColour);
				}
				else
				{
					buffer.fillRect(new Rectangle(x + (width - faceWidth), y, faceWidth, faceHeight), faceColour);
				}
			}
		}
		
		public function update():void
		{
			if (!dead)
			{				
				hitDetection();
			}
			if (started)
				movement();
			
			if (y + height > 500)
			{
				y = 500 - height;
				yV = 0;
				jumping = false;
			}
			
			if (x < 0)
				x = 0;
			if (x + width > GC.SCREEN_WIDTH)
				x = GC.SCREEN_WIDTH - width;
			
			if (Input.keyPressed(Key.SPACE) && !punching && !stopped && started)
			{
				startPunching();
			}
			
			if (facingLeft)
			{
				punchAttack.setOffset(-punchAttack.width, 10);
			} 
			else
			{
				punchAttack.setOffset(width, 10);
			}
			punchAttack.update(x, y, facingLeft);
			
			
			healthBar.update(health);
			setCorrectAnim();
			spritesheet.update();
			
			if (health <= 0 && !dead)
			{
				dead = true;
				fightManager.lose();
				deathSFX = new Sfx(Assets.FIGHTER_DEATH);
				squish1SFX = new Sfx(Assets.DEATH_SPLAT_1);
				squish2SFX = new Sfx(Assets.DEATH_SPLAT_2);
				deathSFX.play();
				if (Math.random() < 0.5) squish1SFX.play() else squish2SFX.play();
				
				for (var i:int = 0; i < emitters.length; i++)
				{
					emitters[i].x = x;
					emitters[i].y = y;
					var j:int = 0;
					while (j < 20)
					{
						emitters[i].emit(GV.rand(width) - width/2, GV.rand(height) - height/2);
						j++
					}
				}
			}
			
			for each(var emitter:Emitter in emitters)
				emitter.update();
		}
		
		public function movement():void
		{			
			var yTemp: Number = y;
			var xTemp: Number = x;
			
			// MOVEMENT
			
			// x movement
			if (!dead && !stopped)
			{
				keyPressed = false;
				moving = false;
				if (Input.keyDown(Key.RIGHT))
				{
					moving = true;
					if (!punching)
					{
						xV += speed;
						facingLeft = false;
					}
					else
						xV += speed / 2;
					keyPressed = true;
				}
				
				if (Input.keyDown(Key.LEFT))
				{
					moving = true;
					if (!punching)
					{
						xV -= speed;
						facingLeft = true;
					}
					else
						xV -= speed / 2;
					keyPressed = true;
				}
			}
			
			xV = xV * GC.FRICTION;
			
			x += xV;
			
			if (!dead && !stopped)
			{
				//xCharacterCollision(xTemp);
			}
			
			// y movement
			if (!dead && !stopped)
			{
				if (Input.keyDown(Key.UP) && (yV == 0))
				{
					yV = -16;
					jumping = true;
					jumpSFX1 = new Sfx(Assets.FIGHTER_JUMP);
					jumpSFX2 = new Sfx(Assets.FIGHTER_PUNCH_1);
					if (Math.random() < 0.5)
					{
						jumpSFX1.play();
					}
					else
					{
						jumpSFX2.play();
					}
				}
			}
			
			yV += GC.GRAVITY;
			
			y += yV;
			
			if (!dead && !stopped)
			{
				//yCharacterCollision(yTemp);
			}
			
		}
		
		public function yCharacterCollision(_yTemp:Number):void
		{			
			yDiff = _yTemp - y;
			
			while (GV.intersects(/* fighter */ x, y, width, height, /* monster */ monster.x, monster.y, monster.width, monster.height))
			{
				//yV = 4;
				
				y += yDiff / 100;
				yV = 0;
			}
			
		}
		
		public function xCharacterCollision(_xTemp:Number):void
		{			
			xDiff = _xTemp - x;
			
			if (GV.intersects(/* fighter */ x, y, width, height, /* monster */ monster.x, monster.y, monster.width, monster.height))
			{
			//	if (
			}
			
		}
		
		public function hitDetection():void
		{
			if (hit)
				return;
				
			for each(var attack:Attack in attacks)
			{
				if (attack.friendly)
					continue;
				if (GV.intersects(/* fighter */ x, y, width, height, /* attack */ attack.x, attack.y, attack.width, attack.height))
				{
					if (attack.knockback)
					{
						xV = attack.xKnockbackStrength;
						yV = attack.yKnockbackStrength;
					}
					health = health - attack.damage;
					hit = true;
					stopped = true;
					if (punching)
						stopPunching();
					GV.freeze(0, 100);
					
				//	crunchSFX.play();
					hitSFXarray[GV.rand(hitSFXarray.length)].play();
					
					// invulnerability timer
					
					var invincibleTimer:Timer = new Timer(invincibleTime / (numberOfFlashes * 2), numberOfFlashes * 2);
					invincibleTimer.addEventListener(TimerEvent.TIMER, function():void { visible = !visible } );
					invincibleTimer.addEventListener(TimerEvent.TIMER_COMPLETE, stopInvincibility);
					invincibleTimer.start();
					
					// stop movement
					
					var stopTimer:Timer = new Timer(stopTime, 1);
					stopTimer.addEventListener(TimerEvent.TIMER, stopMovement);
					stopTimer.start();
				}
			}
		}
			
		public function stopInvincibility(e:TimerEvent):void
		{
			hit = false;
		//	crunchSFX.stop();
			hitSFXarray[0].stop();
			hitSFXarray[1].stop();
			hitSFXarray[2].stop();
			hitSFXarray[3].stop();
		}
		
		public function stopMovement(e:TimerEvent):void
		{
			stopped = false;
		}
		
		public function attackMaker():void
		{
			//punchAttack = new Attack(60, 40, 10, true, true, 15, -8);
			punchAttack = new Attack(60, 40, 10, true, true, 0, 0);
		}
		
		public function startPunching():void
		{
			punching = true;
			punchSfxArray[GV.rand(punchSfxArray.length)].play();
		}
		
		public function addPunch():void
		{
			
			attacks.push(punchAttack);
		}
		
		public function stopPunching():void
		{
			var index:int = attacks.indexOf(punchAttack);
			//trace("index:" + index);
			punching = false;
			if (index == -1)
				return;
			attacks.splice(index, 1);
			moving = false;
		}
		
		private function setCorrectAnim():void
		{
			if (punching)
			{
				if (animOn != "punching")
					changeAnim("punching");
				return;
			}
			if (jumping)
			{
				if (yV < -5 && animOn != "jumpup")
					changeAnim("jumpup");
				else if (yV > 5 && animOn != "jumpdown")
					changeAnim("jumpdown");
				else if (Math.abs(yV) < 5 && animOn != "float")
					changeAnim("float");
				return;
			}
			if (moving)
			{
				if (animOn != "running")
					changeAnim("running");
				return;
			}
			if (animOn != "standing")
			{
				changeAnim("standing");
			}
			
		}
		
		private function changeAnim(anim:String):void
		{
			animOn = anim;
			spritesheet.changeAnim(anim);
		}
		
		public function start():void
		{
			started = true;
		}
	}
}