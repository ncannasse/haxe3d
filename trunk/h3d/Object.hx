package h3d;


class Object {

	public var position : Matrix;
	public var primitives : haxe.FastList<h3d.internal.PrimInst>;
	
	public function new() {
		primitives = new haxe.FastList<h3d.internal.PrimInst>();
		position = new Matrix();
		position.identity();
	}

	public inline function addPrimitive(p) {
		primitives.add(new h3d.internal.PrimInst(p));
	}
	
}