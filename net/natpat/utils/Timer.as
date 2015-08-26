package net.natpat.utils 
{
	import flash.events.TimerEvent;
	import net.natpat.GV;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class Timer 
	{
		private var _duration:int = 0;
		private var _repeatCount:int = 0;
		private var _iteration:int = 0;
		private var _time:int = 0;
		private var _complete:Function;
		private var _tick:Function;
		private var _toRemove:Boolean;
		
		public static var timers:Array = new Array;
		
		public static function update():void
		{
			for each(var timer:Timer in timers)
			{
				timer._time += GV.elapsed * 1000;
				if (timer._duration < timer._time)
				{
					timer._time -= timer._duration;
					timer._iteration++;
					if (timer._iteration == timer._repeatCount)
					{
						timer._toRemove = true;
						if(timer._complete != null)
							timer._complete(null);
					}
					if (timer._tick != null)
						timer._tick(null);
				}
			}
			var i:int = 0;
			while (i < timers.length)
			{
				if (timers[i]._toRemove)
				{
					timers.splice(i, 1);
				} else {
					i++;
				}
			}
		}
		
		public function Timer(duration:int, repeatCount:int) 
		{
			_duration = duration;
			_repeatCount = repeatCount;
		}
		
		public function addEventListener(event:String, callback:Function):void
		{
			if (event == TimerEvent.TIMER)
				_tick = callback;
			if (event == TimerEvent.TIMER_COMPLETE)
				_complete = callback;
		}
		
		public function start():void
		{
			_time = 0;
			timers.push(this);
		}
		
		public function stop():void
		{
			if (timers.indexOf(this) != -1)
				timers.splice(timers.indexOf(this), 1);
		}
		
	}

}