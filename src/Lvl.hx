package;

import kha.graphics2.Graphics;
import kha.Image;
import kha.Assets;
import kha.System;

typedef Tiles = { //tiles.json
	tsize: Int,
	scale: Float,
	layers: Array<Array<{id:Int}>>
}

typedef GameMap = { //map format
	w: Int,
	h: Int,
	layers: Array<Array<Array<Int>>>,
	objects: {
		player: {x:Int, y:Int}
	}
}

class Lvl {
	
	public var origTileset:Image;
	public var origTsize:Int; //for rescaling
	public var layersLength:Array<Int>;
	public var layersNum:Int;
	public var tilesNum:Int;
	public var map:GameMap;
	
	public var screenW = 0; //size of screen in tiles
	public var screenH = 0;
	public var tileset:Image;
	public var tsize = 0; //tile size
	public var scale = 1.0; //tile scale
	public var camera = {x: 0.0, y: 0.0};
	
	public function new() {}
	
	public function init():Void {
		initTiles();
		loadMap(1);
		resize();
	}
	
	private function initTiles():Void {
		var text = Assets.blobs.tiles_json;
		var json:Tiles = haxe.Json.parse(text.toString());
		var layers = json.layers;
		tsize = json.tsize;
		layersNum = layers.length;
		layersLength = [0];
		
		tilesNum = 1;
		for (l in layers) tilesNum += l.length;
		origTileset = Image.createRenderTarget(tilesNum * tsize, tsize);
		var g = origTileset.g2;
		g.begin(true, 0x0);
		origTsize = tsize;
		var offx = tsize;
		
		for (l in 0...layersNum) {
			var layer = layers[l];
			layersLength.push(layer.length);
			
			for (tile in layer) {
				var bmd = Reflect.field(Assets.images, "tiles_"+l+"_"+tile.id);
				g.drawImage(bmd, offx, 0);
				offx += tsize;
			}
		}
		g.end();
		_rescale(json.scale);
	}
	
	private function loadMap(id:Int):Void {
		var text = Reflect.field(Assets.blobs, "maps_"+id+"_json");
		map = haxe.Json.parse(text.toString());
	}
	
	public function getTile(layer:Int, x:Int, y:Int):Int {
		if (x > -1 && y > -1 && x < map.w && y < map.h) {
			var id = map.layers[layer][y][x];
			return id == 0 ? 0 : id + layersLength[layer];
		}
		return 0;
	}
	
	public function setTile(layer:Int, id:Int, x:Int, y:Int):Void {
		if (x > -1 && y > -1 && x < map.w && y < map.h) {
			map.layers[layer][y][x] = id + layersLength[layer];
		}
	}
	
	public function update(g:Graphics):Void {
		//resize(); //need to call this every frame without resize event
		
		//camera in tiles
		var ctx = -Std.int(camera.x/tsize);
		var cty = -Std.int(camera.y/tsize);
		var ctw = ctx + screenW;
		var cth = cty + screenH;
		
		//tiles offset
		var sx = ctx < 0 ? 0 : ctx;
		var sy = cty < 0 ? 0 : cty;
		var ex = ctw > map.w ? map.w : ctw;
		var ey = cth > map.h ? map.h : cth;
		g.color = 0xFFFFFFFF;
		
		for (l in 0...layersNum) {
			for (iy in sy...ey)
				for (ix in sx...ex) {
					var id = getTile(l, ix, iy);
					
					if (id > 0) g.drawSubImage(
						tileset,
						ix * tsize + camera.x,
						iy * tsize + camera.y,
						id * tsize, 0, tsize, tsize
					);
				}
		}
		
		#if debug
		var y = System.windowHeight() - origTileset.height;
		g.drawImage(origTileset, 0, y);
		#end
	}
	
	public function resize():Void {
		screenW = Math.ceil(System.windowWidth()/tsize)+1;
		screenH = Math.ceil(System.windowHeight()/tsize)+1;
	}
	
	function _rescale(scale:Float):Void {
		tsize = Std.int(origTsize * scale);
		this.scale = scale;
		
		tileset = Image.createRenderTarget(tilesNum * tsize, tsize);
		var g = tileset.g2;
		g.begin(true, 0x0);
		g.drawScaledImage(origTileset, 0, 0, tilesNum * tsize, tsize);
		g.end();
	}
	
	public function rescale(scale:Float):Void {
		_rescale(scale);
		resize();
	}
}
