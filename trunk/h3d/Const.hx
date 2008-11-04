package h3d;

class Const {

	public static inline var EPSILON = 1e-10;
	public static inline var CULLING : flash.display.TriangleCulling = cast "positive";
	public static var DEFAULT_SHADE_MODEL = h3d.mat.ShadeModel.Gouraud;

	// round to 4 significant digits, eliminates <1e-10
	public static function f( v : Float ) {
		var neg;
		if( v < 0 ) {
			neg = -1.0;
			v = -v;
		} else
			neg = 1.0;
		var digits = Std.int(4 - Math.log(v) / Math.log(10));
		if( digits < 1 )
			digits = 1;
		else if( digits >= 10 )
			return 0.;
		var exp = Math.pow(10,digits);
		return Math.floor(v * exp + .49999) * neg / exp;
	}

}