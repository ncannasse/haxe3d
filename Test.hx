import h3d.Vector;

class Test {

	var mc : flash.display.MovieClip;
	var world : h3d.World;

	function new( mc ) {
		this.mc = mc;
		var display = new h3d.Display(mc,mc.stage.stageWidth,mc.stage.stageHeight);
		var camera = new h3d.Camera(new Vector(10,10,10));
		world = new h3d.World(display,camera);
		world.axisSize = 1;
		var x = Xml.parse(haxe.Resource.getString("res/axisCube.dae"));
		var c = new h3d.tools.Collada();
		c.loadXML(x);
		for( o in c.objects )
			world.addObject(o);
		var loader = new h3d.tools.Loader();
		for( m in c.materials ) {
			var m = flash.Lib.as(m,h3d.mat.BitmapMaterial);
			if( m != null ) loader.loadTexture(m.texture);
		}
		loader.start();
	}

	function render() {
		// update camera depending on mouse position
		var cp = world.camera.position;
		var M = 5;
		cp.z = (world.display.height / 2 - mc.mouseY) / (world.display.height / 2);
		var p = ((mc.mouseX / world.display.width) - 0.5) * 1.5 + 0.5;
		cp.x = (1 - p);
		cp.y = p;
		cp.scale(M / cp.length());
		world.camera.update();
		// render
		world.render();
	}

	static var inst : Test;

	static function main() {
		var mc = flash.Lib.current;
		inst = new Test(mc);
		mc.addEventListener(flash.events.Event.ENTER_FRAME,function(_) inst.render());
    }

}