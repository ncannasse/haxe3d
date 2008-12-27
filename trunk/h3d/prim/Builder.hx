package h3d.prim;

class Builder extends Primitive {

	var avertexes : flash.Vector<h3d.internal.Vertex>;
	var hvertexes : flash.Vector<Array<Int>>;
	var vpoints : flash.Vector<h3d.internal.Point>;
	var vnormals : flash.Vector<h3d.internal.Normal>;
	var vtcoords : flash.Vector<h3d.material.UV>;
	var vzero : h3d.Vector;

	public function new() {
	}

	public function init( points : flash.Vector<h3d.Vector>, normals : flash.Vector<h3d.Vector>, ?tcoords : flash.Vector<h3d.material.UV> ) {
		if( tcoords == null ) {
			tcoords = new flash.Vector();
			tcoords[0] = new h3d.material.UV(0,0);
		}
		avertexes = new flash.Vector();
		hvertexes = new flash.Vector();
		for( i in 0...tcoords.length )
			hvertexes[i] = new Array();
		vpoints = new flash.Vector();
		vnormals = new flash.Vector();
		vtcoords = new flash.Vector();
		var i = 0;
		for( p in points )
			vpoints[i++] = new h3d.internal.Point(p);
		i = 0;
		for( n in normals )
			vnormals[i++] = new h3d.internal.Normal(n);
		vtcoords = tcoords;
		vzero = new h3d.Vector(0,0,0);
		triangles = null;
		points = null;
		normals = null;
		vertexes = null;
	}

	function makeVertex( v, n, t ) : Int {
		var vid = (v << 16) | n;
		var ht = hvertexes[t];
		var idx = ht[vid];
		if( idx != 0 )
			return idx - 1;
		idx = avertexes.length;
		ht[vid] = idx + 1;
		var p = vpoints[v];
		var n = vnormals[n];
		var t = vtcoords[t];
		var v = new h3d.internal.Vertex(p,n,t);
		avertexes[idx] = v;
		return idx;
	}

	public function addTriangle( v0, v1, v2, n0, n1, n2, t0, t1, t2 ) {
		var t = new h3d.internal.Triangle();
		var iv0 = makeVertex(v0,n0,t0);
		var iv1 = makeVertex(v1,n1,t1);
		var iv2 = makeVertex(v2,n2,t2);
		t.v0 = avertexes[iv0];
		t.v1 = avertexes[iv1];
		t.v2 = avertexes[iv2];
		// calculate face-normal
		t.n = new h3d.internal.Normal(vzero);
		t.n.x = (t.v0.n.x + t.v1.n.x + t.v2.n.x) / 3;
		t.n.y = (t.v0.n.y + t.v1.n.y + t.v2.n.y) / 3;
		t.n.z = (t.v0.n.z + t.v1.n.z + t.v2.n.z) / 3;
		t.material = material;
		t.next = triangles;
		triangles = t;
	}

	public function done() {
		var i;
		// build ordered points list
		i = vpoints.length;
		while( i > 0 ) {
			var p = vpoints[--i];
			p.next = points;
			points = p;
		}
		// build ordered normal list
		i = vnormals.length;
		while( i > 0 ) {
			var n = vnormals[--i];
			n.next = normals;
			normals = n;
		}
		// build ordered vertex list
		i = avertexes.length;
		while( i > 0 ) {
			var v = avertexes[--i];
			v.next = vertexes;
			vertexes = v;
		}
		// cleanup tmp datas
		vzero = null;
		avertexes = null;
		hvertexes = null;
		vpoints = null;
		vnormals = null;
		vtcoords = null;
	}


}

