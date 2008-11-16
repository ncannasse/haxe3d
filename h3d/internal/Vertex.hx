package h3d.internal;

class Vertex {

	// datas
	public var p : Point;
	public var n : Normal;
	public var u : Float;
	public var v : Float;
	public var cr : Float;
	public var cg : Float;
	public var cb : Float;
	// light
	public var lum : Float;
	public var r : Float;
	public var g : Float;
	public var b : Float;
	public var next : Vertex;

	public function new( p, n, t : h3d.material.UV ) {
		this.p = p;
		this.n = n;
		this.u = t.u;
		this.v = t.v;
		this.cr = 0.0;
		this.cg = 0.0;
		this.cb = 0.0;
	}

}