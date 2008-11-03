package h3d.internal;

class Normal {

	public var x : Float;
	public var y : Float;
	public var z : Float;
	public var lum : Float;
	public var next : Normal;

	public function new( p : h3d.Vector ) {
		this.x = p.x;
		this.y = p.y;
		this.z = p.z;
	}

}