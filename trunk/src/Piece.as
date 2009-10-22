package {

	import flash.events.MouseEvent;
	import flash.events.Event;
	import mx.controls.Image;
	import mx.containers.Canvas;

	public class Piece
	{
		private var _type:String;
		private var _imageSrc:String;
		private var  _height:int;
		private var  _width:int;
		private var _id:int;
		private var _row:int;
		private var _column:int;
		private var _color:String;
		private var _imgLabel:String;
		private var _mImageHolder:Image;
		private var _board:Board;
		private var _curRow:int;
		private var _curColumn:int;
		private var _imageRadius:int;
		private var _captured:Boolean;
		private var _parentClip:Canvas;
		private var _inFocus:Boolean;
		private var _enabled:Boolean;
		private var _centerX:int;
		private var _centerY:int;
		
		public function Piece(id, type, row, column, src, imgLabel, color, board):void {
			_id = id;
			_type = type;
			_row = _curRow = row;
			_column = _curColumn = column;
			_imageSrc = src;
			_color = color;
			_imgLabel = imgLabel;
			_board = board;
			_imageRadius = _centerX = _centerY = 22;
			_captured = false;
			_parentClip = null;
			_inFocus = false;
			_enabled = false;
		}

		public function clone() {
			var piece = new Piece("", "", 0, 0, "", "", "", null);
			piece._id = this._id;
			piece._type = this._type;
			piece._row = this._row;
			piece._curRow = this._curRow;
			piece._column = this._column;
			piece._curColumn = this._curColumn;
			piece._imageSrc = this._imageSrc;
			piece._color = this._color;
			piece._mImageHolder = this._mImageHolder;
			piece._imgLabel = this._imgLabel;
			piece._board = this._board;
			piece._imageRadius = this._imageRadius;
			piece._captured = this._captured;
			piece._inFocus = this._inFocus;
			return piece;
		}
		public function getIndex():int {
			return _id;
		}

		public function get getRow():int {
			return _row;
		}

		public function get getColumn():int {
			return _column;
		}
		
		public function getColor():String {
			return _color;
		}

		public function isEventsEnabled() {
			return _enabled;
		}

		public function getType():String {
			return _type;
		}

		public function getPosition():Position
		{
			return new Position(_curRow, _curColumn);
		}
		
		public function setPosition(newPos:Position):void
		{
			_curRow = newPos.row;
			_curColumn = newPos.column;
		}

		public function getInitialPosition():Position
		{
		    return new Position(_row,_column);
		}
		
		public function getImageHolder() {
			return _mImageHolder;
		}
		public function setImageHolder(imgHolder) {
			_mImageHolder = imgHolder;
		}

		public function setImageCenter(x, y) {
			this._centerX = x;
			this._centerY = y;
		}
		public function draw(parentClip, offset, width, height, pieceSkinIndex):void
		{
			_parentClip = parentClip;
			var viewPos:Position = _board.getViewPosition(getPosition());
			_mImageHolder = new Image();
			_mImageHolder.name = this._imgLabel;
			_mImageHolder.x = (offset + viewPos.column * width) - _centerX;
			_mImageHolder.y = (offset + viewPos.row * height) - _centerY;
			_mImageHolder.source =  Global.vars.app.baseURI + "images/pieces/" + pieceSkinIndex + "/" + _imageSrc;
			parentClip.addChild(_mImageHolder);
		}

		public function enableEvents() {
			if (_mImageHolder != null) {
				_mImageHolder.addEventListener(MouseEvent.MOUSE_DOWN, startDragHandler);
				//mImageHolder.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
				_mImageHolder.addEventListener(MouseEvent.MOUSE_UP, stopDragHandler);
				_enabled = true;
			}
		}

		public function disableEvents() {
			if (_mImageHolder != null) {
				_mImageHolder.removeEventListener(MouseEvent.MOUSE_DOWN, startDragHandler);
				//mImageHolder.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
				_mImageHolder.removeEventListener(MouseEvent.MOUSE_UP, stopDragHandler);
				_enabled = false;
			}
		}

		public function startDragHandler(evt:MouseEvent):void 
		{
			var maxDepth = _parentClip.numChildren - 1;
			_parentClip.setChildIndex(_mImageHolder, maxDepth);
			_mImageHolder.startDrag();
		}
		public function stopDragHandler(evt:MouseEvent):void 
		{
			_mImageHolder.stopDrag();
			var newPos:Position = _board.getNearestCell(evt.stageX, evt.stageY, 30);
			if (newPos.row == -1) {
				moveImage();
			}
			else {
				var absPos:Position = _board.getAbsolutePosition(newPos);
				_board.getTable().moveLocalPiece(this, this.getPosition(), absPos);
			}
		}
		
		public function setCapture(flag:Boolean):void
		{
			_captured = flag;
		}
		public function isCaptured():Boolean
		{
			return _captured;
		}
		
		public function setFocus() {
			_inFocus = true;
			if (_mImageHolder != null) {
				_mImageHolder.filters = [Util.createGlowFilter()];
			}
		}
		public function clearFocus() {
			_inFocus = false;
			if (_mImageHolder != null) {
				_mImageHolder.filters = [];
			}
		}
		public function removeImage(parentClip:Canvas):void
		{
			if (_mImageHolder != null) {
				if (isEventsEnabled()) {
					_mImageHolder.removeEventListener(MouseEvent.MOUSE_DOWN, startDragHandler);
					_mImageHolder.removeEventListener(MouseEvent.MOUSE_UP, stopDragHandler);
				}
				if (_mImageHolder.parent) {
					_mImageHolder.parent.removeChild(_mImageHolder);
				}
				_mImageHolder = null;
			}
		}
		public function moveImage() {
			var viewPos:Position = _board.getViewPosition(getPosition());
			if (_mImageHolder != null) {
				_mImageHolder.x = _board.getX(viewPos.column) - _imageRadius;
				_mImageHolder.y = _board.getY(viewPos.row) - _imageRadius;
			}
		}
	}
}
