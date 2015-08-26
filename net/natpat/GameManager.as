package net.natpat 
{
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import net.natpat.dialog.Episode;
	import net.natpat.dialog.EpisodeProvider;
	import net.natpat.dialog.MonsterSplash;
	import net.natpat.gui.Button;
	import net.natpat.gui.InputBox;
	import net.natpat.particles.Emitter;
	import net.natpat.utils.Sfx;
	import net.natpat.utils.Timer;
	
	import net.natpat.gui.Text;
	import net.natpat.gui.GuiManager
	import net.natpat.utils.Ease;
	import net.natpat.utils.Key;
    import net.natpat.utils.TweenManager;
	
	import net.natpat.fighting.FightManager;
	
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class GameManager 
	{
		public var state:int = GameStates.TITLE_SCREEN;
		
		/**
		 * Bitmap and bitmap data to be drawn to the screen.
		 */
		public var bitmap:Bitmap;
		public static var renderer:BitmapData;
		
		public var fightManager: FightManager;
		private var episodeManager:Episode;
		private var titleScreen:TitleScreen;
		private var monsterSplash:MonsterSplash;
		private var deteciveSplash:DetectiveSplash;
		private var phonecall:PhoneCall;
		private var levelSelect:LevelSelect;
		
		private var _episodeProvider:EpisodeProvider;
		
		private var blackScreen:BitmapData;
		private var blackScreenVisible:Boolean;
		public var blackScreenAlpha:Number = 0;
		
		public var investigationMusic:Sfx;
		
		public var changing:Boolean;
		
		public function GameManager(stageWidth:int, stageHeight:int) 
		{
			GC.SCREEN_WIDTH = stageWidth;
			GC.SCREEN_HEIGHT = stageHeight;
			
			renderer = new BitmapData(stageWidth, stageHeight, false, 0x000000);
			
			bitmap = new Bitmap(renderer);
			
			blackScreen = new BitmapData(GC.SCREEN_WIDTH, GC.SCREEN_HEIGHT, true, 0xff000000);
			
			GV.screen = renderer;
			
			titleScreen = new TitleScreen(this);
		}

		public function render():void
		{
			if (GV.frozen)
				return;
			renderer.lock();
			
			//Render the background
			renderer.fillRect(new Rectangle(0, 0, renderer.width, renderer.height), 0xBAB7A2);
			
			GuiManager.render(GV.screen);
			
			switch(state) {
				case GameStates.TITLE_SCREEN:
					titleScreen.render(GV.screen);
					break;
				case GameStates.DETECTIVE:
					episodeManager.render(GV.screen)
					break;
				case GameStates.FIGHT:
					fightManager.render();
					break;
				case GameStates.MONSTER_SPLASH:
					monsterSplash.render(GV.screen);
					break;
				case GameStates.DETECTIVE_SPLASH:
					deteciveSplash.render(GV.screen);
					break;
				case GameStates.PHONE_CALL:
					phonecall.render(GV.screen);
					break;
				case GameStates.LEVEL_SELECT:
					levelSelect.render(GV.screen);
					break;
			}
			
			if (blackScreenVisible)
			{
				var colourTransform:ColorTransform = new ColorTransform(1, 1, 1, blackScreenAlpha);
				renderer.draw(blackScreen, null, colourTransform);
			}
				
			bitmap.x = GV.camera.x;
			bitmap.y = GV.camera.y;
			
			renderer.unlock();
		}
		
		public function update():void
		{
			if (GV.frozen)
				return;
				
			GuiManager.update();
            TweenManager.update();
			Timer.update();
			
			switch(state) {
				case GameStates.TITLE_SCREEN:
					titleScreen.update();
					break;
				case GameStates.DETECTIVE:
					episodeManager.update()
					break;
				case GameStates.FIGHT:
					fightManager.update();
					break;
				case GameStates.DETECTIVE_SPLASH:
					deteciveSplash.update();
					break;
				case GameStates.PHONE_CALL:
					phonecall.update();
					break;
				case GameStates.LEVEL_SELECT:
					levelSelect.update();
					break;
			}
			
			Input.update();
			
		}
		
		
		public function finishedTitleScreen():void
		{
			if (state != GameStates.TITLE_SCREEN)
				return;
			if (changing)
				return;
				
			changing = true;
				
			blackScreenVisible = true;
			var tween:int = TweenManager.newTween(function(t:Number):void { 
				blackScreenAlpha = 1 - (((t - 0.5) * 2) * ((t - 0.5) * 2));
				if (t > 0.5 && state != GameStates.DETECTIVE_SPLASH) {
					startDetectiveSplash();
				}
			}, 3.0, null, false, function():void { 
				blackScreenVisible = false;
				changing = false;
			} );
		}
		public function startDetectiveSplash():void
		{
			state = GameStates.DETECTIVE_SPLASH;
			deteciveSplash = new DetectiveSplash(this);
		}
		
		public function finishedDetectiveSplash():void
		{
			if (state != GameStates.DETECTIVE_SPLASH)
				return;
				
			if (changing)
				return;
				
			changing = true;
			blackScreenVisible = true;
			var tween:int = TweenManager.newTween(function(t:Number):void { 
				blackScreenAlpha = 1 - (((t - 0.5) * 2) * ((t - 0.5) * 2));
				if (t > 0.5 && state != GameStates.LEVEL_SELECT) {
					startLevelSelect();
				}
			}, 3.0, null, false, function():void { 
				blackScreenVisible = false;
				changing = false;
			} );
		}
		
		public function startLevelSelect():void
		{
			levelSelect = new LevelSelect(this);
			state = GameStates.LEVEL_SELECT;
		}
		
		public function finishLevelSelect(episode:int):void
		{
			if (changing)
				return;
				
					GV.track("episode" + episode + "/start");
			GV.currentEpisode = episode;
				
			changing = true;
			_episodeProvider = new EpisodeProvider(Assets["EPISODE" + episode]);
			blackScreenVisible = true;
			var tween:int = TweenManager.newTween(function(t:Number):void { 
				blackScreenAlpha = 1 - (((t - 0.5) * 2) * ((t - 0.5) * 2));
				if (t > 0.5 && state != GameStates.DETECTIVE) {
					startIntro();
				}
			}, 3.0, null, false, function():void { 
				blackScreenVisible = false;
				changing = false;
			} );
		}
		
		public function startIntro():void
		{
			episodeManager = new Episode(this, _episodeProvider);
			episodeManager.start();
			state = GameStates.DETECTIVE;
		}
		
		public function finishedIntro():void
		{
			if (changing)
				return;
				
			changing = true;
			blackScreenVisible = true;
			var tween:int = TweenManager.newTween(function(t:Number):void { 
				blackScreenAlpha = 1 - (((t - 0.5) * 2) * ((t - 0.5) * 2));
				if (t > 0.5 && state != GameStates.PHONE_CALL) {
					startPhoneCall();
				}
			}, 1.0, null, false, function():void { 
				blackScreenVisible = false;
				changing = false;
			} );
		}
		
		public function startPhoneCall():void
		{
			state = GameStates.PHONE_CALL;
			phonecall = new PhoneCall(this, _episodeProvider);
		}
		
		public function finishedPhoneCall():void
		{
			if (changing)
				return;
				
			changing = true;
			blackScreenVisible = true;
			var tween:int = TweenManager.newTween(function(t:Number):void { 
				blackScreenAlpha = 1 - (((t - 0.5) * 2) * ((t - 0.5) * 2));
				if (t > 0.5 && state != GameStates.DETECTIVE) {
					startDetective();
				}
			}, 1.0, null, false, function():void { 
				blackScreenVisible = false;
				changing = false;
			} );
		}
		
		public function startDetective():void
		{
			episodeManager.playInvestigationMusic();
			state = GameStates.DETECTIVE;
		}
		
		public function finishedDetective():void
		{
			GV.track("episode" + GV.currentEpisode + "/" + "fightstart");
			state = GameStates.MONSTER_SPLASH;
			monsterSplash = new MonsterSplash(this, _episodeProvider);
		}
		
		public function finishedMonsterSplash():void
		{
			state = GameStates.FIGHT;
			fightManager = new FightManager(this, _episodeProvider);
		}
		
		public function finishedFight():void
		{
			if (changing)
				return;
				
			changing = true;
			blackScreenVisible = true;
			var tween:int = TweenManager.newTween(function(t:Number):void { 
				blackScreenAlpha = 1 - (((t - 0.5) * 2) * ((t - 0.5) * 2));
				if (t > 0.5 && state != GameStates.LEVEL_SELECT) {
					startLevelSelect();
				}
			}, 3.0, null, false, function():void { 
				blackScreenVisible = false;
				changing = false;
			} );
		}
	}

}
