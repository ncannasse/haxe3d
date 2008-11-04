package h3d.util;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.system.System;


/**
	flash9+.
	Base for flash performance meters/status panels.
*/
class StatusPanel extends Sprite {
	
	public static var DEFAULT_WIDTH = 60;
	
	public static var COLOR_MS = 0x00FF00;
	public static var COLOR_FPS = 0xFFFF00;
	public static var COLOR_MEM = 0x00FFFF;
	
	static var initialized = false;
	
	var w : Int;
	var h : Int;
	var graph : BitmapData;
	var graph_hi : BitmapData;
	var graph_h : Int;
	var tf_fps 	: TextField;
	var tf_ms 	: TextField;
	var tf_mem 	: TextField;
	var format : TextFormat;
	
	var fps 	: Int;
	var timer 	: Float;
	var ms 		: Int;
	var ms_prev : Float;
	var mem 	: Float;
	var mouseDown : Bool;
	
	
	public function new( ?w : Int, ?h : Int ) {
		
		super();
		this.w = ( w != null ) ? w : DEFAULT_WIDTH;
		this.h = ( h != null ) ? h : 50;
		
		graph_h = 50;
		mouseDown = false;
		
		init();
	}
	
	
	function init() {
		
		fps = ms = 0;
		timer = ms_prev = mem = 0.0;
		
		graph = new BitmapData( w, graph_h, false, 0x333333 );
		var bmp = new Bitmap( graph );
		bmp.y = 70;
		addChild( bmp );
		
		graph_hi = new BitmapData( w, graph_h, false, 0x333333 );
		var bmp = new Bitmap( graph_hi );
		bmp.y = 70 + graph_h;
		addChild( bmp );
		
		format = new TextFormat( "__sans", 8 );
		
		graphics.beginFill( 0x222222 );
		graphics.drawRect( 0, 0, w, h );
		graphics.endFill();
		
		tf_fps = new TextField();
		tf_ms = new TextField();
		tf_mem = new TextField();
		
		tf_fps.defaultTextFormat = tf_ms.defaultTextFormat = tf_mem.defaultTextFormat = format;
		tf_fps.width = tf_ms.width = tf_mem.width = w;
		tf_fps.selectable = tf_ms.selectable = tf_mem.selectable = false;
		
		tf_fps.textColor = 0xFFFF00;
		tf_fps.text = "FPS: ";
		addChild( tf_fps );
		
		tf_ms.y = 10;
		tf_ms.textColor = COLOR_MS;
		tf_ms.text = "MS: ";
		addChild( tf_ms );
		
		tf_mem.y = 20;
		tf_mem.textColor = 0x00FFFF;
		tf_mem.text = "MEM: ";
		addChild( tf_mem );
		
		addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
		addEventListener( MouseEvent.CLICK, mouseClickHandler );
		addEventListener( MouseEvent.MOUSE_OUT, mouseExitHandler );
		addEventListener( MouseEvent.MOUSE_UP, mouseExitHandler );
		addEventListener( Event.ENTER_FRAME, update );
		
	}
	
	function mouseClickHandler( e : MouseEvent ) {
		handleMouseFPS();
	}
	
	function mouseDownHandler( e : MouseEvent ) {
		mouseDown = true;
		var self = this;
		haxe.Timer.delay( function() {
			self.addEventListener( Event.ENTER_FRAME, self.mouseHoldHandler );
		}, 400 );
	}
	
	function mouseExitHandler( e : MouseEvent ) {
		mouseDown = false;
		removeEventListener( Event.ENTER_FRAME, mouseHoldHandler );
	}
	
	function mouseOutHandler( e : MouseEvent ) {
		mouseDown = false;
		removeEventListener( Event.ENTER_FRAME, mouseHoldHandler );
	}
	
	function mouseHoldHandler( e : Event ) {
		if( mouseDown ) {
			handleMouseFPS();
		}
	}
	
	function handleMouseFPS() {
		if( this.mouseY > this.height * .5 ) {
			if( stage.frameRate > 1 ) stage.frameRate--;
		} else {
			if( stage.frameRate < 999 ) stage.frameRate++;
		}
		tf_fps.text = "FPS: " + fps + " / " + stage.frameRate;
	}
	
	function update(_) {
		
		timer = flash.Lib.getTimer();
		fps++;
		
		var memGraph =  Math.min( graph_h, Math.sqrt( Math.sqrt( mem * 5000 ) ) ) - 2;
		
		if( timer - 1000 > ms_prev ) {
			ms_prev = Std.int( timer );
			mem = System.totalMemory / 1048576;
			var fpsGraph = Math.min( 50, 50 / stage.frameRate * fps );
			graph.scroll( 1, 0 );
			graph.fillRect( new Rectangle( 0, 0, 1, graph_h ), 0x000000 );
			graph.setPixel( 0, Std.int( graph_h - fpsGraph ), 0xFFFF00 );
			graph.setPixel( 0, Std.int( graph_h - ( Std.int( timer - ms ) >> 1 ) ), 0x00FF00 );                          
			graph.setPixel( 0, Std.int( graph_h - memGraph ), COLOR_MEM);
			tf_fps.text = "FPS: " + fps + " / " + stage.frameRate;
			tf_mem.text = "MEM: " + mem;
			fps = 0;
		}
		
		graph_hi.scroll( 1, 0 );
		graph_hi.fillRect( new Rectangle( 0, 0, 1, graph.height ), 0x222222 );
		graph_hi.setPixel( 0, Std.int( graph.height - ( Std.int( timer - ms ) >> 1 ) ), COLOR_MS );
		graph_hi.setPixel( 0, Std.int( graph.height - memGraph ), COLOR_MEM);
		
		tf_ms.text = "MS: " + ( timer - ms );
		ms = Std.int( timer );
	}
	
}
