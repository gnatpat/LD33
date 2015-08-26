package net.natpat.fighting 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import net.natpat.Assets;
	import net.natpat.dialog.EpisodeProvider;
	import flash.geom.Rectangle;
	import net.natpat.fighting.monsters.ButlerMonster;
	import net.natpat.fighting.monsters.ClownMonster;
	import net.natpat.fighting.monsters.DoctorMonster;
	import net.natpat.GameManager;
	import net.natpat.GC;
	import net.natpat.gui.Text;
	import net.natpat.GV;
	import net.natpat.utils.Sfx;
	import net.natpat.utils.Timer;
	
	/**
	 * ...
	 * @author Archie Evans
	 */
	public class FightManager 
	{
		
		public var fighter: FightPlayer;
		public var monster: Monster;
		public var attacks: Array; 
		
		public var music:Sfx;
		public var winSfx:Sfx;
		public var loseSfx:Sfx;
		public var won:Boolean;
		public var lost:Boolean;
		
		private var introTexts:Array = ["Get ready to fight!",
										"Get ready to fight!",
										"Arrow keys to move!",
										"Arrow keys to move!",
										"Space to punch!",
										"Space to punch!",
										"3",
										"2",
										"1",
										"FIGHT!",
										""];
										
		private var introShowing:int = 0;
		private var introText:Text;
		private var closedText:Text;
		private var caseClosedCounter:int = 0;
		
		private var _episodeProvider:EpisodeProvider;
		private var _gameManager:GameManager;
		
		private var _background:BitmapData;
		
		public function FightManager(gameManager:GameManager, episodeProvider:EpisodeProvider) 
		{
			_episodeProvider = episodeProvider;
			_gameManager = gameManager;
			_background = Bitmap(new Assets[episodeProvider.fight]).bitmapData;
			reset();
		}
		
		public function reset():void
		{
			attacks = new Array();
			if (_episodeProvider.monster == "clown")
				monster = new ClownMonster(this, attacks);
			if (_episodeProvider.monster == "butler")
				monster = new ButlerMonster(this, attacks);
			if (_episodeProvider.monster == "doctor")
				monster = new DoctorMonster(this, attacks);
			fighter = new FightPlayer(this, attacks, monster);	
			monster.setPlayer(fighter);
			
			introShowing = 0;
			
			music = new Sfx(Assets.MUSIC_FIGHT);
			music.play(true);
			winSfx = new Sfx(Assets.MUSIC_VICTORY);
			loseSfx = new Sfx(Assets.MUSIC_DYING);
			
			introText = new Text( -1, 175, "", 36, false, 0);
			closedText = new Text( -1, 225, "", 36, false, 0);
			
			var timer:Timer = new Timer(1000, introTexts.length - 1);
			timer.addEventListener(TimerEvent.TIMER, function(e:Event):void
			{
				showNextText();
			});
			timer.start();
			showNextText();
		}
		
		public function showNextText():void
		{
			introText.text = introTexts[introShowing];
			trace(introText.text);
			introShowing++;
			if (introShowing == introTexts.length)
			{
				monster.start();
				fighter.start();
			}
		}
		
		public function render():void
		{
			GV.screen.copyPixels(_background, _background.rect, GC.ZERO);
			fighter.render(GV.screen);
			monster.render(GV.screen);
			introText.render(GV.screen);
			closedText.render(GV.screen);
		}
		
		public function update():void
		{
			fighter.update();
			monster.update();
		}
		
		public function win():void
		{
			GV.track("episode" + GV.currentEpisode + "/" + "caseclosed");
			music.stop();
			winSfx.play();
			won = true;
			var timer:Timer = new Timer(1000, 4);
			timer.addEventListener(TimerEvent.TIMER, function():void
			{
				if (caseClosedCounter == 0)
				{
					introText.text = "CASE";
					GV.shake(0.5, 10);
				}
				if (caseClosedCounter == 1)
				{
					closedText.text = "CLOSED";
					GV.shake(0.5, 10);
				}
				caseClosedCounter++;
			});
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void
			{
				_gameManager.finishedFight();
			});
			timer.start();
			
		}
		
		public function lose():void
		{
			GV.track("episode" + GV.currentEpisode + "/" + "fightlose");
			music.stop();
			loseSfx.play();
			lost = true;
			var timer:Timer = new Timer(4000, 1);
			timer.addEventListener(TimerEvent.TIMER, function():void
			{
				reset();
			});
			timer.start()
		}
	}

}