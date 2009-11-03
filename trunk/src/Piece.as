package {

	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	
	import mx.containers.Canvas;
	import mx.controls.Image;
	
	import ui.BoardCanvas;

	public class Piece
	{
		private var _type:String;
		private var _imageSrc:String;
		private var _id:int;
		private var _row:int;
		private var _column:int;
		private var _color:String;
		private var _imgLabel:String;
		private var _mImageHolder:Image;
		private var _board:BoardCanvas;
		private var _curRow:int;
		private var _curColumn:int;
		private var _imageRadius:int;
		private var _captured:Boolean = false;
		private var _parentClip:Canvas = null;
		private var _inFocus:Boolean = false;
		private var _enabled:Boolean = false;
		private var _centerX:int;
		private var _centerY:int;
		
		public function Piece(id:int, type:String, row:int, column:int,
							  src:String, imgLabel:String, color:String, board:BoardCanvas) : void
		{
			_id = id;
			_type = type;
			_row = _curRow = row;
			_column = _curColumn = column;
			_imageSrc = src;
			_color = color;
			_imgLabel = imgLabel;
			_board = board;
			_imageRadius = _centerX = _centerY = 22;
		}

		public function getIndex():int { return _id; }
		public function get getRow():int { return _row; }
		public function get getColumn():int { return _column; }
		public function getColor():String { return _color; }
		public function isEventsEnabled() : Boolean { return _enabled; }
		public function getType():String { return _type; }
		public function getImageHolder() : Image { return _mImageHolder; }
		public function isCaptured():Boolean { return _captured; }
		public function getPosition():Position { return new Position(_curRow, _curColumn); }
		public function getInitialPosition():Position { return new Position(_row,_column); }

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
			this._centerX = x;
			this._centerY = y;
		}

		public function draw(parentClip:Canvas, offset:int, width:int, height:int, pieceSkinIndex:int) : void
		{
			_parentClip = parentClip;
			var viewPos:Position = _board.getViewPosition(getPosition());
			_mImageHolder = new Image();
			_mImageHolder.name = _imgLabel;
			_mImageHolder.x = (offset + viewPos.column * width) - _centerX;
			_mImageHolder.y = (offset + viewPos.row * height) - _centerY;
			_mImageHolder.source =  Global.BASE_URI + "res/images/pieces/" + pieceSkinIndex + "/" + _imageSrc;
			parentClip.addChild(_mImageHolder);
		}

		public function enableEvents() : void
		{
			if (_mImageHolder != null) {
				_mImageHolder.addEventListener(MouseEvent.MOUSE_DOWN, startDragHandler);
				_mImageHolder.addEventListener(MouseEvent.MOUSE_UP, stopDragHandler);
				_enabled = true;
			}
		}

		public function disableEvents() : void
		{
			if (_mImageHolder != null) {
				_mImageHolder.removeEventListener(MouseEvent.MOUSE_DOWN, startDragHandler);
				_mImageHolder.removeEventListener(MouseEvent.MOUSE_UP, stopDragHandler);
				_enabled = false;
			}
		}

		private function startDragHandler(evt:MouseEvent) : void 
		{
			var maxDepth:int = _parentClip.numChildren - 1;
			_parentClip.setChildIndex(_mImageHolder, maxDepth);
			_mImageHolder.startDrag();
		}

		private function stopDragHandler(evt:MouseEvent) : void 
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
		
		public function setFocus() : void
		{
			_inFocus = true;
			if (_mImageHolder != null)
			{	
	            const glowFilter:GlowFilter = new GlowFilter( 0x33CCFF /* color */,
							                                  0.8      /* alpha */,
							                                  10       /* blurX */,
							                                  10       /* blurY */,
							                                  2        /* strength */,
							                                  BitmapFilterQuality.HIGH,
							                                  false   /* inner */,
							                                  false   /* knockout */ );
				_mImageHolder.filters = [glowFilter];
			}
		}

		public function clearFocus() : void
		{
			_inFocus = false;
			if (_mImageHolder != null) {
				_mImageHolder.filters = [];
			}
		}

		public function removeImage(parentClip:Canvas) : void
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

		public function moveImage() : void
		{
			var viewPos:Position = _board.getViewPosition(getPosition());
			if (_mImageHolder != null) {
				_mImageHolder.x = _board.getX(viewPos.column) - _imageRadius;
				_mImageHolder.y = _board.getY(viewPos.row) - _imageRadius;
			}
		}
	}
}
