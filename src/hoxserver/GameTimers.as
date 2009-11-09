package hoxserver
{
	public class GameTimers
	{
		public var gameTime:int  = 0;
		public var moveTime:int  = 0;
		public var extraTime:int = 0;

		private var _initialTimes:String = "";  // In "GG/MM/EE" format.
		private var _initialMoveTime:int = 0;

		/**
		 * @param times The initial times string in "GG/MM/EE" format.
		 */
		public function GameTimers(times:String = "") : void
		{
			if (times != "")
			{
				this.initWithTimes(times);
			}
		}

		/**
		 * @param times The initial times string in "GG/MM/EE" format.
		 */
		public function initWithTimes(times:String) : void
		{
			const timers:Array = times.split("/");
			this.gameTime  = parseInt(timers[0]);
			this.moveTime  = parseInt(timers[1]);
			this.extraTime = parseInt(timers[2]);

			_initialTimes = times;
			_initialMoveTime = this.moveTime;
		}

		public function getInitialTimes() : String { return _initialTimes; }

		public function resetMoveTime() : void
		{
			this.moveTime = _initialMoveTime;
		}

		public function decrementTime() : void
		{
			if      ( gameTime > 0 )  { --gameTime;  }
			else if ( extraTime > 0 ) { --extraTime; } // Use extra time if needed.

			if ( moveTime > 0 ) { --moveTime; }
		}

		public function isTimedout() : Boolean
		{
			return (    moveTime == 0
					|| (gameTime == 0 && extraTime == 0) );
		}

		public function getTimer(type:String) : String
		{
			if (type == "game")  { return _formatTime(this.gameTime);  }
			if (type == "move")  { return _formatTime(this.moveTime);  }
			/* "extra" */          return _formatTime(this.extraTime);
		}

		private function _formatTime(seconds:int) : String
		{
			var min:int = 0;
			var sec:int = seconds;

			if (seconds >= 60) {
				min = seconds / 60;
				sec = seconds % 60;
			}

			var time:String = "";
			if      (min == 0) { time += "00";      }
			else if (min < 10) { time += "0" + min; }
			else               { time += min;       }

			time += ":";
			if      (sec == 0) { time += "00";      }
			else if (sec < 10) { time += "0" + sec; }
			else               { time += sec;       }

			return time;
		}
	}
}