package h3d.mat;

class Material {

	static var UID = 0;

	public var id(default,null) : Int;

	function new() {
		id = ++UID;
	}

	public function setup( display : h3d.Display ) {
		// TO OVERRIDE
	}

}