package h3d.material;

class VColorMaterial extends Material {

	var bmpR : flash.display.BitmapData;
	var bmpGB : flash.display.BitmapData;

	public function new() {
		super();
		shade = ShadeModel.VertexColor;
		init();
	}

	function init() {
		bmpR = new flash.display.BitmapData(256,1,true,0);
		bmpGB = new flash.display.BitmapData(256,256,true,0);
		bmpR.lock();
		bmpGB.lock();
		for( x in 0...256 ) {
			bmpR.setPixel32(x,0,0xFF000000 | (x << 16));
			for( y in 0...256 )
				bmpGB.setPixel32(x,y,0xFF000000 | (x << 8) | y);
		}
		bmpR.unlock();
		bmpGB.unlock();
	}

	override function free() {
		bmpR.dispose();
		bmpGB.dispose();
	}

	override function draw( r : h3d.internal.RenderInfos ) {
		var g = r.display.getContext(flash.display.BlendMode.NORMAL);
		g.beginBitmapFill(bmpR,null,false,false);
		g.drawTriangles(r.vertexes,r.indexes,r.lightning);
		g.endFill();
		g = r.display.getContext(flash.display.BlendMode.ADD);
		g.beginBitmapFill(bmpGB,null,false,false);
		g.drawTriangles(r.vertexes,r.indexes,r.colors);
		g.endFill();
	}

}