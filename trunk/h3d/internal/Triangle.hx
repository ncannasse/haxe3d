package h3d.internal;

class Triangle {

	public var z : Float;
	public var v0 : Vertex;
	public var v1 : Vertex;
	public var v2 : Vertex;
	public var n : Normal;
	public var material : h3d.material.Material;
	public var next : Triangle;

	public function new() {
	}

}
