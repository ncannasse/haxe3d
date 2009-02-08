package h3d;

class World {

	public var camera : h3d.Camera;
	public var display(default,setDisplay) : h3d.Display;
	public var axisSize : Float;
	public var stats : h3d.internal.Stats;
	public var fog : h3d.material.Color;
	var plights : haxe.FastList<h3d.internal.LightInst>;
	var dlights : haxe.FastList<h3d.internal.LightInst>;
	var objects : haxe.FastList<h3d.Object>;
	var r : h3d.internal.RenderInfos;
	var tmp : h3d.Vector;

	public function new( display, camera ) {
		axisSize = 0;
		tmp = new h3d.Vector();
		objects = new haxe.FastList<h3d.Object>();
		plights = new haxe.FastList<h3d.internal.LightInst>();
		dlights = new haxe.FastList<h3d.internal.LightInst>();
		stats = new h3d.internal.Stats();
		r = new h3d.internal.RenderInfos(display);
		this.camera = camera;
		this.display = display;
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

	function setDisplay(d) {
		this.display = d;
		r.display = d;
		return d;
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
		var m = new h3d.Matrix(), tmp = new h3d.Matrix();
		r.triangles = new flash.Vector();
		var tbuf = r.triangles;
		var tindex = 0;
		var wmin = camera.wmin, wmax = camera.wmax;
		var fogLum = 0.;
		if( fog != null )
			fogLum = (fog.r + fog.g + fog.b) / 3;
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
				while( t != null ) {
					var p0 = t.v0.p;
					var p1 = t.v1.p;
					var p2 = t.v2.p;
					// backface culling
					if( (p2.sx - p1.sx) * (p0.sy - p1.sy) - (p0.sx - p1.sx) * (p2.sy - p1.sy) < 0 ) {
						// camera z-clipping
						if( p0.w > wmin && p0.w < wmax && p1.w > wmin && p1.w < wmax && p2.w > wmin && p2.w < wmax ) {
							tbuf[tindex++] = t;
							// we will sort triangles depending of this sum (same as average)
							t.z = t.v0.p.w + t.v1.p.w + t.v2.p.w;
						}
					}
					t = t.next;
				}
				// perform shading
				switch( prim.material.shade ) {
				case NoLight:
					// set all luminance to maximum value
					var v = prim.vertexes;
					while( v != null ) {
						v.lum = 1.0;
						v = v.next;
					}
				case Flat:
					updateLights(tmp,o.position);
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
							if( lum > 0 ) {
								t.v0.n.lum += lum;
								t.v1.n.lum += lum;
								t.v2.n.lum += lum;
							}
							t = t.next;
						}
					}
					// use normal luminance for each vertex
					var v = prim.vertexes;
					while( v != null ) {
						v.lum = v.n.lum;
						v = v.next;
					}
				case Gouraud:
					updateLights(tmp,o.position);
					// calculate normals luminance
					var n = prim.normals;
					while( n != null ) {
						n.lum = 0;
						n = n.next;
					}
					for( l in dlights ) {
						n = prim.normals;
						while( n != null ) {
							var lum = n.x * l.lx + n.y * l.ly + n.z * l.lz;
							if( lum > 0 )
								n.lum += lum;
							n = n.next;
						}
					}
					// use normal luminance
					var v = prim.vertexes;
					while( v != null ) {
						v.lum = v.n.lum;
						v = v.next;
					}
					// apply fog
					if( prim.material.useFog && fog != null ) {
						v = prim.vertexes;
						while( v != null ) {
							v.lum -= v.p.w * fogLum;
							v = v.next;
						}
					}
					// add point-lights color
					if( prim.material.pointLights ) {
						for( l in plights ) {
							v = prim.vertexes;
							while( v != null ) {
								var dx = l.lx - v.p.x;
								var dy = l.ly - v.p.y;
								var dz = l.lz - v.p.z;
								var lum = v.n.x * dx + v.n.y * dy + v.n.z * dz;
								if( lum > 0 )
									v.lum += lum * l.l.power / (dx * dx + dy * dy + dz * dz);
								v = v.next;
							}
						}
					}
				case RGBLight:
					updateLights(tmp,o.position);
					// calculate normals colors
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
							if( lum > 0 ) {
								n.r += lum * l.r;
								n.g += lum * l.g;
								n.b += lum * l.b;
							}
							n = n.next;
						}
					}
					// use normal colors
					var v = prim.vertexes;
					while( v != null ) {
						v.r = v.n.r;
						v.g = v.n.g;
						v.b = v.n.b;
						v = v.next;
					}
					// apply fog color
					if( prim.material.useFog && fog != null ) {
						v = prim.vertexes;
						while( v != null ) {
							v.r -= v.p.w * fog.r;
							v.g -= v.p.w * fog.g;
							v.b -= v.p.w * fog.b;
							v = v.next;
						}
					}
					// add point-lights color
					if( prim.material.pointLights ) {
						for( l in plights ) {
							v = prim.vertexes;
							while( v != null ) {
								var dx = l.lx - v.p.x;
								var dy = l.ly - v.p.y;
								var dz = l.lz - v.p.z;
								var lum = v.n.x * dx + v.n.y * dy + v.n.z * dz;
								if( lum > 0 ) {
									lum /= dx * dx + dy * dy + dz * dz;
									v.r += lum * l.r;
									v.g += lum * l.g;
									v.b += lum * l.b;
								}
								v = v.next;
							}
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

		if( tindex == 0 )
			return;

		// sort triangles
		quicksort(0,tbuf.length - 1);
		dt = flash.Lib.getTimer() - t;
		stats.sortTime = stats.sortTime * stats.timeLag + (1 - stats.timeLag) * dt;
		t += dt;

		// render triangles groups
		var max = tindex;
		tindex = 0;
		var mat = tbuf[tindex].material;
		var vertexes = new flash.Vector(), vindex = 0;
		var uvcoords = new flash.Vector(), uvindex = 0;
		var lightning = new flash.Vector(), lindex = 0;
		var colors = null, cindex = 0;
		switch( mat.shade ) { case RGBLight: colors = new flash.Vector(); default : };
		while( tindex < max ) {
			var t = tbuf[tindex++];
			if( t.material != mat ) {
				stats.drawCalls++;
				r.vertexes = vertexes;
				r.uvcoords = uvcoords;
				r.lightning = lightning;
				r.colors = colors;
				mat.draw(r);
				vertexes = new flash.Vector(); vindex = 0;
				uvcoords = new flash.Vector(); uvindex = 0;
				lightning = new flash.Vector(); lindex = 0;
				colors = null; cindex = 0;
				switch( mat.shade ) { case RGBLight: colors = new flash.Vector(); default : };
				mat = t.material;
			}
			var v0 = t.v0, v1 = t.v1, v2 = t.v2;
			var p0 = v0.p, p1 = v1.p, p2 = v2.p;
			vertexes[vindex++] = p0.sx;
			vertexes[vindex++] = p0.sy;
			vertexes[vindex++] = p1.sx;
			vertexes[vindex++] = p1.sy;
			vertexes[vindex++] = p2.sx;
			vertexes[vindex++] = p2.sy;
			uvcoords[uvindex++] = v0.u;
			uvcoords[uvindex++] = v0.v;
			uvcoords[uvindex++] = p0.w;
			uvcoords[uvindex++] = v1.u;
			uvcoords[uvindex++] = v1.v;
			uvcoords[uvindex++] = p1.w;
			uvcoords[uvindex++] = v2.u;
			uvcoords[uvindex++] = v2.v;
			uvcoords[uvindex++] = p2.w;
			if( colors == null ) {
				lightning[lindex++] = v0.lum;
				lightning[lindex++] = 0.;
				lightning[lindex++] = p0.w;
				lightning[lindex++] = v1.lum;
				lightning[lindex++] = 0.;
				lightning[lindex++] = p1.w;
				lightning[lindex++] = v2.lum;
				lightning[lindex++] = 0.;
				lightning[lindex++] = p2.w;
			} else {
				lightning[lindex++] = v0.r + v0.cr;
				lightning[lindex++] = 0.;
				lightning[lindex++] = p0.w;
				lightning[lindex++] = v1.r + v1.cr;
				lightning[lindex++] = 0.;
				lightning[lindex++] = p1.w;
				lightning[lindex++] = v2.r + v2.cr;
				lightning[lindex++] = 0.;
				lightning[lindex++] = p2.w;
				colors[cindex++] = v0.g + v0.cg;
				colors[cindex++] = v0.b + v0.cb;
				colors[cindex++] = p0.w;
				colors[cindex++] = v1.g + v1.cg;
				colors[cindex++] = v1.b + v1.cb;
				colors[cindex++] = p1.w;
				colors[cindex++] = v2.g + v2.cg;
				colors[cindex++] = v2.b + v2.cb;
				colors[cindex++] = p2.w;
			}
		}
		// last draw
		stats.drawCalls++;
		r.vertexes = vertexes;
		r.uvcoords = uvcoords;
		r.lightning = lightning;
		r.colors = colors;
		mat.draw(r);

		// update statistics
		dt = flash.Lib.getTimer() - t;
		stats.materialTime = stats.materialTime * stats.timeLag + (1 - stats.timeLag) * dt;
		t += dt;
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
		var g = display.getContext(flash.display.BlendMode.NORMAL);
		var w = camera.m.project(p,tmp);
		if( w < camera.wmin || w > camera.wmax )
			return;
		g.beginFill(color.argb,color.a);
		g.drawCircle(tmp.x,tmp.y,size);
	}

	public function drawLine( p : h3d.Vector, p2 : h3d.Vector, color : h3d.material.Color, ?size = 1.0 ) {
		var w = camera.m.project(p,tmp);
		if( w < camera.wmin || w > camera.wmax )
			return;
		var g = display.getContext(flash.display.BlendMode.NORMAL);
		g.moveTo(tmp.x,tmp.y);
		w = camera.m.project(p2,tmp);
		if( w < camera.wmin || w > camera.wmax )
			return;
		g.endFill();
		g.lineStyle(size,color.argb,color.a);
		g.lineTo(tmp.x,tmp.y);
		g.lineStyle();
	}

}