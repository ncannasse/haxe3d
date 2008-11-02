package h3d.mat;

class Color {

	public var r : Float;
	public var g : Float;
	public var b : Float;
	public var a : Float;

	public function new( r, g, b, a ) {
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}

	public inline function toInt() {
		return Std.int(a * 255.0) << 24 | Std.int(r * 255.0) << 16 | Std.int(g * 255.0) << 8 | Std.int(b * 255.0);
	}

	public function toString() {
		return "[Color = "+StringTools.hex(toInt(),8)+"]";
	}

	public static inline function ofInt( c : Int ) {
		return new Color(((c >> 16) & 0xFF) / 255.0,((c >> 8) & 0xFF) / 255.0,(c & 0xFF) / 255.0,(c >>> 24) / 255.0);
	}

}
