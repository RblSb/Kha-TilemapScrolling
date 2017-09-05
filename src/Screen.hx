package;

import kha.Framebuffer;
import kha.graphics2.Graphics;
import kha.input.Keyboard;
import kha.input.KeyCode;
import kha.input.Surface;
import kha.input.Mouse;
import kha.Scheduler;
import kha.System;
import kha.Assets;

//Сlass to unify mouse/touch events and setup game screens

typedef Pointer = {
	?startX:Float,
	?startY:Float,
	?x:Float,
	?y:Float,
	?isDown:Bool,
	?used:Bool
}

class Screen {
	
	public static var screen:Screen; //current screen
	static var lastTime = 0.0; //for fps counter
	static var oldW:Int; //for resize event
	static var oldH:Int;
	static var taskId:Int;
	
	public var keys:Map<KeyCode, Bool> = new Map();
	public var pointers:Map<Int, Pointer> = [
		for (i in 0...10) i => {startX: 0, startY: 0, x: 0, y: 0, isDown: false, used: false}
	];
	
	public function new() {}
	
	public function show():Void {
		if (screen != null) screen.hide();
		screen = this;
		
		taskId = Scheduler.addTimeTask(onUpdate, 0, 1/60);
		System.notifyOnRender(_onRender);
		
		Keyboard.get().notify(_onKeyDown, _onKeyUp);
		#if (kha_android || kha_ios)
		Surface.get().notify(_onTouchDown, _onTouchUp, _onTouchMove);
		#else
		Mouse.get().notify(_onMouseDown, _onMouseUp, _onMouseMove, null);
		#end
	}
	
	public function hide():Void {
		Scheduler.removeTimeTask(taskId);
		System.removeRenderListener(_onRender);
		
		Keyboard.get().remove(_onKeyDown, _onKeyUp, null);
		#if mobile
		Surface.get().remove(_onTouchDown, _onTouchUp, _onTouchMove);
		#else
		Mouse.get().remove(_onMouseDown, _onMouseUp, _onMouseMove, null);
		#end
	}
	
	inline function _onRender(framebuffer:Framebuffer):Void {
		if (System.windowWidth() != oldW || System.windowHeight() != oldH) _onResize();
		onRender(framebuffer);
	}
	
	inline function _onResize():Void {
		onResize();
		oldW = System.windowWidth();
		oldH = System.windowHeight();
	}
	
	inline function _onKeyDown(key:KeyCode):Void {
		keys[key] = true;
		onKeyDown(key);
	}
	
	inline function _onKeyUp(key:KeyCode):Void {
		keys[key] = false;
		onKeyUp(key);
	}
	
	inline function _onMouseDown(button:Int, x:Int, y:Int):Void {
		pointers[0].startX = x;
		pointers[0].startY = y;
		pointers[0].x = x;
		pointers[0].y = y;
		pointers[0].isDown = true;
		pointers[0].used = true;
		onMouseDown(0);
	}
	
	inline function _onMouseMove(x:Int, y:Int, mx:Int, my:Int):Void {
		pointers[0].x = x;
		pointers[0].y = y;
		pointers[0].used = true;
		onMouseMove(0);
	}
	
	inline function _onMouseUp(button:Int, x:Int, y:Int):Void {
		pointers[0].x = x;
		pointers[0].y = y;
		pointers[0].isDown = false;
		onMouseUp(0);
	}
	
	inline function _onTouchDown(id:Int, x:Int, y:Int):Void {
		if (id > 9) return;
		pointers[id].startX = x;
		pointers[id].startY = y;
		pointers[id].x = x;
		pointers[id].y = y;
		pointers[id].isDown = true;
		pointers[id].used = true;
		onMouseDown(id);
	}
	
	inline function _onTouchMove(id:Int, x:Int, y:Int):Void {
		if (id > 9) return;
		pointers[id].x = x;
		pointers[id].y = y;
		onMouseMove(id);
	}
	
	inline function _onTouchUp(id:Int, x:Int, y:Int):Void {
		if (id > 9) return;
		pointers[id].x = x;
		pointers[id].y = y;
		pointers[id].isDown = false;
		onMouseUp(id);
	}
	
	function debugScreen(g:Graphics):Void {
		var fps = Math.floor(1 / (System.time - lastTime));
		lastTime = System.time;
		g.color = 0xFFFFFFFF;
		g.font = Assets.fonts.OpenSans_Regular;
		g.fontSize = 24;
		var txt = fps+" | "+System.windowHeight()+"x"+System.windowWidth();
		var x = System.windowWidth() - g.font.width(g.fontSize, txt);
		var y = System.windowHeight() - g.font.height(g.fontSize);
		g.drawString(txt, x, y);
	}
	
	//functions to override
	
	function onResize():Void {}
	
	function onUpdate():Void {}
	
	function onRender(framebuffer:Framebuffer):Void {}
	
	function onKeyDown(key:KeyCode):Void {}
	
	function onKeyUp(key:KeyCode):Void {}
	
	function onMouseDown(id:Int):Void {}
	
	function onMouseMove(id:Int):Void {}
	
	function onMouseUp(id:Int):Void {}
	
}
