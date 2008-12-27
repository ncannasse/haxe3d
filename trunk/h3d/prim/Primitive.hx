package h3d.prim;
import h3d.Vector;

class Primitive {

	public var points : h3d.internal.Point;
	public var normals : h3d.internal.Normal;
	public var vertexes : h3d.internal.Vertex;
	public var triangles : h3d.internal.Triangle;
	public var material(default,null) : h3d.material.Material;

	public function setMaterial( m ) {
		this.material = m;
		var t = triangles;
		while( t != null ) {
			t.material = m;
			t = t.next;
		}
	}

}