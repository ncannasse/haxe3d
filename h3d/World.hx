package h3d;

class World {

	public var camera : h3d.Camera;
	public var display : h3d.Display;
	public var axisSize : Float;
	public var stats : h3d.internal.Stats;
	var plights : haxe.FastList<h3d.internal.LightInst>;
	var dlights : haxe.FastList<h3d.internal.LightInst>;
	var objects : haxe.FastList<h3d.Object>;
	var r : h3d.internal.RenderInfos;

	public function new( display, camera ) {
		this.camera = camera;
		this.display = display;
		axisSize = 0;
		objects = new haxe.FastList<h3d.Object>();
		plights = new haxe.FastList<h3d.internal.LightInst>();
		dlights = new haxe.FastList<h3d.internal.LightInst>();
		stats = new h3d.internal.Stats();
		r = new h3d.internal.RenderInfos(display);
	}

	public function addObject( o ) {
		objects.add(o);
	}

	public function addLight( l : h3d.material.Light ) {
		(if( l.directional ) dlights else plights).add(new h3d.internal.LightInst(l));
	}

	public function removeObject( o ) {
		return objects.remove(o);
	}

	public function removeLight( l : h3d.material.Light ) {
		var lights = l.directional?dlights:plights;
		for( l2 in lights )
			if( l2.l == l )
				return lights.remove(l2);
		return false;
	}

	public function listObjects() {
		return objects.iterator();
	}

	function quicksort( lo : Int, hi : Int ) : Void {
		var i = lo;
		var j = hi;
		var tbuf = r.triangles;
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

	function updateLights( m : Matrix, pos : Matrix ) {
		m.inverse3x4(pos);
		var Math = Math;
		for( l in dlights ) {
			// calculate the light position in terms of object coordinates
			var p = l.pos;
			var lx = p.x * m._11 + p.y * m._21 + p.z * m._31;
			var ly = p.x * m._12 + p.y * m._22 + p.z * m._32;
			var lz = p.x * m._13 + p.y * m._23 + p.z * m._33;
			// ... normalize it in case we have a scale in the object matrix
			var k = l.l.power / Math.sqrt(lx * lx + ly * ly + lz * lz);
			l.lx = lx * k;
			l.ly = ly * k;
			l.lz = lz * k;
		}
		for( l in plights ) {
			// calculate the light position in terms of object coordinates
			var p = l.pos;
			l.lx = p.x * m._11 + p.y * m._21 + p.z * m._31;
			l.ly = p.x * m._12 + p.y * m._22 + p.z * m._32;
			l.lz = p.x * m._13 + p.y * m._23 + p.z * m._33;
		}
	}

	public function render() {
		beginRender();
		renderObjects();
		finishRender();
	}

	public function beginRender() {
		stats.objects = 0;
		stats.primitives = 0;
		stats.triangles = 0;
		stats.drawCalls = 0;
		display.beginDraw();
		// prepare lights
		for( l in dlights ) {
			var p = l.pos;
			p.x = -l.l.position.x;
			p.y = -l.l.position.y;
			p.z = -l.l.position.z;
			l.r = l.l.color.r;
			l.g = l.l.color.g;
			l.b = l.l.color.b;
		}
		for( l in plights ) {
			var p = l.pos;
			p.x = l.l.position.x;
			p.y = l.l.position.y;
			p.z = l.l.position.z;
			l.r = l.l.color.r * l.l.power;
			l.g = l.l.color.g * l.l.power;
			l.b = l.l.color.b * l.l.power;
		}
	}

	public function renderObjects() {
		var stats = stats;

		// render triangles to vbuf and tbuf
		var t = flash.Lib.getTimer();
		var m = new h3d.Matrix();
		var vbuf = r.vertexes;
		var zbuf = r.zcoords;
		var tbuf = r.triangles;
		var uvbuf = r.uvcoords;
		var lbuf = r.lightning;
		var cbuf = r.colors;
		var vindex = 0, tindex = 0, uvindex = 0, lindex = 0, cindex = 0;
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
				// perform shading
				switch( prim.material.shade ) {
				case NoLight:
					// set all luminance to maximum value
					v = prim.vertexes;
					while( v != null ) {
						lbuf[lindex++] = 1.0;
						lbuf[lindex++] = 0;
						lbuf[lindex++] = 0;
						v = v.next;
					}
				case Flat:
					updateLights(m,o.position);
					// reset normals luminance
					var n = prim.normals;
					while( n != null ) {
						n.lum = 0;
						n = n.next;
					}
					// calculate face-normal luminance
					for( l in dlights ) {
						t = prim.triangles;
						while( t != null ) {
							var lum = t.n.x * l.lx + t.n.y * l.ly + t.n.z * l.lz;
							t.v0.n.lum += lum;
							t.v1.n.lum += lum;
							t.v2.n.lum += lum;
							t = t.next;
						}
					}
					// write luminance to output buffer
					v = prim.vertexes;
					while( v != null ) {
						lbuf[lindex++] = v.n.lum;
						lbuf[lindex++] = 0;
						lbuf[lindex++] = v.p.w;
						v = v.next;
					}
				case Gouraud:
					updateLights(m,o.position);
					// calculate normals luminance
					var n = prim.normals;
					while( n != null ) {
						n.lum = 0;
						n = n.next;
					}
					for( l in dlights ) {
						n = prim.normals;
						while( n != null ) {
							n.lum += n.x * l.lx + n.y * l.ly + n.z * l.lz;
							n = n.next;
						}
					}
					// add point-lights color
					if( prim.material.pointLights ) {
						v = prim.vertexes;
						while( v != null ) {
							v.lum = v.n.lum;
							v = v.next;
						}
						for( l in plights ) {
							v = prim.vertexes;
							while( v != null ) {
								var dx = l.lx - v.p.x;
								var dy = l.ly - v.p.y;
								var dz = l.lz - v.p.z;
								v.lum += (v.n.x * dx + v.n.y * dy + v.n.z * dz) * l.l.power / (dx * dx + dy * dy + dz * dz);
								v = v.next;
							}
						}
						// write luminance to output buffer
						v = prim.vertexes;
						while( v != null ) {
							lbuf[lindex++] = v.lum;
							lbuf[lindex++] = 0;
							lbuf[lindex++] = v.p.w;
							v = v.next;
						}
					} else {
						// write luminance to output buffer
						v = prim.vertexes;
						while( v != null ) {
							lbuf[lindex++] = v.n.lum;
							lbuf[lindex++] = 0;
							lbuf[lindex++] = v.p.w;
							v = v.next;
						}
					}
				case VertexColor:
					updateLights(m,o.position);
					// calculate normals luminance
					var n = prim.normals;
					while( n != null ) {
						n.r = 0;
						n.g = 0;
						n.b = 0;
						n = n.next;
					}
					for( l in dlights ) {
						n = prim.normals;
						while( n != null ) {
							var lum = n.x * l.lx + n.y * l.ly + n.z * l.lz;
							n.r += lum * l.r;
							n.g += lum * l.g;
							n.b += lum * l.b;
							n = n.next;
						}
					}
					// pad the color buffer with zeroes
					while( cindex < lindex ) {
						cbuf[cindex++] = 0;
						cbuf[cindex++] = 0;
						cbuf[cindex++] = 0;
					}
					// add point-lights color
					if( prim.material.pointLights ) {
						v = prim.vertexes;
						while( v != null ) {
							v.r = v.n.r;
							v.g = v.n.g;
							v.b = v.n.b;
							v = v.next;
						}
						for( l in plights ) {
							v = prim.vertexes;
							while( v != null ) {
								var dx = l.lx - v.p.x;
								var dy = l.ly - v.p.y;
								var dz = l.lz - v.p.z;
								var lum = (v.n.x * dx + v.n.y * dy + v.n.z * dz) / (dx * dx + dy * dy + dz * dz);
								v.r += lum * l.r;
								v.g += lum * l.g;
								v.b += lum * l.b;
								v = v.next;
							}
						}
						// write luminance and color to output buffer
						v = prim.vertexes;
						while( v != null ) {
							lbuf[lindex++] = v.r + v.cr;
							lbuf[lindex++] = 0;
							lbuf[lindex++] = v.p.w;
							cbuf[cindex++] = v.g + v.cg;
							cbuf[cindex++] = v.b + v.cb;
							cbuf[cindex++] = v.p.w;
							v = v.next;
						}
					} else {
						// write luminance and color to output buffer
						v = prim.vertexes;
						while( v != null ) {
							lbuf[lindex++] = v.n.r + v.cr;
							lbuf[lindex++] = 0;
							lbuf[lindex++] = v.p.w;
							cbuf[cindex++] = v.n.g + v.cg;
							cbuf[cindex++] = v.n.b + v.cb;
							cbuf[cindex++] = v.p.w;
							v = v.next;
						}
					}
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
			while( tindex < max ) {
				var t = tbuf[tindex++];
				if( t.material != mat ) {
					stats.drawCalls++;
					r.indexes = ibuf;
					mat.draw(r);
					ibuf = new flash.Vector<Int>();
					iindex = 0;
					mat = t.material;
				}
				ibuf[iindex++] = t.ibase + t.iv0;
				ibuf[iindex++] = t.ibase + t.iv1;
				ibuf[iindex++] = t.ibase + t.iv2;
			}
			stats.drawCalls++;
			r.indexes = ibuf;
			mat.draw(r);

			dt = flash.Lib.getTimer() - t;
			stats.materialTime = stats.materialTime * stats.timeLag + (1 - stats.timeLag) * dt;
			t += dt;
		}
	}

	public function finishRender() {
		// draw axis
		if( axisSize != 0 ) {
			var p0 = new Vector();
			drawLine(p0,new Vector(axisSize,0,0),new h3d.material.Color(1,0,0));
			drawLine(p0,new Vector(0,axisSize,0),new h3d.material.Color(0,1,0));
			drawLine(p0,new Vector(0,0,axisSize),new h3d.material.Color(0,0,1));
		}
		var t = flash.Lib.getTimer();
		display.endDraw();
		var dt = flash.Lib.getTimer() - t;
		stats.drawTime = stats.drawTime * stats.timeLag + (1 - stats.timeLag) * dt;
		stats.shapeCount = display.shapeCount();
	}

	public function drawPoint( p : h3d.Vector, color : h3d.material.Color, ?size = 1.0 ) {
		var pt = new Vector();
		var g = display.getContext(flash.display.BlendMode.NORMAL);
		pt.x = camera.target.x + p.x;
		pt.y = camera.target.y + p.y;
		pt.z = camera.target.x + p.z;
		camera.m.project(pt,pt);
		g.beginFill(color.argb,color.a);
		g.drawCircle(pt.x,pt.y,size);
		g.endFill();
	}

	public function drawLine( p : h3d.Vector, p2 : h3d.Vector, color : h3d.material.Color, ?size = 1.0 ) {
		var pt = new Vector();
		var g = display.getContext(flash.display.BlendMode.NORMAL);
		g.lineStyle(size,color.argb,color.a);
		pt.x = camera.target.x + p.x;
		pt.y = camera.target.y + p.y;
		pt.z = camera.target.x + p.z;
		camera.m.project(pt,pt);
		g.moveTo(pt.x,pt.y);
		pt.x = camera.target.x + p2.x;
		pt.y = camera.target.y + p2.y;
		pt.z = camera.target.x + p2.z;
		camera.m.project(pt,pt);
		g.lineTo(pt.x,pt.y);
		g.lineStyle();
	}

}