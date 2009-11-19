package
{
	public class PieceInfo
	{
		public var type:String;
		public var color:String;
		public var position:Position;

		private var _captured:Boolean = false;

		public function PieceInfo(type:String, color:String, position:Position)
		{
			this.type = type;
			this.color = color;
			this.position = position.clone();
		}

		public function clone() : PieceInfo
		{
			return new PieceInfo(this.type, this.color, this.position);
		}

		public function isCaptured():Boolean { return _captured; }
		public function setCaptured(val:Boolean) : void { _captured = val; }

		public function setPosition(newPosition:Position) : void
		{
			this.position.row = newPosition.row;
			this.position.column = newPosition.column;
		}

	}
}