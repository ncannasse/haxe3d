package h3d.internal;

class Point {

	public var x : Float;
	public var y : Float;
	public var z : Float;
	public var sx : Float;
	public var sy : Float;
	public var w : Float;
	public var next : Point;

	public function new( p : h3d.Vector ) {
		this.x = p.x;
		this.y = p.y;
		this.z = p.z;
	}

}