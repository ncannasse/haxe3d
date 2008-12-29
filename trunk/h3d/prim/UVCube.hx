package h3d.prim;

import h3d.Vector;
import h3d.material.Material;
import h3d.material.UV;

class UVCube extends Primitive {
	inline static var N = 0.57735027;
	static var vindexes = [ 0, 3, 2, 1,   0, 4, 7, 3,   1, 5, 4, 0,    2, 6, 5, 1,   3, 7, 6, 2,   5, 6, 7, 4];
	static var tindexes = [ 3, 4, 1, 0,   3, 7, 8, 4,   2, 6, 7, 3,   13,11,10,12,   4, 8, 9, 5,  10,11, 8, 7];
	//                      TOP           REAR          LEFT          FRONT          RIGHT        BOTTOM

	public var width(default, null) : Float;
	public var height(default, null) : Float;
	public var length(default, null) : Float;
	public var invertednormals(default, null) : Bool;

	public function new(material : Material, width : Float, ?height : Float, ?length : Float, invertednormals = false) {
		super(material);

		this.width  = width;
		this.height = height != null ? height : width;
		this.length = length != null ? length : width;
		this.invertednormals = invertednormals;

		init();
	}

	function init() {
		var x = width  / 2;
		var y = height / 2;
		var z = length / 2;

		var points = flash.Lib.vectorOfArray([
			new Vector(-x, -y,  z),
			new Vector(-x,  y,  z),
			new Vector( x,  y,  z),
			new Vector( x, -y,  z),
			new Vector(-x, -y, -z),
			new Vector(-x,  y, -z),
			new Vector( x,  y, -z),
			new Vector( x, -y, -z)
		]);

		var n = invertednormals ? -1 : 1;
		var normals = flash.Lib.vectorOfArray([
			new Vector( 0,  0,  n),
			new Vector( 0, -n,  0),
			new Vector(-n,  0,  0),
			new Vector( 0,  n,  0),
			new Vector( n,  0,  0),
			new Vector( 0,  0, -n)
		]);

		var t1 = 1/3;
		var t2 = 2/3;
		var tcoords = flash.Lib.vectorOfArray([
			new UV(t1, 0),
			new UV(t2, 0),
			new UV( 0, 0.25),
			new UV(t1, 0.25),
			new UV(t2, 0.25),
			new UV( 1, 0.25),
			new UV( 0, 0.5),
			new UV(t1, 0.5),
			new UV(t2, 0.5),
			new UV( 1, 0.5),
			new UV(t1, 0.75),
			new UV(t2, 0.75),
			new UV(t1, 1),
			new UV(t2, 1)
		]);

		var builder = new Builder(material);
		builder.init(points, normals, tcoords);

		var p = 0;
		var n0 = invertednormals ? 3 : 0;
		var n1 = invertednormals ? 2 : 1;
		var n2 = invertednormals ? 1 : 2;
		var n3 = invertednormals ? 0 : 3;
		var indexn = 0;
		for(indexn in 0...6) {
			builder.addQuad(
				vindexes[p+n0],
				vindexes[p+n1],
				vindexes[p+n2],
				vindexes[p+n3],
				indexn,
				indexn,
				indexn,
				indexn,
				tindexes[p+n0],
				tindexes[p+n1],
				tindexes[p+n2],
				tindexes[p+n3]);
			p += 4;
		}
		builder.done();
		builder.assignTo(this);
	}
}