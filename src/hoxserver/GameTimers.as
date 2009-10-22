package hoxserver {
	public class GameTimers {
		public var initialTimes:String;
		public var gameTime;
		public var moveTime;
		public var extraTime;

		public function GameTimers(time):void {
			this.initialTimes = time;
			if (time !== "") {
				var timers = time.split("/");
				this.gameTime = parseInt(timers[0]);
				this.moveTime = parseInt(timers[1]);
				this.extraTime = parseInt(timers[2]);
			}
		}
		
		public function setTime(time) {
			if (time !== "") {
				var timers = time.split("/");
				this.gameTime = parseInt(timers[0]);
				this.moveTime = parseInt(timers[1]);
				this.extraTime = parseInt(timers[2]);
			}
		}
		
		public function resetMoveTime() {
			var timers = this.initialTimes.split("/");
			this.moveTime = parseInt(timers[1]);
		}
		
		public function getGameTime() {
			return this.gameTime;
		}
		
		public function getMoveTime() {
			return this.moveTime;
		}
		
		public function getExtraTime() {
			return this.extraTime;
		}
		
		public function formatTime(seconds) {
			var time = "";
			var min = 0;
			var sec = seconds;
			if (seconds >= 60) {
				min = (seconds/60)|0;
				sec = seconds % 60;
			}
			if (min === 0) {
				time = time + "00";
			}
			else if (min < 10) {
				time = time + "0" + min;
			}
			else {
				time = time + min;
			}
			time = time + ":";
			if (sec === 0) {
				time = time + "00";
			}
			else if (sec < 10) {
				time = time + "0" + sec;
			}
			else {
				time = time + sec;
			}
			return time;
		}
		
		public function getTimer(type) {
			if (type === "game") {
				return this.formatTime(this.gameTime);
			}
			else if (type === "move") {
				return this.formatTime(this.moveTime);
			}
			else if (type === "extra") {
				return this.formatTime(this.extraTime);
			}
		}
	}
}