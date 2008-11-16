package h3d.material;

class Color {

	public var r(default,null) : Float;
	public var g(default,null) : Float;
	public var b(default,null) : Float;
	public var a(default,null) : Float;
	public var argb(default,null) : Int;

	public function new( r, g, b, ?a = 1.0 ) {
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
		argb = Std.int(a * 255.0) << 24 | Std.int(r * 255.0) << 16 | Std.int(g * 255.0) << 8 | Std.int(b * 255.0);
	}

	public function add( c : Color ) {
		var r = r + c.r;
		var g = g + c.g;
		var b = b + c.b;
		var a = a + c.a;
		if( r > 1 ) r = 1;
		if( g > 1 ) g = 1;
		if( b > 1 ) b = 1;
		if( a > 1 ) a = 1;
		return new Color(r,g,b,a);
	}

	public function scale( f : Float ) {
		var r = r * f;
		var g = g * f;
		var b = b * f;
		if( r > 1 ) r = 1;
		if( g > 1 ) g = 1;
		if( b > 1 ) b = 1;
		return new Color(r,g,b,a);
	}

	public function toString() {
		return "[Color = "+StringTools.hex(argb,8)+"]";
	}

	public static inline function ofInt( c : Int ) {
		return new Color(((c >> 16) & 0xFF) / 255.0,((c >> 8) & 0xFF) / 255.0,(c & 0xFF) / 255.0,(c >>> 24) / 255.0);
	}

}
