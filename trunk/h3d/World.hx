package h3d;

class World {

	public var camera : h3d.Camera;
	public var display : h3d.Display;
	public var axisSize : Float;
	public var light : h3d.Vector;
	public var stats : h3d.internal.Stats;
	var objects : haxe.FastList<h3d.Object>;
	var vbuf : flash.Vector<Float>;
	var zbuf : flash.Vector<Float>;
	var uvbuf : flash.Vector<Float>;
	var lbuf : flash.Vector<Float>;
	var tbuf : flash.Vector<h3d.internal.Triangle>;

	public function new( display, camera ) {
		this.camera = camera;
		this.display = display;
		this.axisSize = 0;
		this.objects = new haxe.FastList<h3d.Object>();
		stats = new h3d.internal.Stats();
		light = new h3d.Vector(0,0,-1);
		vbuf = new flash.Vector();
		tbuf = new flash.Vector();
		zbuf = new flash.Vector();
		uvbuf = new flash.Vector();
		lbuf = new flash.Vector();
	}

	public function addObject( o ) {
		objects.add(o);
	}

	function zsort( t1 : h3d.internal.Triangle, t2 : h3d.internal.Triangle ) {
		return ( t1.z > t2.z ) ? -1 : 1;
	}

	function quicksort( lo : Int, hi : Int ) : Void {
		var i = lo;
		var j = hi;
		var tbuf = tbuf;
		var p = tbuf[(lo+hi)>>1].z;
		while( i <= j ) {
			while( tbuf[i].z > p ) i++;
			while( tbuf[j].z < p ) j--;
			if( i <= j ) {
				var t = tbuf[i];
				tbuf[i++] = tbuf[j];
				tbuf[j--] = t;
			}
		}
		if( lo < j ) quicksort( lo, j );
		if( i < hi ) quicksort( i, hi );
	}

	public function render() {
		var stats = stats;
		stats.objects = 0;
		stats.primitives = 0;
		stats.triangles = 0;
		stats.drawCalls = 0;
		display.beginDraw();

		// prepare light
		var light = light.copy();
		light.normalize();
		light.scale(-1);

		// render triangles to vbuf and tbuf
		var t = flash.Lib.getTimer();
		var m = new h3d.Matrix();
		var vbuf = this.vbuf;
		var zbuf = this.zbuf;
		var tbuf = this.tbuf;
		var uvbuf = this.uvbuf;
		var lbuf = this.lbuf;
		var vindex = 0, tindex = 0, uvindex = 0, lindex = 0;
		for( o in objects ) {
			// precalculate the absolute projection matrix
			// by taking the object position into account
			m.multiply3x4_4x4(o.position,camera.m);
			for( pinst in o.primitives ) {
				var prim = pinst.p;
				// project all points and store 'w' for later usage
				var p = prim.points;
				while( p != null ) {
					var pw = 1.0 / (m._14 * p.x + m._24 * p.y + m._34 * p.z + m._44);
					p.sx = (m._11 * p.x + m._21 * p.y + m._31 * p.z + m._41) * pw;
					p.sy = (m._12 * p.x + m._22 * p.y + m._32 * p.z + m._42) * pw;
					p.w = pw;
					p = p.next;
				}
				// calculate all triangles-z
				var t = prim.triangles;
				var vbase = vindex >> 1;
				while( t != null ) {
					tbuf[tindex++] = t;
					// the triangle.z is the average of the three vertexes
					t.z = t.v0.p.w + t.v1.p.w + t.v2.p.w;
					t.ibase = vbase;
					t = t.next;
				}
				// emit vertexes into buffer
				var v = prim.vertexes;
				while( v != null ) {
					vbuf[vindex++] = v.p.sx;
					vbuf[vindex++] = v.p.sy;
					uvbuf[uvindex++] = v.u;
					uvbuf[uvindex++] = v.v;
					uvbuf[uvindex++] = v.p.w;
					v = v.next;
				}
				// calculate the light position in terms of object coordinates
				m.inverse3x4(o.position);
				var lx = light.x * m._11 + light.y * m._21 + light.z * m._31;
				var ly = light.x * m._12 + light.y * m._22 + light.z * m._32;
				var lz = light.x * m._13 + light.y * m._23 + light.z * m._33;
				// ... normalize it in case we have a scale in the object matrix
				var len = 1.0 / Math.sqrt(lx * lx + ly * ly + lz * lz);
				lx *= len;
				ly *= len;
				lz *= len;
				// perform shading
				switch( prim.material.shade ) {
				case NoLight:
					// set all normals to maximum luminance
					var n = prim.normals;
					while( n != null ) {
						n.lum = 1.0;
						n = n.next;
					}
				case Flat:
					// calculate face-normal luminance
					t = prim.triangles;
					while( t != null ) {
						var lum = t.n.x * lx + t.n.y * ly + t.n.z * lz;
						t.v0.n.lum = lum;
						t.v1.n.lum = lum;
						t.v2.n.lum = lum;
						t = t.next;
					}
				case Gouraud:
					// calculate normals luminance
					var n = prim.normals;
					while( n != null ) {
						n.lum = n.x * lx + n.y * ly + n.z * lz;
						n = n.next;
					}
				}
				// write luminance to output buffer
				v = prim.vertexes;
				while( v != null ) {
					lbuf[lindex++] = v.n.lum;
					lbuf[lindex++] = 0;
					v = v.next;
				}
				stats.primitives++;
			}
			stats.objects++;
		}
		stats.triangles = tindex;
		var dt = flash.Lib.getTimer() - t;
		stats.transformTime = stats.transformTime * stats.timeLag + (1 - stats.timeLag) * dt;
		t += dt;

		if( tindex > 0 ) {
			// sort triangles
			quicksort(0,tbuf.length - 1);

			dt = flash.Lib.getTimer() - t;
			stats.sortTime = stats.sortTime * stats.timeLag + (1 - stats.timeLag) * dt;
			t += dt;

			// render
			var max = tindex;
			tindex = 0;
			var ibuf = new flash.Vector<Int>();
			var iindex = 0;
			var mat = tbuf[0].material;
			var cull = flash.display.TriangleCulling.POSITIVE;
			while( tindex < max ) {
				var t = tbuf[tindex++];
				if( t.material != mat ) {
					stats.drawCalls++;
					mat.draw(display,ibuf,vbuf,lbuf,uvbuf);
					ibuf = new flash.Vector<Int>();
					iindex = 0;
					mat = t.material;
				}
				ibuf[iindex++] = t.ibase + t.iv0;
				ibuf[iindex++] = t.ibase + t.iv1;
				ibuf[iindex++] = t.ibase + t.iv2;
			}
			stats.drawCalls++;
			mat.draw(display,ibuf,vbuf,lbuf,uvbuf);

			dt = flash.Lib.getTimer() - t;
			stats.materialTime = stats.materialTime * stats.timeLag + (1 - stats.timeLag) * dt;
			t += dt;
		}

		// draw axis
		if( axisSize != 0 ) {
			var pt = new Vector();
			var ghud = display.ghud;

			ghud.lineStyle(1,0xFF0000);
			camera.m.project(camera.target.add(new Vector(axisSize,0,0)),pt);
			ghud.moveTo(0,0);
			ghud.lineTo(pt.x,pt.y);

			ghud.lineStyle(1,0x00FF00);
			camera.m.project(camera.target.add(new Vector(0,axisSize,0)),pt);
			ghud.moveTo(0,0);
			ghud.lineTo(pt.x,pt.y);

			ghud.lineStyle(1,0x0000FF);
			camera.m.project(camera.target.add(new Vector(0,0,axisSize)),pt);
			ghud.moveTo(0,0);
			ghud.lineTo(pt.x,pt.y);

			ghud.lineStyle();
		}

		display.endDraw();

		dt = flash.Lib.getTimer() - t;
		stats.drawTime = stats.drawTime * stats.timeLag + (1 - stats.timeLag) * dt;
		t += dt;
	}

}