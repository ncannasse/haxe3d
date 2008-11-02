package h3d.internal;

class Vertex {

	public var x : Float;
	public var y : Float;
	public var z : Float;
	public var u : Float;
	public var v : Float;
	public var next : Vertex;

	public function new( x, y, z, u, v ) {
		this.x = x;
		this.y = y;
		this.z = z;
		this.u = u;
		this.v = v;
	}

}