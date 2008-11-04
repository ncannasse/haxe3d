package h3d.internal;

class Triangle {

	public var z : Float;
	public var ibase : Int;
	public var iv0 : Int;
	public var iv1 : Int;
	public var iv2 : Int;
	public var v0 : Vertex;
	public var v1 : Vertex;
	public var v2 : Vertex;
	public var n : Normal;
	public var material : h3d.mat.Material;
	public var next : Triangle;

	public function new() {
	}

}
