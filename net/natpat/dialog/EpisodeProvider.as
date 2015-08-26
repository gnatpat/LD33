package net.natpat.dialog {
	import flash.utils.ByteArray;
	import net.natpat.Assets;
	import net.natpat.dialog.statements.*;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class EpisodeProvider 
	{
		
		private var _json:Object;
		
		private var _characters:Object;
		private var _evidence:Object;
		private var _dialogs:Object;
		
		private var _xOffset:int;
		private var _yOffset:int;
		
		private var _splash:String;
		private var _monster:String;
		private var _scene:String;
		private var _fight:String;
		private var _phonecall:Array;
		
		private var _splashXOffset:int;
		private var _splashYOffset:int;
		
		public function EpisodeProvider(episode:Class) 
		{
			var ba:ByteArray = new episode as ByteArray;
			_json = JSON.parse(ba.toString());
			_xOffset = _json.xOffset;
			_yOffset = _json.yOffset;
			_monster = _json.monster;
			_splash = _json.monsterSplash;
			_scene = _json.scene;
			_fight = _json.fight;
			_phonecall = _json.phonecall;
			_splashXOffset = _json.splashxoffset;
			_splashYOffset = _json.splashyoffset;
			
			_characters = new Object();
			for (var character:String in _json.characters)
			{
				var unknownDialog:Array = new Array;
				_characters[character] = new Character(_json.characters[character].name,
													   Assets[_json.characters[character].img],
													   character,
													   _json.characters[character].unknown,
													   _json.characters[character].questions,
													   _json.characters[character].x,
													   _json.characters[character].y,
													   _json.characters[character].width,
													   _json.characters[character].height,
													   _json.characters[character].first,
													   _json.characters[character].visible,
													   _json.characters[character].shadow);
			}
			
			_evidence = new Object();
			for (var evidence:String in _json.evidence)
			{
				_evidence[evidence] = new Evidence(_json.evidence[evidence].name, evidence, 
												   _json.evidence[evidence].does);
			}
			
			_dialogs = new Object();
			for (var dialog:String in _json.dialogs)
			{
				_dialogs[dialog] = new Array();
				
				for each(var dialogObj:Object in _json.dialogs[dialog])
				{
					var statement:Statement;
					if (dialogObj.evidence)
					{
						var e:Evidence = getEvidence(dialogObj.evidence);
						statement = (new EvidenceStatement(e, dialogObj.text));
					}
					else if (dialogObj.question)
					{
						statement = (new QuestionStatement(getCharacter(dialogObj.who), dialogObj.question));
					}
					else if (dialogObj.appear)
					{
						statement = new AppearStatement(getCharacter(dialogObj.appear), dialogObj.when);
					}
					else if (dialogObj.disappear)
					{
						statement = new DisappearStatement(getCharacter(dialogObj.disappear));
					}
					else if (dialogObj["switch"])
					{
						statement = new SwitchStatement(getEvidence(dialogObj["switch"]), getEvidence(dialogObj.to));
					}
					else if (dialogObj.remove)
					{
						statement = new RemoveStatement(getEvidence(dialogObj.remove), dialogObj.text);
					}
					else if (dialogObj.turn)
					{
						statement = new TurnStatement(dialogObj.turn, getCharacter(dialogObj.who));
					}
					else if (dialogObj.removeQuestion)
					{
						statement = new RemoveQuestionStatement(getCharacter(dialogObj.who), dialogObj.removeQuestion);
					}
					else if (dialogObj.info)
					{
						statement = new InfoStatement(dialogObj.info);
					}
					else if (dialogObj.cancelFirst)
					{
						statement = new CancelFirstStatement(getCharacter(dialogObj.cancelFirst));
					}
					else if (dialogObj.choice)
					{
						var choices:Array = new Array();
						for each(var choice:Object in dialogObj.choice)
						{
							choices.push(new Choice(choice.dialog, choice.text));
						}
						statement = new ChoiceStatement(choices);
					}
					else if (dialogObj["goto"])
					{
						statement = new GotoStatement(dialogObj["goto"]);
					}
					else
					{
						statement = (new TextStatement(getCharacter(dialogObj.who), dialogObj.text, dialogObj.shake));
					}
					_dialogs[dialog].push(statement);
				}
			}
		}
		
		public function getDialog(dialog:String):Array
		{
			return _dialogs[dialog];
		}
		
		public function getEvidence(evidence:String):Evidence
		{
			return _evidence[evidence];
		}
		
		public function getCharacter(character:String):Character
		{
			return _characters[character];
		}
		
		public function getCharacterList():Array
		{
			var characters:Array = new Array();
			for each(var character:Character in _characters)
				characters.push(character);
			return characters;
		}
		
		public function get xOffset():int
		{
			return _xOffset;
		}
		
		public function get yOffset():int
		{
			return _yOffset;
		}
		
		public function get splash():String
		{
			return _splash;
		}
		
		public function get monster():String
		{
			return _monster;
		}
		
		public function get scene():String
		{
			return _scene;
		}
		
		public function get fight():String
		{
			return _fight;
		}
		
		public function get phonecall():Array
		{
			return _phonecall;
		}
		
		public function get splashXOffset():int
		{
			return _splashXOffset;
		}
		
		public function get splashYOffset():int
		{
			return _splashYOffset;
		}
		
		
	}

}