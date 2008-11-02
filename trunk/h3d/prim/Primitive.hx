package h3d.prim;
import h3d.Vector;

class Primitive {

	public var points : flash.Vector<h3d.Vector>;
	public var normals : flash.Vector<h3d.Vector>;
	public var tcoords : flash.Vector<h3d.mat.UV>;
	public var triangles : haxe.FastList<h3d.internal.Triangle>;
	public var material : h3d.mat.Material;
	public var vertexes : h3d.internal.Vertex;
	var htn : Array<Int>; // IntHash in fact
	var nvertexes : Int;

	public function new() {
		htn = new Array();
	}

	public function setDatas( pl, nl, ?tl ) {
		this.points = pl;
		this.normals = nl;
		if( tl == null ) {
			tl = new flash.Vector();
			tl.push(new h3d.mat.UV(0,0));
		}
		this.tcoords = tl;
		this.triangles = new haxe.FastList<h3d.internal.Triangle>();
		nvertexes = 0;
		vertexes = null;
	}

	public inline function setMaterial( m ) {
		this.material = m;
	}

	function makeVertex( v, t ) : Int {
		var vid = (v << 16) | t;
		var idx = htn[vid];
		if( idx != 0 )
			return idx - 1;
		idx = ++nvertexes;
		htn[vid] = idx;
		var p = points[v];
		var t = tcoords[t];
		var v = new h3d.internal.Vertex(p.x,p.y,p.z,t.u,t.v);
		v.next = vertexes;
		vertexes = v;
		return idx - 1;
	}

	public inline function addTriangle( v0, v1, v2, n0, n1, n2, t0, t1, t2 ) {
		var t = new h3d.internal.Triangle();
		t.v0 = makeVertex(v0,t0);
		t.v1 = makeVertex(v1,t1);
		t.v2 = makeVertex(v2,t2);
		triangles.add(t);
	}

	public function done() {
		var vl = null;
		// reverse the list
		var v = vertexes;
		while( v != null ) {
			var next = v.next;
			v.next = vl;
			vl = v;
			v = next;
		}
		vertexes = vl;
	}

}