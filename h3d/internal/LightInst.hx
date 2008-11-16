package h3d.internal;

class LightInst {

	public var l : h3d.material.Light;
	public var pos : h3d.Vector;
	public var lx : Float;
	public var ly : Float;
	public var lz : Float;
	public var r : Float;
	public var g : Float;
	public var b : Float;

	public function new(l) {
		this.l = l;
		pos = new h3d.Vector();
	}

}