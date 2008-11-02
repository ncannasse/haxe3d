package h3d.internal;

class PrimInst {

	public var p : h3d.prim.Primitive;
	public var triangles : ZTriangle;

	public function new(p) {
		this.p = p;
		for( t in p.triangles ) {
			var t2 = new ZTriangle();
			t2.v0 = t.v0;
			t2.v1 = t.v1;
			t2.v2 = t.v2;
			t2.mat = p.material.id;
			t2.material = p.material;
			t2.next = triangles;
			triangles = t2;
		}
	}

}