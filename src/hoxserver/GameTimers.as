package hoxserver
{
	public class GameTimers
	{
		public var gameTime:int;
		public var moveTime:int;
		public var extraTime:int;

		public var _initialMoveTime:int = 0;

		public function GameTimers(time:String) : void
		{
			if (time != "") {
				const timers:Array = time.split("/");
				this.gameTime = parseInt(timers[0]);
				this.moveTime = parseInt(timers[1]);
				this.extraTime = parseInt(timers[2]);

				_initialMoveTime = this.moveTime;
			}
		}

		public function resetMoveTime() : void
		{
			this.moveTime = _initialMoveTime;
		}

		public function getTimer(type:String) : String
		{
			if (type == "game")  { return _formatTime(this.gameTime);  }
			if (type == "move")  { return _formatTime(this.moveTime);  }
			if (type == "extra") { return _formatTime(this.extraTime); }
			return "";
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