package;

import kha.Framebuffer;
import kha.input.KeyCode;
import kha.System;

class Game extends Screen {
	
	var lvl:Lvl;
	
	public function new() {
		super();
	}
	
	public function init():Void {
		lvl = new Lvl();
		lvl.init();
	}
	
	override function onKeyDown(key:KeyCode):Void {
		if (key == KeyCode.Zero) {
			lvl.rescale(1);
		} else if (key == 189 || key == KeyCode.HyphenMinus) {
			if (lvl.scale > 1) lvl.rescale(lvl.scale - 1);
		} else if (key == KeyCode.Equals) {
			if (lvl.scale < 9) lvl.rescale(lvl.scale + 1);
		}
	}
	
	override function onResize():Void {
		lvl.resize();
	}
	
	override function onUpdate():Void {
		var sx = 0, sy = 0;
		
		if (keys[KeyCode.Left] || keys[KeyCode.A]) sx -= 5;
		if (keys[KeyCode.Right] || keys[KeyCode.D]) sx += 5;
		if (keys[KeyCode.Up] || keys[KeyCode.W]) sy -= 5;
		if (keys[KeyCode.Down] || keys[KeyCode.S]) sy += 5;
		if (keys[KeyCode.Shift]) {
			sx *= 2; sy *= 2;
		}
		
		if (sx != 0) lvl.camera.x += sx;
		if (sy != 0) lvl.camera.y += sy;
	}
	
	override function onRender(frame:Framebuffer):Void {
		var g = frame.g2;
		g.begin(true, 0xFF888888);
		lvl.update(g);
		
		for (pointer in pointers) {
			if (!pointer.used) continue;
			if (pointer.isDown) g.color = 0xFFFF0000;
			else g.color = 0xFFFFFFFF;
			g.fillRect(pointer.x-10, pointer.y-10, 20, 20);
		}
		
		#if debug
		debugScreen(g);
		#end
		g.end();
	}
	
}
