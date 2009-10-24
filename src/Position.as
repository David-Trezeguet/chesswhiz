package {

	public class Position
	{
		public var row:int;
		public var column:int;
		
		public function Position(row:int, column:int)
		{
			this.row = row;
			this.column = column;
		}
		public function Compare(pos:Position) : int {
			if (this.row == pos.row && this.column == pos.column) {
				return 0;
			}
			return -1;
		}
		public function toString() : String {
			return "[" + row + "," + String.fromCharCode(97 + column) + "]";
		}
	}
}