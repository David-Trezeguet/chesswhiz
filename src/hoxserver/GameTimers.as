package hoxserver
{
	public class GameTimers
	{
		public var gameTime:int  = 0;
		public var moveTime:int  = 0;
		public var extraTime:int = 0;

		private var _initialTimes:String = "";  // In "GG/MM/EE" format.
		private var _initialGameTime:int = 0;
		private var _initialMoveTime:int = 0;
		private var _initialExtraTime:int = 0;

		/**
		 * @param initialTimes The initial times string in "GG/MM/EE" format.
		 */
		public function GameTimers(initialTimes:String = "") : void
		{
			if (initialTimes != "")
			{
				this.initWithTimes(initialTimes, initialTimes);
			}
		}

		/**
		 * @param initialTimes The initial times string in "GG/MM/EE" format.
		 * @param currentTimes The current times string in "GG/MM/EE" format.
		 */
		public function initWithTimes(initialTimes:String, currentTimes:String) : void
		{
			var timers:Array = initialTimes.split("/");
			_initialGameTime = parseInt(timers[0]);
			_initialMoveTime = parseInt(timers[1]);
			_initialExtraTime = parseInt(timers[2]);

			timers = currentTimes.split("/");
			this.gameTime  = parseInt(timers[0]);
			this.moveTime  = parseInt(timers[1]);
			this.extraTime = parseInt(timers[2]);

			_initialTimes = initialTimes;
		}

		public function getInitialTimes() : String { return _initialTimes; }

		public function resetMoveTime() : void
		{
			this.moveTime = _initialMoveTime;
		}

		public function resetAll() : void
		{
			this.gameTime = _initialGameTime;
			this.moveTime = _initialMoveTime;
			this.extraTime = _initialExtraTime;
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
		
		/**
		 * Parse a times string into separate components. 
		 *
		 * @param times The times string in "GG/MM/EE" format.
		 */
		public static function parse_times(times:String) : Object
		{
			const fields:Array = times.split("/");
			return {
					gametime  : parseInt(fields[0]),
					movetime  : parseInt(fields[1]),
					extratime : parseInt(fields[2])
				};
		}
	}
}