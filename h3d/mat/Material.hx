package h3d.mat;

class Material {

	public var shade(default,null) : ShadeModel;

	function new() {
		shade = h3d.Const.DEFAULT_SHADE_MODEL;
	}

	public function setup( display : h3d.Display, bitmapMode : Bool  ) {
		// TO OVERRIDE
	}

}