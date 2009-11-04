package {

	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	
	import mx.containers.Canvas;
	import mx.controls.Image;
	
	import ui.BoardCanvas;

	public class Piece
	{
		private const _imageRadius:int = 22;

		private var _type:String;
		private var _imageSrc:String;
		private var _id:int;
		private var _row:int;
		private var _column:int;
		private var _color:String;
		private var _imageHolder:Image;
		private var _board:BoardCanvas;
		private var _curRow:int;
		private var _curColumn:int;
		private var _captured:Boolean = false;
		private var _parentClip:Canvas = null;
		private var _enabled:Boolean = false;
		private var _centerX:int;
		private var _centerY:int;
		
		public function Piece(id:int, type:String, row:int, column:int,
							  src:String, color:String, board:BoardCanvas) : void
		{
			_id = id;
			_type = type;
			_row = _curRow = row;
			_column = _curColumn = column;
			_imageSrc = src;
			_color = color;
			_board = board;
			_centerX = _centerY = 22;
		}

		public function getIndex():int { return _id; }
		public function getColor():String { return _color; }
		public function isEventsEnabled() : Boolean { return _enabled; }
		public function getType():String { return _type; }
		public function getImageHolder() : Image { return _imageHolder; }
		public function isCaptured():Boolean { return _captured; }
		public function getPosition():Position { return new Position(_curRow, _curColumn); }
		public function getInitialPosition():Position { return new Position(_row, _column); }

		public function setCapture(flag:Boolean) : void
		{
			_captured = flag;
		}
		
		public function setPosition(newPos:Position) : void
		{
			_curRow = newPos.row;
			_curColumn = newPos.column;
		}

		public function setImageCenter(x:int, y:int) : void
		{
			_centerX = x;
			_centerY = y;
		}

		public function draw(parentClip:Canvas, offset:int, width:int, height:int, pieceSkinIndex:int) : void
		{
			_parentClip = parentClip;
			var viewPos:Position = _board.getViewPosition(getPosition());
			_imageHolder = new Image();
			_imageHolder.x = (offset + viewPos.column * width) - _centerX;
			_imageHolder.y = (offset + viewPos.row * height) - _centerY;
			_imageHolder.source =  Global.BASE_URI + "res/images/pieces/" + pieceSkinIndex + "/" + _imageSrc;
			parentClip.addChild(_imageHolder);
		}

		public function enableEvents() : void
		{
			if (_imageHolder != null) {
				_imageHolder.addEventListener(MouseEvent.MOUSE_DOWN, startDragHandler);
				_imageHolder.addEventListener(MouseEvent.MOUSE_UP, stopDragHandler);
				_enabled = true;
			}
		}

		public function disableEvents() : void
		{
			if (_imageHolder != null) {
				_imageHolder.removeEventListener(MouseEvent.MOUSE_DOWN, startDragHandler);
				_imageHolder.removeEventListener(MouseEvent.MOUSE_UP, stopDragHandler);
				_enabled = false;
			}
		}

		private function startDragHandler(evt:MouseEvent) : void 
		{
			var maxDepth:int = _parentClip.numChildren - 1;
			_parentClip.setChildIndex(_imageHolder, maxDepth);
			_imageHolder.startDrag();
		}

		private function stopDragHandler(evt:MouseEvent) : void 
		{
			_imageHolder.stopDrag();
			var newPos:Position = _board.getNearestCell(evt.stageX, evt.stageY, 30);
			if (newPos.row == -1) {
				moveImage();
			}
			else {
				var absPos:Position = _board.getAbsolutePosition(newPos);
				_board.getTable().moveLocalPiece(this, this.getPosition(), absPos);
			}
		}
		
		public function setFocus() : void
		{
			if (_imageHolder != null)
			{	
	            const glowFilter:GlowFilter = new GlowFilter( 0x33CCFF /* color */,
							                                  0.8      /* alpha */,
							                                  10       /* blurX */,
							                                  10       /* blurY */,
							                                  2        /* strength */,
							                                  BitmapFilterQuality.HIGH,
							                                  false   /* inner */,
							                                  false   /* knockout */ );
				_imageHolder.filters = [glowFilter];
			}
		}

		public function clearFocus() : void
		{
			if (_imageHolder != null) {
				_imageHolder.filters = [];
			}
		}

		public function removeImage(parentClip:Canvas) : void
		{
			if (_imageHolder != null) {
				if (isEventsEnabled()) {
					_imageHolder.removeEventListener(MouseEvent.MOUSE_DOWN, startDragHandler);
					_imageHolder.removeEventListener(MouseEvent.MOUSE_UP, stopDragHandler);
				}
				if (_imageHolder.parent) {
					_imageHolder.parent.removeChild(_imageHolder);
				}
				_imageHolder = null;
			}
		}

		public function moveImage() : void
		{
			var viewPos:Position = _board.getViewPosition(getPosition());
			if (_imageHolder != null) {
				_imageHolder.x = _board.getX(viewPos.column) - _imageRadius;
				_imageHolder.y = _board.getY(viewPos.row) - _imageRadius;
			}
		}
	}
}
