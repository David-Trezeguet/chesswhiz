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
		private var _image:Image      = new Image();
		private var _skinIndex:int    = -1;
		private var _captured:Boolean = false;
		
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
		public function getType():String { return _type; }
		public function isCaptured():Boolean { return _captured; }
		public function getPosition():Position { return new Position(_row, _column); }
		public function getInitialPosition():Position { return new Position(_initialRow, _initialColumn); }

		public function setCapture(flag:Boolean) : void { _captured = flag;}
		
		public function setPosition(newPos:Position) : void
		{
			_row = newPos.row;
			_column = newPos.column;
		}

		public function draw(offset:int, size:int, skinIndex:int) : void
		{
			var viewPos:Position = _board.getViewPosition(getPosition());
			if (_skinIndex != skinIndex)
			{
				this.changeSkinIndex(skinIndex);
			}
			_image.x = (offset + viewPos.column * size) - _imageRadius;
			_image.y = (offset + viewPos.row * size) - _imageRadius;
			_board.addChild(_image);
		}

		public function changeSkinIndex(skinIndex:int) : void
		{
			if ( _skinIndex != skinIndex )
			{
				_skinIndex = skinIndex;
				_image.load("assets/pieces/" + _skinIndex + "/" + _imageSrc);
			}
		}

		public function enableEvents() : void
		{
			_image.addEventListener(MouseEvent.MOUSE_DOWN, _startDragHandler);
			_image.addEventListener(MouseEvent.MOUSE_UP, _stopDragHandler);
		}

		public function disableEvents() : void
		{
			_image.removeEventListener(MouseEvent.MOUSE_DOWN, _startDragHandler);
			_image.removeEventListener(MouseEvent.MOUSE_UP, _stopDragHandler);
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
				const viewPos:Position = _board.getViewPosition(newPos);
				// Notify the "parent" board of this new Piece Movement.
				_board.getTable().onLocalPieceMoved(this, this.getPosition(), viewPos);
			}
		}
		
		public function setFocus() : void
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

		public function clearFocus() : void
		{
			_image.filters = [];
		}

		public function removeImage() : void
		{
			if (_image.parent) {
				_image.parent.removeChild(_image);
			}
		}

		public function moveImage() : void
		{
			const viewPos:Position = _board.getViewPosition(getPosition());
			_image.x = _board.getX(viewPos.column) - _imageRadius;
			_image.y = _board.getY(viewPos.row) - _imageRadius;
		}
	}
}
