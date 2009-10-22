package {
	import hoxserver.*;
	public class Side {
		public var type:String;
		public var color:String;
		public var player:PlayerInfo;
		public function Side(type, color, player) {
			this.type = type;
			this.color = color;
			this.player = player;
		}
	}
}