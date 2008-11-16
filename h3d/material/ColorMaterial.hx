package h3d.material;

class ColorMaterial extends Material {

	public var ambient : Color;
	public var diffuse : Color;
	var bmp : flash.display.BitmapData;

	public function new( ambient, diffuse ) {
		super();
		this.ambient = ambient;
		this.diffuse = diffuse;
	}

	override function update() {
		if( bmp == null )
			bmp = new flash.display.BitmapData(256,1,true,0);
		buildAmbientDiffuseBitmap(bmp,ambient,diffuse);
	}

	override function free() {
		if( bmp != null ) bmp.dispose();
	}

	override function draw( r : h3d.internal.RenderInfos ) {
		if( bmp == null )
			update();
		var g = r.display.getContext(flash.display.BlendMode.NORMAL);
		g.beginBitmapFill(bmp,null,false,false);
		g.drawTriangles(r.vertexes,r.indexes,r.lightning);
		g.endFill();
	}

	public function toString() {
		return "[ColorMaterial "+StringTools.hex(ambient.argb,8)+":"+StringTools.hex(diffuse.argb,8)+"]";
	}

}