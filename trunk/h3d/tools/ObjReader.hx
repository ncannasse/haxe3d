package h3d.tools;

import h3d.Object;
import h3d.prim.Builder;
import h3d.material.Color;
import h3d.material.Material;
import h3d.material.UV;

#if flash9
typedef TypedArray<T> = flash.Vector<T>;
#else
typedef TypedArray<T> = Array<T>;
#end

class ObjReader extends AbstractModelReader {

	var texturesOk : Bool;
	var modelsOk : Bool;

	/** original .obj file **/
	var doc : String;

	var objectList : Array<{obj : Object, materialName : String}>;
	var points : TypedArray<h3d.Vector>;
	var normals : TypedArray<h3d.Vector>;
	var uvs : TypedArray<UV>;

	var builder : Builder;

	public function new(url:String) {
		super(url);

		objectList = new Array();
		points = new TypedArray();
		normals = new TypedArray();
		uvs = new TypedArray();
	}

	public override function parse(data:flash.utils.ByteArray) {
		var me = this;
		data.position = 0;
		doc = data.readUTFBytes(data.length);

		var contLoad = function(url, msg) {
			me.texturesOk = true;
			me.parseModels();
		}
		var i = doc.indexOf("mtllib");
		if(i < 0) {
			contLoad(null, null);
		} else {
			var end = doc.indexOf(".mtl");
			if(end < 0) return;
			i += 7;
			end += 4;
			var mtlUrl = basepath + "/" + doc.substr(i, end - i);
			var loader = new h3d.tools.Loader();
			loader.add(mtlUrl, true, parseMtl);
// 			loader.onError = contLoad;
			loader.start();
		}
	}

	private function parseMtl( data : flash.utils.ByteArray) : Void {
		var me = this;
		var parseFloat = Std.parseFloat;
		var parseInt = Std.parseInt;

		data.position = 0;
		var parts = data.readUTFBytes(data.length).split("\n");
		var name : String = null;
		var filename : String = null;
		var ambient : Color = null;
		var diffuse : Color = null;
		var mode : Int = 0;
		var alpha : Float = 1.0;

		var finalize = function() {
			if(name == null) return;
			var mat : h3d.material.Material;

			if(ambient == null)
				ambient = new Color(0,0,0,1.0);
			if(diffuse == null)
				diffuse = new Color(0,0,0,1.0);
			if(filename != null) {
				me.textures.set(name, { file : filename, texture : new h3d.material.Texture() });
				var sub = new h3d.material.ColorMaterial(ambient, diffuse);
				mat = new h3d.material.BitmapMaterial(sub, me.textures.get(name).texture);
			} else {
				mat = new h3d.material.ColorMaterial(ambient, diffuse);
			}
			me.materials.set(name, mat);
			name = null;
			filename = null;
			ambient = null;
			mode = 0;
			alpha = 1.0;
		}
		var mkColor = function(f : Array<String>) {
			var r = parseFloat(f[1]);
			var g = (f[2] == null) ? r : parseFloat(f[2]);
			var b = (f[3] == null) ? r : parseFloat(f[3]);
			var a = (f[4] == null) ? 1.0 : parseFloat(f[4]);
			return new Color(r,g,b,a);
		}
		for(s in parts) {
			var f = ~/[\s]+/g.split(StringTools.trim(s));
			switch (f[0])
			{
			case "newmtl":
				finalize();
				name = f[1];
			case "Ns": // specular exponent (usually 0-1000)
			case "Ka": // ambient reflectivity r g b
				ambient = mkColor(f);
			case "Kd": // diffuse reflectivity r g b
				diffuse = mkColor(f);
			case "Ks": // specifies the specular reflectivity using RGB values
			case "Ni": // Specifies the optical density for the surface.  This is also known as index of refraction.
						// 1.0 == no bend
			case "d": // Specifies the dissolve for the current material (alpha)
				alpha = parseFloat(f[1]);
			case "illum":
// 				0		Color on and Ambient off
// 				1		Color on and Ambient on
// 				2		Highlight on
// 				3		Reflection on and Ray trace on
// 				4		Transparency: Glass on
//				Several more
				mode = parseInt(f[1]);
			case "map_Kd":
				filename = f[1];
			}
		}
		finalize();
		loadTextures();
		parseModels();
	}

	private function parseModels() {
		var me = this;
		var parseFloat = Std.parseFloat;
		var parseInt = Std.parseInt;
		var parts = doc.split("\n");
		var container : Object = new Object("default");
		objects.set("default", container);
		var hasPrims = false;
		var currentMaterialName = "";
		var switchPrim = false;
		builder = null;

		var closePrimitive = function() {
			if(me.builder != null) {
				var b = me.endMesh();
				if(b != null) {
					container.addPrimitive(b);
					hasPrims = true;
					return true;
				}
			}
			return false;
		}

		var mkVector = function(f) {
			return new h3d.Vector(parseFloat(f[1]), parseFloat(f[2]), parseFloat(f[3]));
		}

		for(i in 0...parts.length) {
			var s = parts[i];
			var f = ~/[\s]+/g.split(StringTools.trim(s));
			switch(f[0]) {
			case "mtllib": // material library, handled above
			case "v": // vertices
				switchPrim = true;
				points.push( mkVector(f) );
			case "vt": // texture vertices
				switchPrim = true;
				uvs.push(new UV(parseFloat(f[1]), (f[2] == null) ? 0.0 : parseFloat(f[2])));
			case "vn": // vertex normals i, j, k
				switchPrim = true;
				normals.push( mkVector(f) );
			case "g": // group name
				if(f.length != 2)
					throw "Not able to parse multiple groupnames";
				var groupname = (f[1] == null) ? "default" : f[1];
				closePrimitive();
				if(!hasPrims || container.name == groupname) {
					container.name = groupname;
				} else { // new group
					container = new Object(groupname);
					if(objects.exists(groupname))
						throw "Object named " + groupname + " already exists";
					objects.set(groupname, container);
				}
			case "s": // smoothing group
				switchPrim = true;
			case "usemtl": // material name
				switchPrim = true;
				currentMaterialName = f[1];
			case "f": // face f -4 -3 -2 -1 or f 1 2 3 4 or f v1/[vt1]/[vn1] v2/vt2/vn2   v3/vt3/vn3
				if((switchPrim && closePrimitive()) || builder == null)
					startMesh(currentMaterialName);
				switchPrim = false;
				var getIndex = function(s:String, a, ?noNull = true) : Null<Int> {
					var v = parseInt(s);
					if(v == null) return (noNull) ? 0 : null;
					return if(v < 0) a.length + v;
					else v - 1;
				}
				var spec0 = f[1].split("/");
				var spec1 = f[2].split("/");
				var spec2 = f[3].split("/");
				var spec3 = (f[4] == null) ? [] : f[4].split("/");
				var v0 = getIndex(spec0[0], points, true);
				var v1 = getIndex(spec1[0], points, true);
				var v2 = getIndex(spec2[0], points, true);
				var v3 = getIndex(spec3[0], points, true);
				var uv0 = getIndex(spec0[1], uvs, false);
				var uv1 = getIndex(spec1[1], uvs, false);
				var uv2 = getIndex(spec2[1], uvs, false);
				var uv3 = getIndex(spec3[1], uvs, false);
				var n0 = getIndex(spec0[2], normals, false);
				var n1 = getIndex(spec1[2], normals, false);
				var n2 = getIndex(spec2[2], normals, false);
				var n3 = getIndex(spec3[2], normals, false);

				var added = -1;
				if(n0 == null || n1 == null || n2 == null)
					added = builder.createNormal(v0, v1, v2);
				n0 = (n0 == null) ? added : n0;
				n1 = (n1 == null) ? added : n1;
				n3 = (n3 == null) ? added : n3;

				var defUv = function(u : Null<Int>, i:Int) : Int {
					return (u == null) ? i : u;
				}
				if(f[4] == null) { //f v1/[vt1]/[vn1] v2/vt2/vn2 v3/vt3/vn3
					builder.addTriangle(v0,v1,v2,n0,n1,n2,defUv(uv0,0),defUv(uv1,1),defUv(uv2,2));
				} else { // f 1 2 3 4
					if(n3 == null)
						n3 = builder.createNormal(v1,v2,v3);
					builder.addTriangle(v0,v1,v3,n0,n1,n3,defUv(uv0,0),defUv(uv1,1),defUv(uv3,2));
					builder.addTriangle(v1,v2,v3,n1,n2,n3,defUv(uv1,0),defUv(uv2,1),defUv(uv3,2));
				}
			}
		}
		closePrimitive();
		modelsOk = true;
		completeTest();
	}

	override function onTexturesLoaded() {
		texturesOk = true;
		completeTest();
	}

	private function completeTest() {
		if(texturesOk && modelsOk)
			onComplete();
	}

	private function startMesh(materialName : String) : Void {
		if(uvs.length == 0)
			uvs.push(new UV(0.0, 1.0));
		if(uvs.length == 1)
			uvs.push(new UV(0.5, 0.0));
		if(uvs.length == 2)
			uvs.push(new UV(1.0, 1.0));

		builder = new h3d.prim.Builder(materials.get(materialName));
		builder.init(points,normals,uvs);
	}

	private function endMesh() : Builder {
		if(builder != null) {
			builder.done();
			var b = builder;
			builder = null;
			return b;
		}
		return null;
	}
}


