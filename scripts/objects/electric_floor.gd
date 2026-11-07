@tool
extends Hazard
## Starkstrom-Bodenplatte: Reihe aus Platten mit knisternden Funken. Wer sie
## beruehrt, stirbt. Wird anstelle von Boden-Tiles eingesetzt (Lueckenbreite
## = width_tiles). Der Node liegt an der linken oberen Ecke der ersten Platte.
## Im Editor sofort in der richtigen Breite sichtbar (@tool).

const TEXTURE := preload("res://graphics/sprites/objects/object_electric_floor_placeholder.png")
const TILE := 16
## Wechsel zwischen den zwei Funken-Bildern (Sekunden).
const FRAME_TIME := 0.08
## Toedlicher Bereich: ab dieser Hoehe innerhalb der Platte (Pixel von oben).
const DEADLY_TOP := 6

## Breite in Tiles.
@export_range(1, 64) var width_tiles := 3:
	set(value):
		width_tiles = value
		_update_shape()
		queue_redraw()

var _shape: CollisionShape2D
var _frame := 0
var _frame_left := FRAME_TIME


func _ready() -> void:
	_shape = CollisionShape2D.new()
	_shape.shape = RectangleShape2D.new()
	add_child(_shape)
	_update_shape()
	super._ready()


func _process(delta: float) -> void:
	_frame_left -= delta
	if _frame_left <= 0.0:
		_frame_left += FRAME_TIME
		# Nicht immer streng abwechseln: wirkt unruhiger, wie echte Funken.
		_frame = (_frame + 1) % 2 if randf() < 0.8 else _frame
		queue_redraw()


func _update_shape() -> void:
	if _shape == null:
		return
	var rect := _shape.shape as RectangleShape2D
	rect.size = Vector2(width_tiles * TILE, TILE - DEADLY_TOP)
	_shape.position = Vector2(width_tiles * TILE * 0.5, DEADLY_TOP + (TILE - DEADLY_TOP) * 0.5)


func _draw() -> void:
	for i in width_tiles:
		# Jede Platte startet versetzt, damit die Funken nicht im Gleichtakt springen.
		var frame := (_frame + i) % 2
		draw_texture_rect_region(TEXTURE, Rect2(i * TILE, 0, TILE, TILE), Rect2(0, frame * TILE, TILE, TILE))
