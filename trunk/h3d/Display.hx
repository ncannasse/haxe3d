package h3d;

class Display {

	public var width(default,null) : Int;
	public var height(default,null) : Int;
	public var gcolor : flash.display.Graphics;
	public var gbitmap : flash.display.Graphics;
	public var ghud : flash.display.Graphics;
	public var result : flash.display.DisplayObject;
	var scene : flash.display.Sprite;
	var bitmap : flash.display.BitmapData;
	var colShape : flash.display.Shape;
	var bmpShape : flash.display.Shape;
	var hudShape : flash.display.Shape;
	var pos : flash.geom.Matrix;

	public function new( width : Int, height : Int ) {
		this.width = width;
		this.height = height;
		bitmap = new flash.display.BitmapData(width,height,true,0);
		scene = new flash.display.Sprite();
		result = new flash.display.Bitmap(bitmap);
		pos = new flash.geom.Matrix();
		pos.translate(width/2,height/2);
		colShape = new flash.display.Shape();
		bmpShape = new flash.display.Shape();
		hudShape = new flash.display.Shape();
		scene.addChild(colShape);
		scene.addChild(bmpShape);
		scene.addChild(hudShape);
		colShape.x = bmpShape.x = hudShape.x = width / 2;
		colShape.y = bmpShape.y = hudShape.y = height / 2;
		bmpShape.blendMode = flash.display.BlendMode.MULTIPLY;
		gcolor = colShape.graphics;
		gbitmap = bmpShape.graphics;
		ghud = hudShape.graphics;
	}

	public function beginDraw() {
	}

	public function endDraw() {
		bitmap.lock();
		bitmap.fillRect(bitmap.rect,0);
		// I would prefer to draw the three shapes by hand
		// but this crash the flash player 10
		bitmap.draw(scene);
		bitmap.unlock();
		gcolor.clear();
		gbitmap.clear();
		ghud.clear();
	}

}