package h3d.internal;

class PrimTmpData {

	public var avertexes : flash.Vector<Vertex>;
	public var hvertexes : flash.Vector<Array<Int>>;
	public var points : flash.Vector<Point>;
	public var normals : flash.Vector<Normal>;
	public var tcoords : flash.Vector<h3d.mat.UV>;
	public var v0 : h3d.Vector;

	public function new( ntcoords ) {
		avertexes = new flash.Vector();
		hvertexes = new flash.Vector();
		for( i in 0...ntcoords )
			hvertexes[i] = new Array();
		points = new flash.Vector();
		normals = new flash.Vector();
		tcoords = new flash.Vector();
		v0 = new h3d.Vector();
	}

}