package h3d.material;

class Texture {

	public var bitmap : flash.display.BitmapData;

	public function new() {
		bitmap = EMPTY_BITMAP;
	}

	public function free() {
		bitmap.dispose();
	}

	static var EMPTY_BITMAP = new flash.display.BitmapData(1,1,true,0xFFFF00FF);

}