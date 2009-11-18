package
{
	public class Move
	{
		public var color:String;
		public var pieceIndex:int = -1;
		public var oldRow:int;
		public var oldCol:int;
		public var newRow:int;
		public var newCol:int;
		public var capturedIndex:int = -1;
					
		public function Move(color:String, pieceIndex:int,
							 oldRow:int, oldCol:int,
							 newRow:int, newCol:int,
							 capturedIndex:int = -1)
		{
			this.color = color;
			this.pieceIndex = pieceIndex;
			this.oldRow = oldRow;
			this.oldCol = oldCol;
			this.newRow = newRow;
			this.newCol = newCol;
			this.capturedIndex = capturedIndex;
		}
	}
}