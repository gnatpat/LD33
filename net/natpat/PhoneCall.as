package net.natpat 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import net.natpat.dialog.EpisodeProvider;
	import net.natpat.gui.Text;
	import flash.geom.Point;
	import net.natpat.utils.Sfx;
	import net.natpat.utils.Timer;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class PhoneCall 
	{
		
		private var _bitmapDatas:Vector.<BitmapData>;
		private var _currentBackground:int = 0;
		
		private var _gameManager:GameManager;
		private var _episodeProvider:EpisodeProvider;
		private var _textboxBitmapData:BitmapData;
		private var _evidenceBitmapData:BitmapData;
		private var _statementText:Text;
		private var _evidenceText:Text;
		
		private var _currentStatementIndex:int = -1;
		private var _currentStatement:Object;
		private var _currentText:String;
		private var _phonecall:Array;
		private var _characters:int;
		
		private var _textWriteTimer:Timer;
		private var _doneText:Boolean;
		private var _waiting:Boolean;
		
		private var phoneCallMusic:Sfx;
		private var ringingSFX: Sfx;
		
		public function PhoneCall(gameManager:GameManager, episodeProvider:EpisodeProvider) 
		{
			_gameManager = gameManager;
			_episodeProvider = episodeProvider;
			
			phoneCallMusic = new Sfx(Assets.MUSIC_PHONECALL);
			phoneCallMusic.play(true);
			
			ringingSFX = new Sfx(Assets.RING_RING_LONG);
			
			_bitmapDatas = new Vector.<BitmapData>();
			_bitmapDatas.push(Bitmap(new Assets.PHONE_SPLASH1).bitmapData);
			_bitmapDatas.push(Bitmap(new Assets.PHONE_SPLASH2).bitmapData);
			_bitmapDatas.push(Bitmap(new Assets.PHONE_SPLASH3).bitmapData);
			
			_statementText = new Text(25, GC.TEXT_BOX_Y + 25, "", 26, false, 0, true, 760);
			_evidenceText = new Text(GC.EVIDENCE_BOX_X + 25, 20, "Items:", 26, false, 0);
			
			var bitmapData:BitmapData = Bitmap(new Assets.TEXT_BOX).bitmapData;
			var matrix:Matrix = new Matrix();
			matrix.scale(GC.CHARACTER_SCALE, GC.CHARACTER_SCALE);
			_textboxBitmapData = new BitmapData(bitmapData.width * GC.CHARACTER_SCALE,
												bitmapData.height * GC.CHARACTER_SCALE,
												true,
												0);
			_textboxBitmapData.draw(bitmapData, matrix);
			
			bitmapData = Bitmap(new Assets.EVIDENCE_BOX).bitmapData;
			matrix = new Matrix();
			matrix.scale(GC.CHARACTER_SCALE, GC.CHARACTER_SCALE);
			_evidenceBitmapData = new BitmapData(bitmapData.width * GC.CHARACTER_SCALE,
												bitmapData.height * GC.CHARACTER_SCALE,
												true,
												0);
			_evidenceBitmapData.draw(bitmapData, matrix);
			
			_phonecall = _episodeProvider.phonecall;
			trace(_phonecall.length);
			showNextStatement();
		}
		
		public function showNextStatement():void
		{
			if (_waiting)
				return;
			_currentStatementIndex++;
			if (_currentStatementIndex >= _phonecall.length)
			{
				phoneCallMusic.stop();
				_gameManager.finishedPhoneCall();
				return;
			}
			
			
			_currentStatement = _phonecall[_currentStatementIndex];
			if (_currentStatement.picture != null)
			{
				_currentBackground = _currentStatement.picture;
				if (_currentBackground == 2) ringingSFX.stop();
				var timer:Timer = new Timer(1000, 1);
				timer.addEventListener(TimerEvent.TIMER, function(e:Event):void {
					_waiting = false;
					showNextStatement();
				});
				timer.start();
				_waiting = true;
				return;
			}
			else if (_currentStatement.ring)
			{
				ringingSFX.play();
				var ringTimer:Timer = new Timer(1000, 1);
				GV.shake(1, 5);
				_statementText.text = "RING! RING!";
				ringTimer.addEventListener(TimerEvent.TIMER, function(e:Event):void {
					_waiting = false;
					showNextStatement();
				});
				ringTimer.start();
				_waiting = true;
				return;
			}
			else 
			{
				_doneText = false;
				_characters = 0;
				_statementText.text = "";
				_currentText = _currentStatement.text;
				_textWriteTimer = new Timer(1000 / GC.TEXT_SPEED, _currentText.length);
				_textWriteTimer.addEventListener(TimerEvent.TIMER, function(e:Event):void {
					_characters++;
					_statementText.text = _currentText.slice(0, _characters);
				});
				_textWriteTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:Event):void {
					_doneText = true;
					_textWriteTimer.stop();
				});
				_textWriteTimer.start();
			}
			
		}
		
		public function update():void
		{
			if (Input.mousePressed)
			{
				if (!_doneText)
				{
					_doneText = true;
					_textWriteTimer.stop();
					_statementText.text = _currentText;
				} 
				else 
				{
					showNextStatement();
				}
			}
		}
		
		
		
		public function render(buffer:BitmapData):void
		{
			var matrix:Matrix = new Matrix();
			matrix.scale(2, 2);
			matrix.translate( -40, -20);
			buffer.draw(_bitmapDatas[_currentBackground], matrix);
			buffer.copyPixels(_textboxBitmapData, _textboxBitmapData.rect, new Point(0, GC.TEXT_BOX_Y));
			buffer.copyPixels(_evidenceBitmapData, _evidenceBitmapData.rect, new Point(GC.EVIDENCE_BOX_X, 0));
			_evidenceText.render(buffer);
			_statementText.render(buffer);
		}
	}

}

