package h3d;

class Matrix {

	public var _11 : Float;
	public var _12 : Float;
	public var _13 : Float;
	public var _14 : Float;
	public var _21 : Float;
	public var _22 : Float;
	public var _23 : Float;
	public var _24 : Float;
	public var _31 : Float;
	public var _32 : Float;
	public var _33 : Float;
	public var _34 : Float;
	public var _41 : Float;
	public var _42 : Float;
	public var _43 : Float;
	public var _44 : Float;

	public function new() {
	}

	public function zero() {
		_11 = 0.0; _12 = 0.0; _13 = 0.0; _14 = 0.0;
		_21 = 0.0; _22 = 0.0; _23 = 0.0; _24 = 0.0;
		_31 = 0.0; _32 = 0.0; _33 = 0.0; _34 = 0.0;
		_41 = 0.0; _42 = 0.0; _43 = 0.0; _44 = 0.0;
	}

	public function identity() {
		_11 = 1.0; _12 = 0.0; _13 = 0.0; _14 = 0.0;
		_21 = 0.0; _22 = 1.0; _23 = 0.0; _24 = 0.0;
		_31 = 0.0; _32 = 0.0; _33 = 1.0; _34 = 0.0;
		_41 = 0.0; _42 = 0.0; _43 = 0.0; _44 = 1.0;
	}

	public function multiply( a : Matrix, b : Matrix ) {
		var a11 = a._11; var a12 = a._12; var a13 = a._13; var a14 = a._14;
		var a21 = a._21; var a22 = a._22; var a23 = a._23; var a24 = a._24;
		var a31 = a._31; var a32 = a._32; var a33 = a._33; var a34 = a._34;
		var a41 = a._41; var a42 = a._42; var a43 = a._43; var a44 = a._44;
		var b11 = b._11; var b12 = b._12; var b13 = b._13; var b14 = b._14;
		var b21 = b._21; var b22 = b._22; var b23 = b._23; var b24 = b._24;
		var b31 = b._31; var b32 = b._32; var b33 = b._33; var b34 = b._34;
		var b41 = b._41; var b42 = b._42; var b43 = b._43; var b44 = b._44;

		_11 = a11 * b11 + a12 * b21 + a13 * b31 + a14 * b41;
		_12 = a11 * b12 + a12 * b22 + a13 * b32 + a14 * b42;
		_13 = a11 * b13 + a12 * b23 + a13 * b33 + a14 * b43;
		_14 = a11 * b14 + a12 * b24 + a13 * b34 + a14 * b44;

		_21 = a21 * b11 + a22 * b21 + a23 * b31 + a24 * b41;
		_22 = a21 * b12 + a22 * b22 + a23 * b32 + a24 * b42;
		_23 = a21 * b13 + a22 * b23 + a23 * b33 + a24 * b43;
		_24 = a21 * b14 + a22 * b24 + a23 * b34 + a24 * b44;

		_31 = a31 * b11 + a32 * b21 + a33 * b31 + a34 * b41;
		_32 = a31 * b12 + a32 * b22 + a33 * b32 + a34 * b42;
		_33 = a31 * b13 + a32 * b23 + a33 * b33 + a34 * b43;
		_34 = a31 * b14 + a32 * b24 + a33 * b34 + a34 * b44;

		_41 = a41 * b11 + a42 * b21 + a43 * b31 + a44 * b41;
		_42 = a41 * b12 + a42 * b22 + a43 * b32 + a44 * b42;
		_43 = a41 * b13 + a42 * b23 + a43 * b33 + a44 * b43;
		_44 = a41 * b14 + a42 * b24 + a43 * b34 + a44 * b44;
	}

	public inline function project( v : Vector, out : Vector ) {
		var px = _11 * v.x + _21 * v.y + _31 * v.z + _41;
		var py = _12 * v.x + _22 * v.y + _32 * v.z + _42;
		var pz = _13 * v.x + _23 * v.y + _33 * v.z + _43;
		var pw = _14 * v.x + _24 * v.y + _34 * v.z + _44;
		pw = 1.0 / pw;
		out.x = px * pw;
		out.y = py * pw;
		out.z = pz;
	}

	public function toString() {
		return "MAT=[\n" +
			"  [ " + Const.f(_11) + ", " + Const.f(_12) + ", " + Const.f(_13) + ", " + Const.f(_14) + " ]\n" +
			"  [ " + Const.f(_21) + ", " + Const.f(_22) + ", " + Const.f(_23) + ", " + Const.f(_24) + " ]\n" +
			"  [ " + Const.f(_31) + ", " + Const.f(_32) + ", " + Const.f(_33) + ", " + Const.f(_34) + " ]\n" +
			"  [ " + Const.f(_41) + ", " + Const.f(_42) + ", " + Const.f(_43) + ", " + Const.f(_44) + " ]\n" +
		"]";
	}

}