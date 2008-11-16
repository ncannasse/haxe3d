package h3d.material;

class BitmapMaterial extends Material {

	public var ambient : Color;
	public var texture : Texture;
	var bmp : flash.display.BitmapData;

	public function new( ambient : Color, texture : Texture ) {
		super();
		this.ambient = ambient;
		this.texture = texture;
	}

	override function free() {
		if( bmp != null ) bmp.dispose();
	}

	override function update() {
		if( bmp == null )
			bmp = new flash.display.BitmapData(256,1,true,0);
		buildAmbientDiffuseBitmap(bmp,new Color(0,0,0,1),ambient);
	}

	override function draw( r : h3d.internal.RenderInfos  ) {
		if( bmp == null )
			update();
		var g = r.display.getContext(flash.display.BlendMode.NORMAL);
		g.beginBitmapFill(bmp,null,false,false);
		g.drawTriangles(r.vertexes,r.indexes,r.lightning);
		g.endFill();
		g = r.display.getContext(flash.display.BlendMode.MULTIPLY);
		g.beginBitmapFill(texture.bitmap,null,false,false);
		g.drawTriangles(r.vertexes,r.indexes,r.uvcoords);
		g.endFill();
	}

}