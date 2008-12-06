package h3d.internal;

class RenderInfos {

	public var display : h3d.Display;
	public var vertexes : flash.Vector<Float>;
	public var lightning : flash.Vector<Float>;
	public var uvcoords : flash.Vector<Float>;
	public var colors : flash.Vector<Float>;
	public var indexes : flash.Vector<Int>;
	public var triangles : flash.Vector<h3d.internal.Triangle>;

	public function new(display) {
		this.display = display;
	}

}