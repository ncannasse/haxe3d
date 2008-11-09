package h3d.internal;

class Vertex {

	public var p : Point;
	public var n : Normal;
	public var u : Float;
	public var v : Float;
	public var next : Vertex;

	public function new( p, n, t : h3d.material.UV ) {
		this.p = p;
		this.n = n;
		this.u = t.u;
		this.v = t.v;
	}

}