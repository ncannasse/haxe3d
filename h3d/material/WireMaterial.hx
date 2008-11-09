package h3d.material;

class WireMaterial extends Material {

	public var color : Color;

	public function new(color) {
		super();
		this.color = color;
	}

	override function draw( display : h3d.Display, ibuf : flash.Vector<Int>, vbuf : flash.Vector<Float>, lbuf : flash.Vector<Float>, uvbuf : flash.Vector<Float> ) {
		var g = display.getContext(flash.display.BlendMode.NORMAL);
		g.lineStyle(1,color.argb,color.a);
		g.drawTriangles(vbuf,ibuf,null,flash.display.TriangleCulling.NONE);
		g.lineStyle();
	}

}