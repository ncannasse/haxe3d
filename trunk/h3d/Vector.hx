package h3d;

class Vector {

	public var x : Float;
	public var y : Float;
	public var z : Float;

	public function new( x = 0., y = 0., z = 0. ) {
		this.x = x;
		this.y = y;
		this.z = z;
	}

	public inline function sub( v : Vector ) {
		return new Vector(x - v.x, y - v.y, z - v.z);
	}

	public inline function add( v : Vector ) {
		return new Vector(x + v.x, y + v.y, z + v.z);
	}

	public inline function cross( v : Vector ) {
		return new Vector(y * v.z - z * v.y, z * v.x - x * v.z,  x * v.y - y * v.x);
	}

	public inline function dot( v : Vector ) {
		return x * v.x + y * v.y + z * v.z;
	}

	public inline function length() {
		return Math.sqrt(x * x + y * y + z * z);
	}

	public function normalize() {
		var k = length();
		if( k < Const.EPSILON ) k = 0 else k = 1.0 / k;
		x *= k;
		y *= k;
		z *= k;
	}

	public function set(x,y,z) {
		this.x = x;
		this.y = y;
		this.z = z;
	}

	public inline function scale( f : Float ) {
		x *= f;
		y *= f;
		z *= f;
	}

	public inline function copy() {
		return new Vector(x,y,z);
	}

	public function toString() {
		return "{"+Const.f(x)+","+Const.f(y)+","+Const.f(z)+"}";
	}


}