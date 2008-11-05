package h3d.internal;

class Stats {

	public var objects : Int;
	public var primitives : Int;
	public var triangles : Int;
	public var drawCalls : Int;

	public var transformTime : Float;
	public var sortTime : Float;
	public var materialTime : Float;
	public var drawTime : Float;
	public var timeLag : Float;

	public function new() {
		timeLag = 0.9;
		transformTime = 0;
		materialTime = 0;
		sortTime = 0;
		drawTime = 0;
	}

	public function toString() {
		var data = {
			objects : objects,
			primitives : primitives,
			triangles : triangles,
			drawCalls : drawCalls,
			transform : h3d.Const.f(transformTime),
			sort : h3d.Const.f(sortTime),
			material : h3d.Const.f(materialTime),
			draw : h3d.Const.f(drawTime),
		};
		return "STATS = " + Std.string(data);
	}

}