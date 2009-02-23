package h3d.tools;

class AbstractModelReader {

	public var materials : Hash<h3d.material.Material>;
	public var textures : Hash<{ file : String, texture : h3d.material.Texture }>;
	public var objects : Hash<h3d.Object>;

	var basepath : String;

	public function new(url:String) {
		materials = new Hash();
		textures = new Hash();
		objects = new Hash();

		var r = ~/[\\\/]/g;
		var upath = r.split(url);
		upath.pop();
		basepath = upath.join("/");
	}

	public function parse( data : flash.utils.ByteArray ) {}

	function loadTextures() {
		var r = ~/[\\\/]/g;
		var loader = new Loader();
		for( t in textures ) {
			var tpath = r.split(t.file);
			var file = basepath + "/" + tpath.pop();
			loader.loadTexture(file, t.texture);
		}
		loader.onLoaded = onTexturesLoaded;
		loader.onError = onTexturesError;
		loader.start();
	}

	private function onTexturesLoaded() {}

	private function onTexturesError(url : String, msg : String ) {
		throw "Error while loading "+url+" ("+msg+")";
	}

	public dynamic function onComplete() {}
}