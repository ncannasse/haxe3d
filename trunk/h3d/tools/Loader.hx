package h3d.tools;

class Loader {

	var cur : flash.display.Loader;
	var bytes : flash.net.URLLoader;
	var queue : Array<{ url : String, bytes : Bool, callb : Dynamic -> Void }>;

	public function new() {
		queue = new Array();
	}

	public function add(url,bytes,callb) {
		queue.push({ url : url, bytes : bytes, callb : callb });
	}

	public function loadTexture( file : String, t : h3d.material.Texture ) {
		var me = this;
		add(file,false,function(obj) {
			var bdata = flash.Lib.as(obj,flash.display.Bitmap);
			if( bdata == null )
				me.onError(file,"Not a bitmap");
			else
				t.bitmap = bdata.bitmapData;
		});
	}

	public function loadCollada( url : String ) {
		var me = this;
		var col = new h3d.tools.Collada();
		add(url,true,function(data:flash.utils.ByteArray) {
			data.position = 0;
			var x = Xml.parse(data.readUTFBytes(data.length));
			col.loadXML(x);
			// load texture relative to the DAE url
			var r = ~/[\\\/]/g;
			var upath = r.split(url);
			upath.pop();
			var path = upath.join("/");
			for( t in col.textures ) {
				var tpath = r.split(t.file);
				var file = path + "/" + tpath.pop();
				me.loadTexture(file,t.texture);
			}
		});
		return col;
	}

	public function start() {
		var me = this;
		var e = queue.shift();
		cur = null;
		bytes = null;
		if( e == null ) {
			onLoaded();
			return;
		}
		var data = haxe.Resource.getBytes(e.url);
		if( data != null ) {
			if( e.bytes ) {
				e.callb(data.getData());
				start();
			} else {
				cur = new flash.display.Loader();
				cur.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE,function(_) {
					e.callb(me.cur.content);
					me.start();
				});
				cur.loadBytes(data.getData());
			}
			return;
		}
		if( e.bytes ) {
			var me = this;
			bytes = new flash.net.URLLoader(new flash.net.URLRequest(e.url));
			bytes.dataFormat = flash.net.URLLoaderDataFormat.BINARY;
			bytes.addEventListener(flash.events.IOErrorEvent.IO_ERROR,function(err:flash.events.IOErrorEvent) me.onError(e.url,err.text));
			bytes.addEventListener(flash.events.SecurityErrorEvent.SECURITY_ERROR,function(err:flash.events.SecurityErrorEvent) me.onError(e.url,err.text));
			bytes.addEventListener(flash.events.Event.COMPLETE,function(_) {
				e.callb(me.bytes.data);
				me.start();
			});
		} else {
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