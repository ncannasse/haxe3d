package h3d.mat;

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

	override function draw( display : h3d.Display, ibuf, vbuf, lbuf, uvbuf  ) {
		if( bmp == null )
			update();
		var g = display.gcolor;
		g.beginBitmapFill(bmp,null,false,false);
		g.drawTriangles(vbuf,ibuf,lbuf,h3d.Const.CULLING);
		g.endFill();
		// we need to draw on the bitmap layer as well
		// since we don't want part of our color layer
		// to be masked with a triangle of the bitmap layer
		// that would have otherwise been overwritten...

		// we might use this step for performing additional lightning as well
		// such as specular
		var g = display.gbitmap;
		g.beginFill(0xFFFFFF);
		g.drawTriangles(vbuf,ibuf,null,h3d.Const.CULLING);
		g.endFill();
	}

}