package h3d.prim;

class Builder extends Primitive {

	var avertexes : flash.Vector<h3d.internal.Vertex>;
	var hvertexes : flash.Vector<Array<Int>>;
	var vpoints : flash.Vector<h3d.internal.Point>;
	var vnormals : flash.Vector<h3d.internal.Normal>;
	var vtcoords : flash.Vector<h3d.material.UV>;
	var vzero : h3d.Vector;

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
		points = null;
		normals = null;
		vertexes = null;
		triangles = null;
	}

	/**
		Creates and adds a new normal to the internal normals list.
		@param vIdx0 Vertex index
		@param vIdx1 Vertex index
		@param vIdx2 Vertex index
		@return New normal index
	**/
	public function createNormal( vIdx0, vIdx1, vIdx2 ) : Int {
		var rv = vnormals.length;
		var n = new h3d.Vector();
		var v0 = vpoints[vIdx0];
		var v1 = vpoints[vIdx1];
		var v2 = vpoints[vIdx2];
		var d1x:Float = v1.x - v0.x;
		var d1y:Float = v1.y - v0.y;
		var d1z:Float = v1.z - v0.z;

		var d2x:Float = v2.x - v0.x;
		var d2y:Float = v2.y - v0.y;
		var d2z:Float = v2.z - v0.z;

		var pa:Float = d1y*d2z - d1z*d2y;
		var pb:Float = d1z*d2x - d1x*d2z;
		var pc:Float = d1x*d2y - d1y*d2x;

		var pdd = Math.sqrt(pa*pa + pb*pb + pc*pc);

		n.x = pa / pdd;
		n.y = pb / pdd;
		n.z = pc / pdd;
		vnormals.push(new h3d.internal.Normal(n));
		return rv;
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

	public function addTriangle( v0, v1, v2, n0, n1, n2, ?t0 = 0, ?t1 = 0, ?t2 = 0 ) {
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

	public function addQuad( v0, v1, v2, v3, n0, n1, n2, n3, ?t0 = 0, ?t1 = 0, ?t2 = 0, ?t3 = 0 ) {
		addTriangle(v0,v1,v3,n0,n1,n3,t0,t1,t3);
		addTriangle(v1,v2,v3,n1,n2,n3,t1,t2,t3);
	}

	public function assignTo( p : Primitive ) {
		p.points = points;
		p.normals = normals;
		p.vertexes = vertexes;
		p.triangles = triangles;
		p.material = material;
		points = null;
		normals = null;
		vertexes = null;
		triangles = null;
		// keep material
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

