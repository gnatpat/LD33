package net.natpat.dialog 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GraphicsSolidFill;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextDisplayMode;
	import net.natpat.utils.Sfx;
	import net.natpat.utils.Timer;
	import net.natpat.Assets;
	import net.natpat.GameManager;
	import net.natpat.GC;
	import net.natpat.gui.Text;
	import net.natpat.GV;
	import net.natpat.Input;
	
	import net.natpat.dialog.statements.*;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class Episode 
	{
		private var _gameManager:GameManager;
		private var _episodeProvider:EpisodeProvider;
		
		private var _currentDialog:Array;
		private var _currentDialogName:String;
		private var _currentDialogPos:int;
		private var _currentStatement:Statement;
		private var _currentCharacter:InGameCharacter;
		
		private var _selectedEvidence:InGameEvidence;
		private var _selectedCharacter:InGameCharacter;
		
		private var _evidenceGot:Array;
		
		private var _statementText:Text;
		private var _evidenceText:Text;
		
		private var _characters:Object;
		
		private var _textWriteTimer:Timer;
		private var _charsToShow:int;
		private var _shownAllText:Boolean;
		
		private var _onScreenQuestions:Array;
		
		private var _showingChoices:Boolean;
		private var _showingFirstTimeChat:Boolean;
		
		private var _waiting:Boolean;
		
		private var _backgroundBitmapData:BitmapData;
		private var _textboxBitmapData:BitmapData;
		private var _evidenceBitmapData:BitmapData;
		
		private var introMusic: Sfx;
		public var investigationMusic: Sfx;
		
		private var useOnText:Text;
		
		public function Episode(gameManager:GameManager, episodeProvider:EpisodeProvider) 
		{
			_gameManager = gameManager;
			_episodeProvider = episodeProvider;
			
			_characters = new Object();
			
			introMusic = new Sfx(Assets.MUSIC_EPISODE_OPENING);
			introMusic.play(true);
			investigationMusic = new Sfx(Assets.MUSIC_INVESTIGATION);
			
			var characters:Array = _episodeProvider.getCharacterList();
			for each(var character:Character in characters)
			{
				_characters[character.id] = (new InGameCharacter(character));
			}
			
			_statementText = new Text(25, GC.TEXT_BOX_Y + 25, "", 26, false, 0, true, 760);
			_evidenceText = new Text(GC.EVIDENCE_BOX_X + 25, 20, "Items:", 26, false, 0);
			
			_backgroundBitmapData = new BitmapData(GC.SCREEN_WIDTH, GC.SCREEN_HEIGHT);
			var bitmapData:BitmapData = Bitmap(new Assets[episodeProvider.scene]).bitmapData;
			var matrix:Matrix = new Matrix();
			matrix.scale(GC.CHARACTER_SCALE, GC.CHARACTER_SCALE);
			matrix.translate(_episodeProvider.xOffset, _episodeProvider.yOffset);
			_backgroundBitmapData.draw(bitmapData, matrix);
			
			bitmapData = Bitmap(new Assets.TEXT_BOX).bitmapData;
			matrix = new Matrix();
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
			
			useOnText = new Text(200, 50, "Use on...", 36, false, 0);
		}
		
		public function playInvestigationMusic():void
		{
			investigationMusic.play(true);
		}
		
		public function start():void
		{
			startDialog("start");
			_evidenceGot = new Array();
		}
		
		private function startDialog(dialog:String):void
		{
			if (dialog == "end")
			{
				var timer:Timer = new Timer(3000, 1);
				timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent):void {
					done();
				});
				timer.start();
			}
			
			_currentDialogName = dialog;
			_currentDialog = _episodeProvider.getDialog(dialog);
			_currentDialogPos = 0;
			startStatement();
		}
		
		private function startDialogFromObj(dialog:Array):void
		{
			_currentDialog = dialog;
			_currentDialogPos = 0;
			startStatement();
		}
		
		private function startNextStatement():void
		{
			if (_currentCharacter)
				_currentCharacter.talking = false;
			_currentDialogPos++;
			startStatement();
		}
		
		private function startStatement():void
		{
			if (_currentDialogPos >= _currentDialog.length)
			{
				endDialog();
				return;
			}
			_currentCharacter = null;
			_currentStatement = _currentDialog[_currentDialogPos];
			
			_statementText.text = "";
			_charsToShow = 0;
			_shownAllText = false;
			
			var index:int;
			var i:int;
			
			if (_currentStatement is EvidenceStatement)
			{
				addEvidence(EvidenceStatement(_currentStatement).evidence);
			}
			else if (_currentStatement is AppearStatement) 
			{
				var appearStatement:AppearStatement = AppearStatement(_currentStatement);
				if (appearStatement.when)
				{
					_characters[appearStatement.who.id].visible = true;
					startNextStatement();
					return;
				}
				_characters[appearStatement.who.id].fadeIn(function():void {
					_waiting = false;
					startNextStatement();
				});
				_waiting = true;
				return;
			}
			else if (_currentStatement is DisappearStatement) 
			{
				var disappearStatement:DisappearStatement = DisappearStatement(_currentStatement);
				_characters[disappearStatement.who.id].fadeOut(function():void {
					_waiting = false;
					startNextStatement();
				});
				_waiting = true;
				return;
			}
			else if (_currentStatement is TurnStatement)
			{
				var turnStatement:TurnStatement = TurnStatement(_currentStatement);
				_characters[turnStatement.character.id].setFacing(turnStatement.direction, function():void {
					_waiting = false;
					startNextStatement();
				});
				_waiting = true;
				return;
			}
			else if (_currentStatement is QuestionStatement)
			{
				var questionStatement:QuestionStatement = QuestionStatement(_currentStatement);
				_characters[questionStatement.who.id].unlockQuestion(questionStatement.question);
				startNextStatement();
				return;
			}
			else if (_currentStatement is CancelFirstStatement)
			{
				var cancelFirstStatement:CancelFirstStatement = CancelFirstStatement(_currentStatement);
				_characters[cancelFirstStatement.who.id].hadFirstTimeChat = true;
				startNextStatement();
				return;
			}
			else if (_currentStatement is ChoiceStatement)
			{
				var choiceStatement:ChoiceStatement = ChoiceStatement(_currentStatement);
				var choices:Array = choiceStatement.choices;
				_onScreenQuestions = new Array();
				for each(var choice:Choice in choices)
				{
					_onScreenQuestions.push(new InGameQuestion(choice.text, choice.dialog));
				}
				startNextStatement();
				updateOnScreenQuestions();
				_showingChoices = true;
				return;
			}
			else if (_currentStatement is RemoveQuestionStatement)
			{
				var rmquestionStatement:RemoveQuestionStatement = RemoveQuestionStatement(_currentStatement)
				_characters[rmquestionStatement.who.id].removeQuestion(rmquestionStatement.dialog);
				startNextStatement();
				updateEvidenceList();
				return;
			}
			else if (_currentStatement is RemoveStatement)
			{
				var removeStatement:RemoveStatement = RemoveStatement(_currentStatement);
				index = -1;
				for (i = 0; i < _evidenceGot.length; i++)
				{
					if (_evidenceGot[i].evidence == removeStatement.evidence)
					{
						index = i;
						break;
					}
				}
				if (index == -1)
					throw new Error("Trying to remove out evidence not held.");
					
				_evidenceGot.splice(index, 1);
			}
			else if (_currentStatement is SwitchStatement)
			{
				var switchStatement:SwitchStatement = SwitchStatement(_currentStatement);
				index = -1;
				for (i = 0; i < _evidenceGot.length; i++)
				{
					if (_evidenceGot[i].evidence == switchStatement.from)
					{
						index = i;
						break;
					}
				}
				if (index == -1)
					throw new Error("Trying to swap out evidence not held.");
					
				_evidenceGot.splice(index, 1, new InGameEvidence(switchStatement.to));
				updateEvidenceList();
				startNextStatement();
				return;				
			}
			else if (_currentStatement is InfoStatement)
			{
				
			}
			else if (_currentStatement is GotoStatement)
			{
				var gotoStatement:GotoStatement = GotoStatement(_currentStatement);
				startDialog(gotoStatement.dialog);
				return;
			}
			else
			{
				var textStatement:TextStatement = TextStatement(_currentStatement);
				_currentCharacter = _characters[textStatement.who.id];
				_currentCharacter.talking = true;
				if (textStatement.shake)
					GV.shake(_currentStatement.text.length / GC.TEXT_SPEED, textStatement.shake);
			}
			
			_textWriteTimer = new Timer(1000 / GC.TEXT_SPEED, _currentStatement.text.length)
			_textWriteTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
				_charsToShow++;
				_statementText.text = _currentStatement.text.slice(0, _charsToShow);
			});
			_textWriteTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent):void {
				showAllText();
			});
			_textWriteTimer.start();
		}
		
		private function showAllText():void
		{
			_statementText.text = _currentStatement.text;
			_textWriteTimer.stop();
			_shownAllText = true;
			if (_currentCharacter)
				_currentCharacter.talking = false;
		}
		
		private function endDialog():void
		{
			if (_currentDialogName == "start")
			{
				introMusic.stop();
				_gameManager.finishedIntro();
			}
			_statementText.text = "";
			_currentDialog = null;
			if (_showingFirstTimeChat)
			{
				_showingFirstTimeChat = false;
				if (_currentCharacter)
					addOnScreenQuestions(_currentCharacter);
			}
		}
		
		private function addEvidence(evidence:Evidence):void
		{
			for each (var e:InGameEvidence in _evidenceGot)
			{
				if (e.evidence == evidence)
					return;
			}
			_evidenceGot.push(new InGameEvidence(evidence));
			updateEvidenceList();
		}	
		
		private function updateEvidenceList():void
		{
			var height:int = 50;
			for (var i:int = 0; i < _evidenceGot.length; i++)
			{
				_evidenceGot[i].y = height;
				height += _evidenceGot[i].height + 10;
			}
		}
		
		private function updateOnScreenQuestions():void
		{
			for (var i:int = 0; i < _onScreenQuestions.length; i++)
			{
				_onScreenQuestions[i].y = GC.TEXT_BOX_Y + 25 + i * 40;
			}
		}
		
		private function useEvidenceOnCharacter(inGameEvidence:InGameEvidence, 
												inGameCharacter:InGameCharacter):void
		{
			var evidence:Evidence = inGameEvidence.evidence;
			var character:Character = inGameCharacter.character;
			var nextDialog:String = evidence.doesOn(character.id);
			if (nextDialog)
				startDialog(nextDialog);
			else
				startDialogFromObj([new TextStatement(character, character.randomUnknownText, 0)]);
		}
		
		private function addOnScreenQuestions(character:InGameCharacter):void
		{
			_selectedCharacter = character;
			_onScreenQuestions = character.questions;
			updateOnScreenQuestions();
		}
		
		public function update():void
		{
			var hasClicked:Boolean = false;
			if (Input.mousePressed)
			{
				if (_showingChoices)
				{
					for each(var q:InGameQuestion in _onScreenQuestions)
					{
						if (q.isMouseOver)
						{
							_showingChoices = false;
							_onScreenQuestions = null;
							hasClicked = true;
							startDialog(q.dialog);
						}
					}
				}
				else if (_currentDialog)
				{
					if(!_waiting)
						if (_shownAllText)
							startNextStatement();
						else
							showAllText();
				}
				else
				{
					for each(var question:InGameQuestion in _onScreenQuestions)
					{
						if (question.isMouseOver)
						{
							hasClicked = true;
							startDialog(question.dialog);
						}
					}
					_onScreenQuestions = null;
					_selectedCharacter = null;
					for each(var character:InGameCharacter in _characters)
					{
						if (character.isMouseOver)
						{
							if (_selectedEvidence)
							{
								hasClicked = true;
								useEvidenceOnCharacter(_selectedEvidence, character);
							}
							else if (!character.hadFirstTimeChat)
							{
								character.hadFirstTimeChat = true;
								_showingFirstTimeChat = true;
								startDialog(character.character.first);
							}
							else
							{
								addOnScreenQuestions(character);
							}
						}
					}
					_selectedEvidence = null;
					for each(var evidence:InGameEvidence in _evidenceGot)
					{
						evidence.selected = false;
						if (evidence.isMouseOver)
						{
							hasClicked = true;
							_selectedEvidence = evidence;
							_selectedCharacter = null;
							evidence.selected = true;
						}
					}
				}
			}
				
			_statementText.update();
			_evidenceText.update();
			
			for each(var c:InGameCharacter in _characters)
			{
				c.canClick = (!_showingChoices) && (!_currentDialog);
				c.update();
			}
			for each(var e:InGameEvidence in _evidenceGot)
			{
				e.update();
				e.canClick = (!_showingChoices) && (!_currentDialog) && (!_selectedEvidence);
			}
			for each(var _question:InGameQuestion in _onScreenQuestions)
				_question.update();
		}
		
		public function render(buffer:BitmapData):void
		{
			buffer.copyPixels(_backgroundBitmapData, _backgroundBitmapData.rect, GC.ZERO);
			
			//buffer.fillRect(new Rectangle(0, GC.TEXT_BOX_Y - 5, GC.SCREEN_WIDTH, GC.SCREEN_HEIGHT - GC.TEXT_BOX_Y + 5), 0x80ffffff);
			buffer.copyPixels(_evidenceBitmapData, _evidenceBitmapData.rect, new Point(GC.EVIDENCE_BOX_X, 0));
			buffer.copyPixels(_textboxBitmapData, _textboxBitmapData.rect, new Point(0, GC.TEXT_BOX_Y));
			
			_statementText.render(buffer);
			_evidenceText.render(buffer);
			
			for each(var character:InGameCharacter in _characters)
				character.render(buffer);
			for each(character in _characters)
				character.renderArrow(buffer);
			for each(var question:InGameQuestion in _onScreenQuestions)
				question.render(buffer);
			
			for each(var e:InGameEvidence in _evidenceGot)
				e.render(buffer);
				
			if (_selectedEvidence)
				useOnText.render(buffer);
		}
		
		public function done():void
		{
			investigationMusic.stop();
			_gameManager.finishedDetective();
		}
		
	}

}