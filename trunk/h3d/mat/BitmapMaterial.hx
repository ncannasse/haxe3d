package h3d.mat;

class BitmapMaterial extends Material {

	public var ambient : Color;
	public var texture : Texture;
	var rgb : Int;

	public function new( ambient : Color, texture : Texture ) {
		super();
		this.ambient = ambient;
		this.texture = texture;
		rgb = ambient.toInt();
	}

	override function setup( display : h3d.Display, bitmapMode ) {
		if( bitmapMode )
			display.gbitmap.beginBitmapFill(texture.bitmap);
		else
			display.gcolor.beginFill(rgb,ambient.a);
	}

}