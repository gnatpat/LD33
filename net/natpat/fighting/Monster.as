package net.natpat.fighting 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import net.natpat.utils.Sfx;
	import net.natpat.utils.Timer;
	import net.natpat.Assets;
	import net.natpat.SpriteSheet;
	import net.natpat.utils.Key;
	import net.natpat.Input;
	import net.natpat.GC;
	import net.natpat.GV;
	import net.natpat.particles.Emitter;
	/**
	 * ...
	 * @author Archie Evans
	 */
	public class Monster 
	{
		public var x:          Number = 600;
		public var y:          Number = 400;
		public var width:      Number;
		public var height:     Number;
		public var spriteWidth:Number;
		public var spriteHeight:Number;
		public var spriteXOffset:Number;
		public var spriteYOffset:Number;
		public var faceWidth:  Number =  35;
		public var faceHeight: Number =  35;
		public var yV:         Number =   0;
		public var xV:         Number =   0;
		public var health:     Number = 100;
		public var damage:     Number =   5;
		public var hitboxOffsetX:Number = 0;
		public var hitboxOffsetY:Number = 0;

		
		public var monsterColour: uint;
		public var deadColour:    uint;
		public var faceColour:    uint;
		
		public var dead:       Boolean = false;
		public var dying:      Boolean = false;
		public var facingLeft: Boolean = true;
		private var visible:Boolean = true;
		
		public var healthBar: MonsterHealthBar;
		
		public var attacks: Array;
		
		public var spritesheet:SpriteSheet;
		public var bitmapData:BitmapData;
		
		public var invincibleTime: Number = 1000;
		public var hit:         Boolean = false;
		
		public var numberOfFlashes:Number = 5;
		
		protected var player:FightPlayer;
		protected var friction:Number = GC.FRICTION;
		
		public var started:Boolean;
		
		
		private var fightManager:FightManager;
		
		//private var hitSFXarray:Array;
		public var crunchSFX:Sfx;
		
		public var squish1SFX:Sfx;
		public var squish2SFX:Sfx;
		
		private var emitters:Array;
		private var blood:BitmapData;
		
		
		public function Monster(fightManager:FightManager, _attacks:Array ) 
		{
			attacks = _attacks;
			this.fightManager = fightManager;
			
			monsterColour = 0xFFFF00FF;
			deadColour = 0xFFBF78BD;
			faceColour = 0xFF8B0087;
			
		//	hitSFXarray = new Array();
		//	hitSFXarray.push(new Sfx(Assets.HIT_SOUND_1));
		//	hitSFXarray.push(new Sfx(Assets.HIT_SOUND_2));
		//	hitSFXarray.push(new Sfx(Assets.HIT_SOUND_3));
		//	hitSFXarray.push(new Sfx(Assets.HIT_SOUND_4));
			crunchSFX = new Sfx(Assets.MUNCH_SFX);
			
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
		
		public function setPlayer(player:FightPlayer):void
		{
			this.player = player;
		}
		
		public function render(buffer:BitmapData):void
		{
			healthBar.render(buffer);
			
			if (!dead)
			{
				drawMonster(monsterColour, buffer);
				
				bitmapData.fillRect(bitmapData.rect, 0);
				
				spritesheet.render(bitmapData, 0, 0);
				
				var matrix:Matrix = new Matrix();
				matrix.translate(-spriteWidth / 2, -spriteHeight / 2);
				matrix.scale((facingLeft ? 1 : -1), 1);
				matrix.translate(spriteWidth / 2, spriteHeight / 2);
				
				if(facingLeft)
					matrix.translate(x - spriteXOffset, y - spriteYOffset);
				else
					matrix.translate(x + width + spriteXOffset - spriteWidth, y - spriteYOffset);
				if(visible || dying)
					buffer.draw(bitmapData, matrix);
			}
			else
			{
				drawMonster(deadColour, buffer);
			}
			for each(var attack:Attack in attacks)
			{
				attack.render(buffer);
			}
			
			for each(var emitter:Emitter in emitters)
				emitter.render(buffer);
		}
		
		public function drawMonster(_colour:uint, buffer:BitmapData):void
		{
			if (GV.debug)
			{
				// Draw Body
				
				buffer.fillRect(new Rectangle(x + hitboxOffsetX, y + hitboxOffsetY, width, height), _colour);
				
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
			if (health <= 0 && !dead)
			{
				dead = true;
				fightManager.win();
				attacks.splice(0, 1000);
				started = false;
				dying = false;
				//deathSFX = new Sfx(Assets.FIGHTER_DEATH);
				squish1SFX = new Sfx(Assets.DEATH_SPLAT_1);
				squish2SFX = new Sfx(Assets.DEATH_SPLAT_2);
				//deathSFX.play();
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
			
			if (!dead)
			{
				hitDetection();
				movement();
			}
			
			yV += GC.GRAVITY;
			
			y += yV;
			
			xV *= friction;
			x += xV;
			
			if (y + height > 500)
			{
				y = 500 - height;
				yV = 0;
			}
			
			if (x < 0)
			{
				xV = 0;
				x = 0;
			}
			if (x + width > GC.SCREEN_WIDTH)
			{
				x = GC.SCREEN_WIDTH - width;
				xV = 0;
			}
			
			healthBar.update(health);
			spritesheet.update();
			
			
			for each(var emitter:Emitter in emitters)
				emitter.update();
		}
		
		public function movement():void
		{
			// MOVEMENT
			
			// y movement
			
			// x movement
		}
		
		public function hitDetection():void
		{
			if (hit)
				return;
			for each(var attack:Attack in attacks)
			{
				if (!attack.friendly)
					continue;
				if (GV.intersects(/* monster */ x + hitboxOffsetX, y + hitboxOffsetY, width, height, /* attack */ attack.x, attack.y, attack.width, attack.height))
				{
					if (attack.knockback)
					{
						xV = attack.xKnockbackStrength;
						yV = attack.yKnockbackStrength;
					}
					health = health - attack.damage;
					hit = true;
					crunchSFX.play();
				//	hitSFXarray[GV.rand(hitSFXarray.length)].play();
					if (health <= 0)
					{
						dying = true;
						GV.freezeNow(400);
					}
					else
					{
						GV.freeze(10, 100);
					}
					
					// invulnerability timer
					var invincibleTimer:Timer = new Timer(invincibleTime / (numberOfFlashes * 2), numberOfFlashes * 2);
					invincibleTimer.addEventListener(TimerEvent.TIMER, function():void { visible = !visible } );
					invincibleTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void { 
																									hit = false;																									
																								//	hitSFXarray[0].stop();
																								//	hitSFXarray[1].stop();
																								//	hitSFXarray[2].stop();
																								//	hitSFXarray[3].stop();
																									crunchSFX.stop();
																								});
					invincibleTimer.start();
				}
			}
		}
		
		public function start():void
		{
			started = true;
		}
	}

}