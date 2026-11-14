@tool
extends Node2D
## Deko-Requisit (Doku 2.9, Werkstatt): Werkbank, Werkzeugwand, Maschinen,
## Erfindungen usw. aus dem Atlas graphics/sprites/deco/deco_workshop.png.
## Reine Dekoration ohne Kollision, liegt hinter den Spielobjekten.
## Requisiten mit zwei Bildern (Bildschirme, Funken, Blasen) sind animiert;
## das Tempo laeuft mit der Zeitblase (Regel 17).
## Der Node liegt unten in der Mitte (auf den Boden bzw. an die Wand setzen).

const TEXTURE := preload("res://graphics/sprites/deco/deco_workshop.png")
const META_FILE := "res://graphics/sprites/deco/deco_workshop.json"

## Welches Requisit.
@export_enum("workbench", "tool_wall", "shelf", "generator", "tesla_coil", "console", "robot_arm", "jetpack", "tube", "chalkboard", "lamp", "crate", "gauges", "cables", "prototype", "pizza_boxes", "barrel", "big_gear", "rocket", "microscope", "dish", "coffee", "blueprint", "toolbox", "gas_tanks", "brain_jar", "wall_clock", "bookshelf", "ladder", "laser_cannon", "hanging_cables", "drone", "teleporter", "cactus", "trash_can") var prop := "workbench":
	set(value):
		prop = value
		_update_bounds()
		queue_redraw()
## Spiegeln (nach links gewandt).
@export var flip := false:
	set(value):
		flip = value
		queue_redraw()
@export_group("Animation")
## Dauer eines Bildes bei animierten Requisiten (Sekunden, bei normalem Tempo).
@export_range(0.05, 5.0, 0.05) var frame_time := 0.4
## Versatz im Takt (Sekunden), damit gleiche Requisiten nicht gleichzeitig blinken.
@export_range(0.0, 5.0, 0.05) var start_offset := 0.0

static var _meta := {}

var _time := 0.0
var _frame := 0
var _time_affected: TimeAffected


func _ready() -> void:
	z_index = -8
	_time = start_offset
	if not Engine.is_editor_hint():
		_time_affected = TimeAffected.new()
		add_child(_time_affected)
	_update_bounds()


## Ausschnitt des Requisits im Atlas (x, y, w, h, frames).
func get_info() -> Dictionary:
	if _meta.is_empty():
		var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(META_FILE))
		_meta = data if data is Dictionary else {}
	return _meta.get(prop, {"x": 0, "y": 0, "w": 16, "h": 16, "frames": 1})


func _update_bounds() -> void:
	if _time_affected:
		var info := get_info()
		_time_affected.bounds = Rect2(-info.w * 0.5, -info.h, info.w, info.h)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var info := get_info()
	if int(info.frames) < 2:
		return
	_time += delta * _time_affected.time_scale
	var frame := int(_time / frame_time) % int(info.frames)
	if frame != _frame:
		_frame = frame
		queue_redraw()


func _draw() -> void:
	var info := get_info()
	var w: float = info.w
	var h: float = info.h
	var source := Rect2(info.x + _frame * w, info.y, w, h)
	var target := Rect2(-floorf(w * 0.5), -h, w, h)
	if flip:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(-1, 1))
		target.position.x = -target.position.x - w
	draw_texture_rect_region(TEXTURE, target, source)
	draw_set_transform(Vector2.ZERO)
