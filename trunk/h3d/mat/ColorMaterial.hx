package h3d.mat;

class ColorMaterial extends Material {

	public var ambient : Color;
	public var diffuse : Color;
	var rgb : Int;

	public function new( ambient, diffuse ) {
		super();
		this.ambient = ambient;
		this.diffuse = diffuse;
		rgb = diffuse.toInt();
	}

	override function setup( display : h3d.Display, bitmapMode ) {
		if( bitmapMode )
			display.gbitmap.beginFill(0xFFFFFF);
		else
			display.gcolor.beginFill(rgb,diffuse.a);
	}

}