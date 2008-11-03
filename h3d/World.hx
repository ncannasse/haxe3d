package h3d;

class World {

	public var camera : h3d.Camera;
	public var display : h3d.Display;
	public var axisSize : Float;
	var objects : haxe.FastList<h3d.Object>;
	var vbuf : flash.Vector<Float>;
	var zbuf : flash.Vector<Float>;
	var uvbuf : flash.Vector<Float>;
	var tbuf : flash.Vector<h3d.internal.Triangle>;

	public function new( display, camera ) {
		this.camera = camera;
		this.display = display;
		this.axisSize = 0;
		this.objects = new haxe.FastList<h3d.Object>();
		vbuf = new flash.Vector();
		tbuf = new flash.Vector();
		zbuf = new flash.Vector();
		uvbuf = new flash.Vector();
	}

	public function addObject( o ) {
		objects.add(o);
	}

	function zsort( t1 : h3d.internal.Triangle, t2 : h3d.internal.Triangle ) {
		return ( t1.z > t2.z ) ? -1 : 1;
	}

	public function render() {
		var display = display;
		display.beginDraw();
		var gbitmap = display.gbitmap;
		var gcolor = display.gcolor;
		var ghud = display.ghud;

		// render triangles to vbuf and tbuf
		var m = new h3d.Matrix();
		var vbuf = this.vbuf;
		var zbuf = this.zbuf;
		var tbuf = this.tbuf;
		var uvbuf = this.uvbuf;
		var vindex = 0, tindex = 0, uvindex = 0;
		for( o in objects ) {
			m.multiply(o.position,camera.m);
			for( pinst in o.primitives ) {
				var prim = pinst.p;
				// transform all points
				var p = prim.points;
				while( p != null ) {
					var pw = 1.0 / (m._14 * p.x + m._24 * p.y + m._34 * p.z + m._44);
					p.sx = (m._11 * p.x + m._21 * p.y + m._31 * p.z + m._41) * pw;
					p.sy = (m._12 * p.x + m._22 * p.y + m._32 * p.z + m._42) * pw;
					p.w = pw;
					p = p.next;
				}
				// TODO : tranform normals
				// TODO : lightning
				// calculate all triangles-z
				var t = prim.triangles;
				var vbase = vindex >> 1;
				while( t != null ) {
					tbuf[tindex++] = t;
					// the triangle.z is the average of the three vertex
					t.z = t.v0.p.w + t.v1.p.w + t.v2.p.w;
					t.ibase = vbase;
					t = t.next;
				}
				// emit vertexes
				var v = prim.vertexes;
				while( v != null ) {
					vbuf[vindex++] = v.p.sx;
					vbuf[vindex++] = v.p.sy;
					uvbuf[uvindex++] = v.u;
					uvbuf[uvindex++] = v.v;
					uvbuf[uvindex++] = v.p.w;
					v = v.next;
				}
			}
		}

		if( tindex > 0 ) {
			// sort triangles
			tbuf.sort(zsort);

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
					mat.setup(display,false);
					gcolor.drawTriangles(vbuf,ibuf,null,cull);
					gcolor.endFill();
					mat.setup(display,true);
					gbitmap.drawTriangles(vbuf,ibuf,uvbuf,cull);
					gbitmap.endFill();
					ibuf = new flash.Vector<Int>();
					iindex = 0;
					mat = t.material;
				}
				ibuf[iindex++] = t.ibase + t.iv0;
				ibuf[iindex++] = t.ibase + t.iv1;
				ibuf[iindex++] = t.ibase + t.iv2;
			}
			mat.setup(display,false);
			gcolor.drawTriangles(vbuf,ibuf,null,cull);
			gcolor.endFill();
			mat.setup(display,true);
			gbitmap.drawTriangles(vbuf,ibuf,null,cull);
			gbitmap.endFill();
		}

		// draw axis
		if( axisSize != 0 ) {
			var pt = new Vector();

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
	}

}