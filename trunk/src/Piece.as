package {

	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	
	import mx.controls.Image;
	
	import ui.BoardCanvas;

	public class Piece
	{
		private const _imageRadius:int = 22; // TODO: Assuming Piece's size = 44 px.

		private var _id:int;
		private var _type:String;
		private var _color:String;
		private var _row:int;
		private var _column:int;
		private var _board:BoardCanvas;

		private var _initialRow:int;
		private var _initialColumn:int;
		private var _imageSrc:String;
		private var _image:Image      = null;
		private var _captured:Boolean = false;
		private var _enabled:Boolean  = false;
		
		public function Piece(id:int, type:String, color:String, row:int, column:int, board:BoardCanvas) : void
		{
			_id      = id;
			_type    = type;
			_color   = color;
			_row     = row;
			_column  = column;
			_board   = board;

			_initialRow    = _row;
			_initialColumn = _column;
			_imageSrc      = (_color == "Red" ? "r" : "b") + _type + ".png";
		}

		public function getIndex():int { return _id; }
		public function getColor():String { return _color; }
		public function isEventsEnabled() : Boolean { return _enabled; }
		public function getType():String { return _type; }
		public function getImageHolder() : Image { return _image; }
		public function isCaptured():Boolean { return _captured; }
		public function getPosition():Position { return new Position(_row, _column); }
		public function getInitialPosition():Position { return new Position(_initialRow, _initialColumn); }

		public function setCapture(flag:Boolean) : void
		{
			_captured = flag;
		}
		
		public function setPosition(newPos:Position) : void
		{
			_row = newPos.row;
			_column = newPos.column;
		}

		public function draw(offset:int, width:int, height:int, pieceSkinIndex:int) : void
		{
			var viewPos:Position = _board.getViewPosition(getPosition());
			_image = new Image();
			_image.load("assets/pieces/" + pieceSkinIndex + "/" + _imageSrc);
			_image.x = (offset + viewPos.column * width) - _imageRadius;
			_image.y = (offset + viewPos.row * height) - _imageRadius;
			_board.addChild(_image);
		}

		public function enableEvents() : void
		{
			if (_image != null) {
				_image.addEventListener(MouseEvent.MOUSE_DOWN, _startDragHandler);
				_image.addEventListener(MouseEvent.MOUSE_UP, _stopDragHandler);
				_enabled = true;
			}
		}

		public function disableEvents() : void
		{
			if (_image != null) {
				_image.removeEventListener(MouseEvent.MOUSE_DOWN, _startDragHandler);
				_image.removeEventListener(MouseEvent.MOUSE_UP, _stopDragHandler);
				_enabled = false;
			}
		}

		private function _startDragHandler(evt:MouseEvent) : void 
		{
			var maxDepth:int = _board.numChildren - 1;
			_board.setChildIndex(_image, maxDepth);
			_image.startDrag();
		}

		private function _stopDragHandler(evt:MouseEvent) : void 
		{
			_image.stopDrag();
			var newPos:Position = _board.getNearestCell(evt.stageX, evt.stageY, 30);
			if (newPos.row == -1) {
				moveImage();
			}
			else {
				var absPos:Position = _board.getViewPosition(newPos);
				_board.getTable().moveLocalPiece(this, this.getPosition(), absPos);
			}
		}
		
		public function setFocus() : void
		{
			if (_image != null)
			{	
	            const glowFilter:GlowFilter = new GlowFilter( 0x33CCFF /* color */,
							                                  0.8      /* alpha */,
							                                  10       /* blurX */,
							                                  10       /* blurY */,
							                                  2        /* strength */,
							                                  BitmapFilterQuality.HIGH,
							                                  false   /* inner */,
							                                  false   /* knockout */ );
				_image.filters = [glowFilter];
			}
		}

		public function clearFocus() : void
		{
			if (_image != null) {
				_image.filters = [];
			}
		}

		public function removeImage() : void
		{
			if (_image != null) {
				if (_enabled) {
					_image.removeEventListener(MouseEvent.MOUSE_DOWN, _startDragHandler);
					_image.removeEventListener(MouseEvent.MOUSE_UP, _stopDragHandler);
				}
				if (_image.parent) {
					_image.parent.removeChild(_image);
				}
				_image = null;
			}
		}

		public function moveImage() : void
		{
			if (_image != null) {
				const viewPos:Position = _board.getViewPosition(getPosition());
				_image.x = _board.getX(viewPos.column) - _imageRadius;
				_image.y = _board.getY(viewPos.row) - _imageRadius;
			}
		}
	}
}
