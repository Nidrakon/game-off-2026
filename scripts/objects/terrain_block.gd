@tool
extends StaticBody2D
## Wand- und Bodenelement (Doku 2.9, Baukasten): ein fester Block aus
## Gelaende-Tiles in beliebiger Groesse, zum Hineinziehen statt Malen.
## Groesse in Tiles im Inspector, im Editor sofort sichtbar (@tool).
## Liegt auf Ebene 1 "world" wie der gemalte Boden.
## Der Node liegt an der linken oberen Ecke (auf das 16er-Raster setzen).

## Aussehen: Boden (oberste Reihe mit Kante, darunter Fuellung) oder Block
## (ueberall Block-Tiles, fuer Waende, Saeulen und Kisten).
enum Style { FLOOR, BLOCK }

const TEXTURE := preload("res://graphics/tilesets/tileset_placeholder.png")
const TILE := 16
## Lage der Tiles in der Grafik: Boden-Oberseite, Fuellung, Block.
const SURFACE := Rect2(0, 0, 16, 16)
const FILL := Rect2(16, 0, 16, 16)
const BLOCK := Rect2(32, 0, 16, 16)

## Breite und Hoehe in Tiles.
@export var size_tiles := Vector2i(6, 2):
	set(value):
		size_tiles = value.max(Vector2i.ONE)
		_update_shape()
		queue_redraw()
## Aussehen (Boden oder Block).
@export var style := Style.FLOOR:
	set(value):
		style = value
		queue_redraw()
## Von unten durchspringbar (man landet oben drauf, stoesst nicht mit dem
## Kopf an), z. B. fuer Stege.
@export var one_way := false:
	set(value):
		one_way = value
		_update_shape()

var _shape: CollisionShape2D


func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	_shape = CollisionShape2D.new()
	_shape.shape = RectangleShape2D.new()
	add_child(_shape)
	_update_shape()


func _update_shape() -> void:
	if _shape == null:
		return
	var size := Vector2(size_tiles * TILE)
	(_shape.shape as RectangleShape2D).size = size
	_shape.position = size * 0.5
	_shape.one_way_collision = one_way


func _draw() -> void:
	for y in size_tiles.y:
		for x in size_tiles.x:
			var source := BLOCK
			if style == Style.FLOOR:
				source = SURFACE if y == 0 else FILL
			draw_texture_rect_region(TEXTURE, Rect2(x * TILE, y * TILE, TILE, TILE), source)
