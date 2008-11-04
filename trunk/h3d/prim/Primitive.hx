package h3d.prim;
import h3d.Vector;

class Primitive {

	public var points : h3d.internal.Point;
	public var normals : h3d.internal.Normal;
	public var vertexes : h3d.internal.Vertex;
	public var triangles : h3d.internal.Triangle;
	public var material : h3d.mat.Material;

	var tmpData : h3d.internal.PrimTmpData;

	public function new() {
	}

	public function setDatas( points : flash.Vector<h3d.Vector>, normals : flash.Vector<h3d.Vector>, ?tcoords : flash.Vector<h3d.mat.UV> ) {
		if( tcoords == null ) {
			tcoords = new flash.Vector();
			tcoords[0] = new h3d.mat.UV(0,0);
		}
		var t = new h3d.internal.PrimTmpData(tcoords.length);
		var i = 0;
		for( p in points )
			t.points[i++] = new h3d.internal.Point(p);
		i = 0;
		for( n in normals )
			t.normals[i++] = new h3d.internal.Normal(n);
		t.tcoords = tcoords;
		tmpData = t;
		triangles = null;
	}

	public inline function setMaterial( m ) {
		this.material = m;
	}

	function makeVertex( v, n, t ) : Int {
		var vid = (v << 16) | n;
		var ht = tmpData.hvertexes[t];
		var idx = ht[vid];
		if( idx != 0 )
			return idx - 1;
		idx = tmpData.avertexes.length;
		ht[vid] = idx + 1;
		var p = tmpData.points[v];
		var n = tmpData.normals[n];
		var t = tmpData.tcoords[t];
		var v = new h3d.internal.Vertex(p,n,t);
		tmpData.avertexes[idx] = v;
		return idx;
	}

	public inline function addTriangle( v0, v1, v2, n0, n1, n2, t0, t1, t2 ) {
		var t = new h3d.internal.Triangle();
		t.iv0 = makeVertex(v0,n0,t0);
		t.iv1 = makeVertex(v1,n1,t1);
		t.iv2 = makeVertex(v2,n2,t2);
		t.v0 = tmpData.avertexes[t.iv0];
		t.v1 = tmpData.avertexes[t.iv1];
		t.v2 = tmpData.avertexes[t.iv2];
		// calculate face-normal
		t.n = new h3d.internal.Normal(tmpData.v0);
		t.n.x = (t.v0.n.x + t.v1.n.x + t.v2.n.x) / 3;
		t.n.y = (t.v0.n.y + t.v1.n.y + t.v2.n.y) / 3;
		t.n.z = (t.v0.n.z + t.v1.n.z + t.v2.n.z) / 3;
		t.material = material;
		t.next = triangles;
		triangles = t;
	}

	public function done() {
		var i;
		var t = tmpData;
		// build ordered points list
		i = t.points.length;
		while( i > 0 ) {
			var p = t.points[--i];
			p.next = points;
			points = p;
		}
		// build ordered normal list
		i = t.normals.length;
		while( i > 0 ) {
			var n = t.normals[--i];
			n.next = normals;
			normals = n;
		}
		// build ordered vertex list
		i = t.avertexes.length;
		while( i > 0 ) {
			var v = t.avertexes[--i];
			v.next = vertexes;
			vertexes = v;
		}
		tmpData = null;
	}

}