import h3d.Vector;

class Test {

	var mc : flash.display.MovieClip;
	var world : h3d.World;
	var czoom : Float;
	var time : Float;
	var collada : h3d.tools.Collada;

	function new( mc ) {
		this.mc = mc;
		var display = new h3d.Display(mc.stage.stageWidth,mc.stage.stageHeight);
		mc.addChild(display.result);
		var camera = new h3d.Camera(new Vector(10,10,10));
		czoom = 5;
		time = 0;
		world = new h3d.World(display,camera);
		world.axisSize = 1;
		var loader = new h3d.tools.Loader();
		collada = loader.loadCollada("res/axisCube.dae");
		loader.onLoaded = init;
		loader.start();
	}

	function init() {
		for( o in collada.objects )
			world.addObject(o);
		var me = this;
		var qualities = [flash.display.StageQuality.BEST,flash.display.StageQuality.HIGH,flash.display.StageQuality.MEDIUM,flash.display.StageQuality.LOW];
		var qpos = 3;
		mc.addEventListener(flash.events.Event.ENTER_FRAME,function(_) inst.render());
		mc.stage.addEventListener(flash.events.MouseEvent.MOUSE_WHEEL,function(e:flash.events.MouseEvent) me.czoom *= (e.delta > 0) ? 0.85 : 1.15);
		mc.stage.addEventListener(flash.events.MouseEvent.MOUSE_UP,function(e:flash.events.MouseEvent) {
			me.mc.stage.quality = qualities[qpos % qualities.length];
			qpos++;
		});
	}

	function render() {
		haxe.Log.clear();

		// update camera depending on mouse position
		var cp = world.camera.position;
		cp.z = (world.display.height / 2 - mc.mouseY) / (world.display.height / 2);
		var p = ((mc.mouseX / world.display.width) - 0.5) * 1.5 + 0.5;
		cp.x = (1 - p);
		cp.y = p;
		cp.scale(czoom / cp.length());
		world.camera.update();
		// rotate light direction
		time += 0.03;
		world.light.x = -Math.cos(time);
		world.light.y = -Math.sin(time);
		world.light.z = -1;
		// render
		world.render();
		trace(world.stats);
	}

	static var inst : Test;

	static function main() {
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;

		var mc = flash.Lib.current;
		inst = new Test(mc);

		var statusPanel = new h3d.tools.StatusPanel();
		mc.addChild( statusPanel );
	}

}