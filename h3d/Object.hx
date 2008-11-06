package h3d;


/**
	Level Of Detail.
*/
typedef LOD = {
	var active : Bool;
	var min : Float;
	var max : Float;
}

class Object {

	public var position : Matrix;
	public var primitives : haxe.FastList<h3d.internal.PrimInst>;
	public var lod : LOD;
	
	public function new() {
		primitives = new haxe.FastList<h3d.internal.PrimInst>();
		position = new Matrix();
		position.identity();
		lod = { active: false, min : 0.0, max : Math.POSITIVE_INFINITY };
	}

	public inline function addPrimitive(p) {
		primitives.add(new h3d.internal.PrimInst(p));
	}
	
	public function matchLOD( cam : Camera ) : Bool {
		if( !lod.active ) return true;
		var p = cam.zoom / ( 1 + position._14 / cam.position.length() );
		if( p < lod.min ) return false;
		if( p >= lod.max ) return false;
		return true;
	}
	
}