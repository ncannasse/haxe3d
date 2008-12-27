import h3d.Vector;

typedef K = flash.ui.Keyboard;

class Test {

	var mc : flash.display.MovieClip;
	var world : h3d.World;
	var light : h3d.material.Light;
	var light2 : h3d.material.Light;
	var cam : h3d.Camera;
	var time : Float;
	var collada : h3d.tools.Collada;
	var xmove : Float;
	var ymove : Float;

	function new( mc ) {
		this.mc = mc;
		var display = new h3d.Display(mc.stage.stageWidth,mc.stage.stageHeight);
		mc.addChild(display.result);
		cam = new h3d.Camera();
		cam.position.set(3,3,1);
		time = 0;
		xmove = 0; ymove = 0;
		light = new h3d.material.Light(new h3d.Vector(0,0,-1),new h3d.material.Color(1,0.1,0.5),false);
		light2 = new h3d.material.Light(new h3d.Vector(0,0,2),new h3d.material.Color(0,0.5,0),false);
		world = new h3d.World( display, cam );
		world.axisSize = 1;
		world.addLight(light);
		world.addLight(light2);
		var loader = new h3d.tools.Loader();
		collada = loader.loadCollada("res/axisCube.dae");
		loader.onLoaded = init;
		loader.start();
		var statusPanel = new h3d.tools.StatusPanel( world );
		mc.addChild( statusPanel );
	}

	function init() {
		for( o in collada.objects )
			world.addObject( o );
		var me = this;
		mc.addEventListener(flash.events.Event.ENTER_FRAME,function(_) inst.render());
		mc.stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN,function(e:flash.events.KeyboardEvent) me.onKeyDown(e.keyCode));
		mc.stage.addEventListener(flash.events.KeyboardEvent.KEY_UP,function(e:flash.events.KeyboardEvent) me.onKeyUp(e.keyCode));
	}

	function getColor( mat : h3d.material.Material ) {
		var color = null;
		var m = flash.Lib.as(mat,h3d.material.ColorMaterial);
		if( m != null ) color = m.ambient.add(m.diffuse);
		var m = flash.Lib.as(mat,h3d.material.BitmapMaterial);
		if( m != null ) color = getColor(m.sub);
		var m = flash.Lib.as(mat,h3d.material.WireMaterial);
		if( m != null ) color = m.color;
		if( color == null ) color = new h3d.material.Color(0.5,0.5,0.5,1);
		return color;
	}

	function onKeyDown( k : Int ) {
		switch( k ) {
		case K.DOWN: xmove = -0.1;
		case K.UP: xmove = 0.1;
		case K.LEFT: ymove = -0.1;
		case K.RIGHT: ymove = 0.1;
		}
	}

	function onKeyUp( k : Int ) {
		switch( k ) {
		case "W".code:
			for( o in world.listObjects() )
				for( p in o.primitives ) {
					var color = getColor(p.p.material);
					p.p.material.free();
					p.p.setMaterial(new h3d.material.WireMaterial(color));
				}
		case "P".code:
			var vcolor = new h3d.material.RGBMaterial();
			for( o in world.listObjects() )
				for( p in o.primitives ) {
					var color = getColor(p.p.material).scale(0.3);
					// colorize vertexes with material color
					var v = p.p.vertexes;
					while( v != null ) {
						v.cr = color.r;
						v.cb = color.b;
						v.cg = color.g;
						v = v.next;
					}
					// set vertex color material
					var bmat = flash.Lib.as(p.p.material,h3d.material.BitmapMaterial);
					if( bmat == null )
						p.p.setMaterial(vcolor);
					else {
						bmat.sub = vcolor;
						bmat.shade = h3d.material.ShadeModel.RGBLight;
					}
				}
		case "Q".code:
			var qualities = [flash.display.StageQuality.BEST,flash.display.StageQuality.HIGH,flash.display.StageQuality.MEDIUM,flash.display.StageQuality.LOW];
			var qpos = 0;
			// fu*n, the enums are lowercase while reading the attribute is uppercase
			var q = Std.string(mc.stage.quality).toLowerCase();
			for( i in 0...qualities.length )
				if( q == Std.string(qualities[i]).toLowerCase() ) {
					qpos = i;
					break;
				}
			qpos++;
			mc.stage.quality = qualities[qpos % qualities.length];
		case K.DOWN, K.UP:
			xmove = 0;
		case K.LEFT, K.RIGHT:
			ymove = 0;
		}
	}

	function render() {
		// update camera depending on mouse position
		haxe.Log.clear();
		var dy = (mc.mouseY / world.display.height - 0.5) * 2;
		var dx = (mc.mouseX / world.display.width - 0.5) * 2;
		var p = world.camera.position;
		var t = world.camera.target;
		var dt = t.sub(p);
		dt.normalize();
		var lt = dt.cross(world.camera.up);
		lt.normalize();
		p.x += dt.x * xmove + lt.x * ymove;
		p.y += dt.y * xmove + lt.y * ymove;
		p.z += dt.z * xmove + lt.z * ymove;
		var a = (-dx * 1.2 + 1) * Math.PI;
		t.set(Math.cos(a) + p.x,Math.sin(a) + p.y,(-dy + 0.3) * 3 + p.z);
		world.camera.update();

		// rotate light direction
		time += 0.03;
		light.power = light.directional ? 1.0 : 2.0;
		light.position.x = -Math.cos(time) * 3;
		light.position.y = -Math.sin(time) * 3;
		light.position.z = light.directional ? -3 : 3;
		light2.position.x = -Math.cos(time/2) * 2;
		light2.position.y = -Math.sin(time/3) * 4;
		light2.position.z = light2.directional ? -2 : 2;

		// render
		world.beginRender();
		world.renderObjects();
		if( !light.directional )
			world.drawPoint(light.position,light.color,3);
		if( !light2.directional )
			world.drawPoint(light2.position,light2.color,3);
		world.finishRender();
	}

	static var inst : Test;

	static function main() {

		var stage = flash.Lib.current.stage;
		stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		stage.align = flash.display.StageAlign.TOP_LEFT;
		stage.quality = flash.display.StageQuality.MEDIUM;

		var mc = flash.Lib.current;
		inst = new Test(mc);
	}

}