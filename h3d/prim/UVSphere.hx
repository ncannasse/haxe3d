package h3d.prim;

import h3d.Vector;
import h3d.material.Material;
import h3d.material.UV;

class UVSphere extends Primitive {
	public var radius(default, null) : Float;
	public var hradius(default, null) : Float;
	public var slices(default, null) : Int;
	public var rings(default, null) : Int;
	public var invertednormals(default, null) : Bool;

	public function new(material : Material, radius : Float, hradius : Float, slices : Int, rings : Int, invertednormals = false) {
		super(material);
		this.radius  = radius;
		this.hradius = hradius;
		this.slices  = slices < 3 ? 3 : slices;
		this.rings   = rings < 1  ? 1 : rings;
		this.invertednormals = invertednormals;
		init();
	}

	function init() {
		var points   = new flash.Vector();
		var normals  = new flash.Vector();
		var vindexes = new flash.Vector();
		var tcoords  = new flash.Vector();
		var n = invertednormals ? -1 : 1;

		var unitw = 1/slices;
		var unith = 1/(1+rings);

		var tlevels = new flash.Vector(rings, true);
		var levels  = new flash.Vector(rings, true);
		var angle   = 2*Math.PI/slices;
		var alpha   = Math.PI/(rings+1);
		for(ring in 0...rings) {
			var level  = levels[ring]  = new flash.Vector(slices, true);
			var tlevel = tlevels[ring] = new flash.Vector(slices+1, true);

			var a = alpha*(ring+1);
			var z = -Math.cos(a);
			var r = Math.sin(a)*radius;

			for(slice in 0...slices) {
				var x = Math.cos(angle*slice);
				var y = Math.sin(angle*slice);
				normals.push(new Vector(x*n, y*n, z*n));
				points.push (new Vector(x*r, y*r, z*hradius));
				level[slice] = points.length-1;
				tcoords.push(new UV(unitw*slice, 1-ring*unith));
				tlevel[slice] = tcoords.length-1;
			}
			tcoords.push(new UV(1, 1-ring*unith));
			tlevel[slices] = tcoords.length-1;
		}

		// top
		normals.push(new Vector(0, 0, n));
		points.push (new Vector(0, 0, hradius));
		var topvertex = points.length-1;
		var tleveltop = new flash.Vector(slices, true);
		for(slice in 0...slices) {
			tcoords.push(new UV(unitw*slice+unitw/2, 0));
			tleveltop[slice] = tcoords.length-1;
		}

		// bottom
		normals.push(new Vector(0, 0, -n));
		points.push (new Vector(0, 0, -hradius));
		var bottomvertex = points.length-1;
		var tlevelbottom = new flash.Vector(slices, true);
		for(slice in 0...slices) {
			tcoords.push(new UV(unitw*slice+unitw/2, 1));
			tlevelbottom[slice] = tcoords.length-1;
		}

		var tindexes = new flash.Vector();
		var builder = new Builder(material);
		builder.init(points, normals, tcoords);

		var n1 = invertednormals ? 1 : 0;
		var n2 = invertednormals ? 0 : 1;
		var level = levels[0];
		for(i in 0...slices) {
			var index1 = i+n1 == slices ? 0 : i+n1;
			var index2 = i+n2 == slices ? 0 : i+n2;
			builder.addTriangle(
				bottomvertex,
				level[index2],
				level[index1],
				bottomvertex,
				level[index2],
				level[index1],
				tlevelbottom[i],
				tlevels[0][i],
				tlevels[0][i+1]);
		}

		for(i in 0...levels.length-1) {
			var levelbottom = levels[i];
			var leveltop = levels[i+1];
			var tlevelbottom = tlevels[i];
			var tleveltop = tlevels[i+1];
			for(j in 0...slices) {
				var index1 = j+n1 == slices ? 0 : j+n1;
				var index2 = j+n2 == slices ? 0 : j+n2;
				builder.addQuad(
					leveltop[index1],
					levelbottom[index1],
					levelbottom[index2],
					leveltop[index2],
					leveltop[index1],
					levelbottom[index1],
					levelbottom[index2],
					leveltop[index2],
					tleveltop[j+n1],
					tlevelbottom[j+n1],
					tlevelbottom[j+n2],
					tleveltop[j+n2]);
			}
		}

		level = levels[levels.length-1];
		for(i in 0...slices) {
			var index1 = i+n1 == slices ? 0 : i+n1;
			var index2 = i+n2 == slices ? 0 : i+n2;
			builder.addTriangle(
				topvertex,
				level[index1],
				level[index2],
				topvertex,
				level[index1],
				level[index2],
				tleveltop[i],
				tlevels[tlevels.length-1][i+1],
				tlevels[tlevels.length-1][i]);
		}
		builder.done();
		builder.assignTo(this);
	}
}