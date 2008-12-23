package h3d.material;

class BitmapMaterial extends Material {

	public var sub : Material;
	public var smooth : Bool;
	public var texture : Texture;

	public function new( sub : Material, texture : Texture ) {
		super();
		this.sub = sub;
		this.smooth = false;
		this.texture = texture;
	}

	override function free() {
		if( sub != null ) sub.free();
	}

	override function draw( r : h3d.internal.RenderInfos  ) {
		if( sub != null ) sub.draw(r);
		var g = r.display.getContext(flash.display.BlendMode.MULTIPLY);
		g.beginBitmapFill(texture.bitmap,null,false,smooth);
		g.drawTriangles(r.vertexes,r.indexes,r.uvcoords);
	}

}