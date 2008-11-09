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

	override function draw( display : h3d.Display, ibuf, vbuf, lbuf, uvbuf  ) {
		if( bmp == null )
			update();
		var g = display.getContext(flash.display.BlendMode.NORMAL);
		g.beginBitmapFill(bmp,null,false,false);
		g.drawTriangles(vbuf,ibuf,lbuf,h3d.Const.CULLING);
		g.endFill();
		g = display.getContext(flash.display.BlendMode.MULTIPLY);
		g.beginBitmapFill(texture.bitmap,null,false,false);
		g.drawTriangles(vbuf,ibuf,uvbuf,h3d.Const.CULLING);
		g.endFill();
	}

}