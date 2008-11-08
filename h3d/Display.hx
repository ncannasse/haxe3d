package h3d;

private class ShapeList extends flash.display.Shape {
	public var next : ShapeList;
}

class Display {

	public var width(default,null) : Int;
	public var height(default,null) : Int;
	public var result : flash.display.DisplayObject;
	var scene : flash.display.Sprite;
	var bitmap : flash.display.BitmapData;
	var current : flash.display.Graphics;
	var curmode : flash.display.BlendMode;
	var shapeCache : ShapeList;
	var shapeUsed : ShapeList;

	public function new( width : Int, height : Int ) {
		this.width = width;
		this.height = height;
		bitmap = new flash.display.BitmapData(width,height,true,0);
		result = new flash.display.Bitmap(bitmap);
	}

	public function beginDraw() {
		current = null;
		curmode = null;
		scene = new flash.display.Sprite();
	}

	public function shapeCount() {
		return scene.numChildren;
	}

	public inline function getContext( mode ) {
		if( mode != curmode )
			setContext(mode);
		return current;
	}

	function setContext(mode) {
		var s = shapeCache;
		if( s == null ) {
			s = new ShapeList();
			s.x = width >> 1;
			s.y = height >> 1;
		} else
			shapeCache = s.next;
		s.next = shapeUsed;
		shapeUsed = s;
		s.blendMode = mode;
		scene.addChild(s);
		current = s.graphics;
		curmode = mode;
	}

	public function endDraw() {
		bitmap.lock();
		bitmap.fillRect(bitmap.rect,0);
		// I would prefer to draw the shapes by hand
		// but this crash the flash player 10
		bitmap.draw(scene);
		bitmap.unlock();
		// cleanup
		var s = shapeUsed;
		while( s != null ) {
			s.graphics.clear();
			s = s.next;
		}
		shapeCache = shapeUsed;
		shapeUsed = null;
	}

}