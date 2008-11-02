package h3d.mat;

class BitmapMaterial extends Material {

	public var ambient : Color;
	public var texture : Texture;

	public function new( ambient : Color, texture : Texture ) {
		super();
		this.ambient = ambient;
		this.texture = texture;
	}

	override function setup( display : h3d.Display ) {
		display.g.beginBitmapFill(texture.bitmap);
	}

}