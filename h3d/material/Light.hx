package h3d.material;

class Light {

	public var position : h3d.Vector;
	public var color : Color;
	public var directional : Bool;
	public var power : Float;

	public function new(pos,color,directional,power=1.0) {
		this.position = pos;
		this.color = color;
		this.directional = directional;
		this.power = power;
	}

}