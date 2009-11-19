package
{
	public class Position
	{
		public var row:int;
		public var column:int;

		public function Position(row:int, column:int)
		{
			this.row = row;
			this.column = column;
		}

		public function clone() : Position
		{
			return new Position(row, column);
		}

		public function toString() : String
		{
			return "[" + row + "," + String.fromCharCode(97 + column) + "]";
		}
	}
}