package h3d;

class Display {

	public var width(default,null) : Int;
	public var height(default,null) : Int;
	public var g : flash.display.Graphics;
	var context : flash.display.Shape;

	public function new( container : flash.display.DisplayObjectContainer, width : Int, height : Int ) {
		this.width = width;
		this.height = height;
		context = new flash.display.Shape();
		context.x = width >> 1;
		context.y = height >> 1;
		container.addChild(context);
		g = context.graphics;
	}

}