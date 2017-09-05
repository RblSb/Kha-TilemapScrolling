package;

import kha.Framebuffer;
import kha.System;
import kha.Font;
import kha.Assets;

class Loader {
	
	public function new() {}
	
	public function init():Void {
		System.notifyOnRender(onRender);
		Assets.loadEverything(loadComplete);
	}
	
	public function loadComplete():Void {
		System.removeRenderListener(onRender);
		
		var game = new Game();
		game.show();
		game.init();
	}
	
	function onRender(framebuffer:Framebuffer):Void {
		var g = framebuffer.g2;
		g.begin();
		var h = System.windowHeight() / 20;
		var w = Assets.progress * System.windowWidth();
		var y = System.windowHeight() / 2 - h;
		g.fillRect(0, y, w, h * 2);
		g.end();
	}
	
}
