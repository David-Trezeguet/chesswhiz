package
{
	public class PieceInfo
	{
		public var type:String;
		public var color:String;
		public var position:Position;

		private var _captured:Boolean = false; // TODO: Need to reconsider the design!
		private var _initialPosition:Position;  // TODO: Need to reconsider the design!

		public function PieceInfo(type:String, color:String, position:Position)
		{
			this.type = type;
			this.color = color;
			this.position = position;

			_initialPosition = new Position(position.row, position.column);
		}
		
		public function isCaptured():Boolean { return _captured; }
		public function setCaptured(val:Boolean):void { _captured = val; }
		public function getInitialPosition() : Position { return _initialPosition; }

		public function getPosition() : Position
		{
			return new Position(position.row, position.column);
		}

		public function setPosition(newPosition:Position) : void
		{
			this.position.row = newPosition.row;
			this.position.column = newPosition.column;
		}

	}
}