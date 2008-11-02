package h3d.prim;
import h3d.Vector;

class Triangle {

	public var v0 : Int;
	public var v1 : Int;
	public var v2 : Int;
	public var n0 : Int;
	public var n1 : Int;
	public var n2 : Int;
	public var t0 : Int;
	public var t1 : Int;
	public var t2 : Int;

	public function new() {
	}

}

class Primitive {

	public var vertexes : haxe.FastList<h3d.Vector>;
	public var normals : haxe.FastList<h3d.Vector>;
	public var tcoords : flash.Vector<h3d.mat.UV>;
	public var triangles : haxe.FastList<Triangle>;
	public var material : h3d.mat.Material;

	public function new() {
	}

	public inline function setDatas( vl, nl, ?tl ) {
		this.vertexes = vl;
		this.normals = nl;
		this.tcoords = tl;
		this.triangles = new haxe.FastList<Triangle>();
	}

	public inline function setMaterial( m ) {
		this.material = m;
	}

	public inline function addTriangle( v0, v1, v2, n0, n1, n2, t0 = -1, t1 = -1, t2 = -1 ) {
		var t = new Triangle();
		t.v0 = v0;
		t.v1 = v1;
		t.v2 = v2;
		t.n0 = n0;
		t.n1 = n1;
		t.n2 = n2;
		t.t0 = t0;
		t.t1 = t1;
		t.t2 = t2;
		triangles.add(t);
	}

}