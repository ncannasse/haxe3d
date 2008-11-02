package h3d;

class World {

	public var camera : h3d.Camera;
	public var display : h3d.Display;
	public var axisSize : Float;
	var objects : haxe.FastList<h3d.Object>;
	var vbuf : flash.Vector<Float>;
	var zbuf : flash.Vector<Float>;
	var uvbuf : flash.Vector<Float>;
	var tbuf : flash.Vector<h3d.internal.ZTriangle>;

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

	function zsort( t1 : h3d.internal.ZTriangle, t2 : h3d.internal.ZTriangle ) {
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
			for( p in o.primitives ) {
				var zindex = 0;
				var vbase = vindex >> 1;
				var v = p.p.vertexes;
				while( v != null ) {
					var px = m._11 * v.x + m._21 * v.y + m._31 * v.z + m._41;
					var py = m._12 * v.x + m._22 * v.y + m._32 * v.z + m._42;
					//var pz = m._13 * v.x + m._23 * v.y + m._33 * v.z + m._43;
					var pw = 1.0 / (m._14 * v.x + m._24 * v.y + m._34 * v.z + m._44);
					zbuf[zindex++] = pw;
					vbuf[vindex++] = px * pw;
					vbuf[vindex++] = py * pw;
					uvbuf[uvindex++] = v.u;
					uvbuf[uvindex++] = v.v;
					uvbuf[uvindex++] = pw;
					v = v.next;
				}
				var t = p.triangles;
				while( t != null ) {
					// the triangle.z is the average of the three vertex
					t.z = zbuf[t.v0] + zbuf[t.v1] + zbuf[t.v2];
					t.base = vbase;
					tbuf[tindex++] = t;
					t = t.next;
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
			var t0 = tbuf[0];
			var old = t0.mat;
			var oldMat = t0.material;
			var cull = flash.display.TriangleCulling.POSITIVE;
			while( tindex < max ) {
				var t = tbuf[tindex++];
				if( t.mat != old ) {
					oldMat.setup(display,false);
					gcolor.drawTriangles(vbuf,ibuf,null,cull);
					gcolor.endFill();
					oldMat.setup(display,true);
					gbitmap.drawTriangles(vbuf,ibuf,uvbuf,cull);
					gbitmap.endFill();
					ibuf = new flash.Vector<Int>();
					iindex = 0;
					old = t.mat;
					oldMat = t.material;
				}
				ibuf[iindex++] = t.base + t.v0;
				ibuf[iindex++] = t.base + t.v1;
				ibuf[iindex++] = t.base + t.v2;
			}
			oldMat.setup(display,false);
			gcolor.drawTriangles(vbuf,ibuf,null,cull);
			gcolor.endFill();
			oldMat.setup(display,false);
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