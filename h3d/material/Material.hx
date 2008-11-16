package h3d.material;

class Material {

	public var shade : ShadeModel;

	function new() {
		shade = h3d.Const.DEFAULT_SHADE_MODEL;
	}

	function buildAmbientDiffuseBitmap( bmp : flash.display.BitmapData, ambient : Color, diffuse : Color ) {
		var size = bmp.width;
		var d = 1 / (size - 1);
		for( i in 0...size ) {
			var k = i * d;
			var r = ambient.r + diffuse.r * k;
			var g = ambient.g + diffuse.g * k;
			var b = ambient.b + diffuse.b * k;
			var a = ambient.a + diffuse.a * k;
			if( r > 1 ) r = 1;
			if( g > 1 ) g = 1;
			if( b > 1 ) b = 1;
			if( a > 1 ) a = 1;
			bmp.setPixel32(i,0,new Color(r,g,b,a).argb);
		}
	}

	public function update() {
		// TO OVERRIDE
	}

	public function free() {
		// TO OVERRIDE
	}

	public function draw( r : h3d.internal.RenderInfos ) {
		// TO OVERRIDE
	}

}