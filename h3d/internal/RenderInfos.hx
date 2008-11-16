package h3d.internal;

class RenderInfos {

	public var display : h3d.Display;
	public var zcoords : flash.Vector<Float>;
	public var triangles : flash.Vector<h3d.internal.Triangle>;
	public var vertexes : flash.Vector<Float>;
	public var lightning : flash.Vector<Float>;
	public var uvcoords : flash.Vector<Float>;
	public var colors : flash.Vector<Float>;

	public var cull : flash.display.TriangleCulling;
	public var cull_no : flash.display.TriangleCulling;
	public var indexes : flash.Vector<Int>;

	public function new(display) {
		this.display = display;
		zcoords = new flash.Vector();
		triangles = new flash.Vector();
		vertexes = new flash.Vector();
		lightning = new flash.Vector();
		uvcoords = new flash.Vector();
		colors = new flash.Vector();
		cull = flash.display.TriangleCulling.POSITIVE;
		cull_no = flash.display.TriangleCulling.NONE;
	}

}