package h3d.tools;

class Loader {

	var cur : flash.display.Loader;
	var queue : Array<{ url : String, callb : flash.display.DisplayObject -> Void }>;

	public function new() {
		queue = new Array();
	}

	public function add(url,callb) {
		queue.push({ url : url, callb : callb });
	}

	public function loadTexture( t : h3d.mat.Texture ) {
		add(t.file,function(obj) {
			var bdata = flash.Lib.as(obj,flash.display.Bitmap);
			t.bitmap = bdata.bitmapData;
		});
	}

	public function start() {
		var e = queue.shift();
		if( e == null ) {
			cur = null;
			onLoaded();
		} else {
			var me = this;
			cur = new flash.display.Loader();
			cur.contentLoaderInfo.addEventListener(flash.events.IOErrorEvent.IO_ERROR,function(err:flash.events.IOErrorEvent) me.onError(e.url,err.text));
			cur.contentLoaderInfo.addEventListener(flash.events.SecurityErrorEvent.SECURITY_ERROR,function(err:flash.events.SecurityErrorEvent) me.onError(e.url,err.text));
			cur.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE,function(_) {
				e.callb(me.cur.content);
				me.start();
			});
			cur.load(new flash.net.URLRequest(e.url));
		}
	}

	public dynamic function onError( url : String, msg : String ) {
		throw "Error while loading "+url+" ("+msg+")";
	}

	public dynamic function onLoaded() {
	}

}