package h3d.tools;

class Collada {

	public var materials : Hash<h3d.material.Material>;
	public var textures : Hash<{ file : String, texture : h3d.material.Texture }>;
	public var objects : Hash<h3d.Object>;

	public function new() {
		materials = new Hash();
		textures = new Hash();
		objects = new Hash();
	}

	function parseColor( s : String ) {
		var a = s.split(" ");
		if( a.length != 4 ) throw "Invalid color '"+s+"'";
		return new h3d.material.Color(
			Std.parseFloat(a[0]),
			Std.parseFloat(a[1]),
			Std.parseFloat(a[2]),
			Std.parseFloat(a[3])
		);
	}

	function parseMatrix( s : String ) {
		var f = ~/[ \r\n\t]+/g.split(StringTools.trim(s));
		if( f.length != 16 ) throw "Invalid matrix '"+s+"'";
		var a = new flash.Vector<Float>(16);
		for( i in 0...16 )
			a[i] = Std.parseFloat(f[i]);
		var m = new h3d.Matrix();
		m._11 = a[0]; m._21 = a[1]; m._31 = a[2]; m._41 = a[3];
		m._12 = a[4]; m._22 = a[5]; m._32 = a[6]; m._42 = a[7];
		m._13 = a[8]; m._23 = a[9]; m._33 = a[10]; m._43 = a[11];
		m._14 = a[12]; m._24 = a[13]; m._34 = a[14]; m._44 = a[15];
		return m;
	}

	function resolve<T>( id : String, h : Hash<T> ) : T {
		var elt = h.get(id);
		if( elt == null )
			throw "Element not found '"+id+"'";
		return elt;
	}

	function buildVertex( vdata : flash.Vector<Float> ) {
		var i = 0;
		var max = Std.int(vdata.length / 3);
		var vl = new flash.Vector();
		for( p in 0...max )
			vl[p] = new h3d.Vector(vdata[i++],vdata[i++],vdata[i++]);
		return vl;
	}

	public function loadXML( doc : Xml ) {
		if( doc.nodeType == Xml.Document )
			doc = doc.firstElement();
		var x = new haxe.xml.Fast(doc);
		// load textures
		for( i in x.node.library_images.nodes.image ) {
			var file = i.node.init_from.innerData;
			textures.set(i.att.id,{ file : file, texture : new h3d.material.Texture() });
		}
		// load material effects
		var matfx = new Hash();
		for( e in x.node.library_effects.nodes.effect ) {
			var profile = e.node.profile_COMMON;
			// prepare <newparam/>
			var params = new Hash();
			for( p in profile.nodes.newparam ) {
				var key = if( p.hasNode.surface )
					p.node.surface.node.init_from.innerData;
				else if( p.hasNode.sampler2D )
					p.node.sampler2D.node.source.innerData;
				else
					null;
				params.set(p.att.sid,key);
			}
			// parse phong
			var tech = profile.node.technique;
			var phong = tech.node.phong;
			var ambient = parseColor(phong.node.ambient.node.color.innerData);
			var dif = phong.node.diffuse;
			var mat = if( dif.hasNode.texture ) {
				var sampler = dif.node.texture.att.texture;
				var img = resolve(resolve(sampler,params),params);
				new h3d.material.BitmapMaterial(ambient,resolve(img,textures).texture);
			} else if( dif.hasNode.color ) {
				var col = parseColor(dif.node.color.innerData);
				new h3d.material.ColorMaterial(ambient,col);
			} else
				throw "Unknown diffuse parameters for effect "+e.att.id;
			matfx.set("#"+e.att.id,mat);
		}
		// load materials
		for( m in x.node.library_materials.nodes.material ) {
			var fxs = m.nodes.instance_effect;
			if( fxs.length != 1 ) throw "Multiple-effect materials are not supported";
			var mat = resolve(fxs.first().att.url,matfx);
			materials.set(m.att.id,mat);
		}
		// load geometries
		var geometries = new Hash();
		for( g in x.node.library_geometries.nodes.geometry ) {
			var mesh = g.node.mesh;
			// sources
			var sources = new Hash();
			for( s in mesh.nodes.source ) {
				var floats = s.node.float_array.innerData.split(" ");
				var a = new flash.Vector<Float>(floats.length,true);
				for( i in 0...floats.length )
					a[i] = Std.parseFloat(floats[i]);
				sources.set("#"+s.att.id,a);
			}
			// vertices
			var vertices = new Hash();
			for( v in mesh.nodes.vertices ) {
				var vdata = resolve(v.node.input.att.source,sources);
				vertices.set("#"+v.att.id,buildVertex(vdata));
			}
			// geometry
			var tri = mesh.nodes.triangles;
			if( tri.length != 1 )
				throw "Mesh '"+g.att.id+"' does not have triangles";
			var triangles = tri.first();
			var voffset = 0, noffset = 0, toffset = 0;
			var vinf = null, ninf = null, tinf = null, stride = 0;
			for( s in triangles.nodes.input ) {
				var off = Std.parseInt(s.att.offset);
				switch( s.att.semantic ) {
				case "VERTEX":
					vinf = resolve(s.att.source,vertices);
					voffset = off;
				case "NORMAL":
					ninf = buildVertex(resolve(s.att.source,sources));
					noffset = off;
				case "TEXCOORD":
					var tdata = resolve(s.att.source,sources);
					var i = 0;
					var max = tdata.length >> 1;
					tinf = new flash.Vector(max,true);
					for( p in 0...max )
						tinf[p] = new h3d.material.UV(tdata[i++],tdata[i++]);
					toffset = off;
				default: // SKIP
				}
				stride++;
			}
			if( vinf == null || ninf == null )
				throw "Mesh '"+g.att.id+"' is either missing vertex or normals";
			// parse indexes
			var indexes = new flash.Vector();
			var idx = triangles.node.p.innerData.split(" ");
			for( i in 0...idx.length )
				indexes[i] = Std.parseInt(idx[i]);
			// build primitive
			var p = new h3d.prim.Primitive();
			p.setDatas(vinf,ninf,tinf);
			p.setMaterial(resolve(triangles.att.material,materials));
			geometries.set("#"+g.att.id,p);
			// fill triangles
			var pos = 0;
			var max = indexes.length;
			var dstride = stride * 2;
			var hasUV = tinf != null;
			while( pos < max ) {
				p.addTriangle(
					indexes[pos + voffset],
					indexes[pos + stride + voffset],
					indexes[pos + dstride + voffset],
					indexes[pos + noffset],
					indexes[pos + stride + noffset],
					indexes[pos + dstride + noffset],
					hasUV ? indexes[pos + toffset] : 0,
					hasUV ? indexes[pos + stride + toffset] : 0,
					hasUV ? indexes[pos + dstride + toffset] : 0
				);
				pos += stride + dstride;
			}
			p.done();
		}
		// load objects
		for( scene in x.node.library_visual_scenes.nodes.visual_scene )
			for( o in scene.nodes.node ) {
				if( !o.hasNode.instance_geometry )
					continue;
				var obj = new h3d.Object();
				objects.set(o.att.name,obj);
				obj.position = parseMatrix(o.node.matrix.innerData);
				obj.addPrimitive( resolve(o.node.instance_geometry.att.url,geometries) );
			}
	}

}