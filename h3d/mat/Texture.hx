package h3d.mat;

class Texture {

	public var file(default,null) : String;
	public var bitmap : flash.display.BitmapData;

	public function new( file : String ) {
		this.file = file;
		bitmap = EMPTY_BITMAP;
	}

	static var EMPTY_BITMAP = new flash.display.BitmapData(1,1,true,0xFFFF00FF);

}