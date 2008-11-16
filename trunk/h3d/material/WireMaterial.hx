package h3d.material;

class WireMaterial extends Material {

	public var color : Color;

	public function new(color) {
		super();
		this.color = color;
	}

	override function draw( r : h3d.internal.RenderInfos ) {
		var g = r.display.getContext(flash.display.BlendMode.NORMAL);
		g.lineStyle(1,color.argb,color.a);
		g.drawTriangles(r.vertexes,r.indexes,null);
		g.lineStyle();
	}

}