package;

import kha.System;
#if js
import js.html.CanvasElement;
import js.Browser.document;
import js.Browser.window;
#end

class Main {
	
	public static function main():Void {
		//make html5 canvas resizable
		#if js
		document.documentElement.style.padding = "0";
		document.documentElement.style.margin = "0";
		document.body.style.padding = "0";
		document.body.style.margin = "0";
		var canvas = cast(document.getElementById("khanvas"), CanvasElement);
		canvas.style.display = "block";
		
		var resize = function() {
			canvas.width = Std.int(window.innerWidth * window.devicePixelRatio);
			canvas.height = Std.int(window.innerHeight * window.devicePixelRatio);
			canvas.style.width = document.documentElement.clientWidth + "px";
			canvas.style.height = document.documentElement.clientHeight + "px";
		}
		window.onresize = resize;
		resize();
		#end
		
		System.init({title: "TilemapScrolling", width: 800, height: 600}, init);
	}
	
	public static function init():Void {
		var loader = new Loader();
		loader.init();
	}
	
}
