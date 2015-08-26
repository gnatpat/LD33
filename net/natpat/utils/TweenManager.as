package net.natpat.utils 
{
	import net.natpat.GV;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class TweenManager
	{
		
		public static var tween:TweenObject = null;
		public static var nextId:int = 0;

        public function TweenManager()
        {
        }
		
		public static function newTween(func:Function, length:Number, ease:Function = null, repeatable:Boolean = false, callback:Function = null):int
		{
			if (ease == null) ease = Ease.none;
			var id:int = nextId++;
			var newTween:TweenObject = new TweenObject(id, func, length, ease, repeatable, callback);
			newTween.next = tween;
			newTween.prev = null;
			if (newTween.next) newTween.next.prev = newTween;
			tween = newTween;
			return id;
		}
		
		public static function update():void
		{
			var t:TweenObject = tween;
			var elapsed:Number = GV.elapsed;
			while (t != null)
			{
				if (!t.enabled || t.done)
				{
					t = t.next;
					continue;
				}
				t.time += elapsed;
                t.func(t.ease(t.time/t.length));

				if (t.repeatable)
				{
					while (t.time > t.length)
					{
						t.time -= t.length;
						if(t.callback != null) t.callback();
					}
				}
				
				if (t.time >= t.length)
				{
					t.time = t.length;
					if(!t.done && t.callback != null) t.callback();
					t.done = true;
				}
				t = t.next;
			}
		}
		
		public static function remove(id:int):void
		{
			var t:TweenObject = tween;
			while (t != null)
			{
				if (t.id == id)
				{
					if (tween == t)
						tween = t.next;
					if (t.prev)
						t.prev.next = t.next;
					if (t.next)
						t.next.prev = t.prev;
					break;
				}
				t = t.next;
			}
		}
		
		public static function disable(id:int):void
		{
			var t:TweenObject = tween;
			while (t != null)
			{
				if (t.id == id)
				{
					t.enabled = false;
					return;
				}
				t = t.next;
			}
		}
		
		public static function enable(id:int):void
		{
			var t:TweenObject = tween;
			while (t != null)
			{
				if (t.id == id)
				{
					t.enabled = true;
					return;
				}
				t = t.next;
			}
		}

	}

}

internal class TweenObject
{
	public var id:int;
	
	public var time:Number = 0;

    public var func:Function;
	public var length:Number;
	public var callback:Function;
	public var ease:Function;

	public var next:TweenObject;
	public var prev:TweenObject;
	public var done:Boolean;
	public var repeatable:Boolean = false;
	
	public var enabled:Boolean;
	
	public function TweenObject(id:int, func:Function, length:Number, ease:Function = null, repeatable:Boolean = false, callback:Function = null)
	{
		this.id = id;
        this.func = func;
		this.length = length;
		this.callback = callback;
        this.repeatable = repeatable;
		this.ease = ease;
		done = false;
		enabled = true;
	}
}
