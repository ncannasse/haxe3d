package h3d;


class Object {

	public var name : String;
	public var position : Matrix;
	public var primitives : haxe.FastList<h3d.internal.PrimInst>;

	public function new(?name:String) {
		primitives = new haxe.FastList<h3d.internal.PrimInst>();
		position = new Matrix();
		position.identity();
		this.name = name;
	}

	public inline function addPrimitive(p) {
		primitives.add(new h3d.internal.PrimInst(p));
	}

}