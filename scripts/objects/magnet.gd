@tool
extends StaticBody2D
## Elektromagnet (Doku 2.4): geht im Takt an und aus. Solange er an ist, zieht
## er den Professor zur Polplatte hin (Metallteile im Exoskelett) oder stoesst
## ihn weg, wenn er im Feld steht. Beim Anziehen schwebt er dicht vor der
## Polplatte. Das Feld zeigt immer von der Polplatte weg (lokal nach unten)
## und dreht sich mit dem Magneten: an der Decke (Standard) nach unten, an
## einer Wand zur Seite, auf dem Boden (180 Grad gedreht) nach oben.
## Feldlinien fliessen zum Magneten hin (Anziehen) bzw. von ihm weg
## (Abstossen); kurz vor dem Ausschalten flackert das Feld (Warnung).
## Der Takt laeuft mit der Zeitblase, wenn sie den Magneten beruehrt.
##
## Signal-Empfaenger: activate() = einschalten (Takt laeuft), deactivate() =
## ganz aus, toggle() = umschalten.
## Fester Koerper auf Ebene 1. Ursprung: Mitte der Halterung (an Decke bzw.
## Wand setzen). "field_width" verbreitert Magnet, Kollision und Feld.
## Im Editor zeigen gestrichelter Rahmen und Pfeile Feld und Richtung (@tool).

## Wird gesendet, wenn das Feld an- oder ausgeht.
signal switched(is_on: bool)

## Anziehen (zum Magneten hin) oder Abstossen (weg vom Magneten).
enum Mode { ATTRACT, REPEL }

@export var mode := Mode.ATTRACT:
	set(value):
		mode = value
		queue_redraw()
@export_group("Takt")
## So lange ist das Feld an bzw. aus (Sekunden, bei normalem Tempo).
@export_range(0.1, 30.0, 0.05, "or_greater") var on_time := 3.0
@export_range(0.1, 30.0, 0.05, "or_greater") var off_time := 2.0
## Versatz im Takt beim Levelstart (Sekunden); 0 = beginnt mit "an".
@export_range(0.0, 30.0, 0.05, "or_greater") var start_offset := 0.0
## So lange vor dem Ausschalten flackert das Feld (Warnung, Sekunden).
@export_range(0.0, 5.0, 0.05) var warning_time := 0.6
## Dauerhaft an statt im Takt.
@export var always_on := false
## Laeuft beim Levelstart (sonst erst nach activate() bzw. toggle()).
@export var active := true
@export_group("Feld")
## Wie weit das Feld reicht (Pixel ab der Polplatte).
@export var reach := 460.0:
	set(value):
		reach = value
		queue_redraw()
## Breite des Felds und des Magneten (Pixel, mindestens 32).
@export var field_width := 48.0:
	set(value):
		field_width = maxf(value, 32.0)
		_update_shape()
		queue_redraw()
## Geschwindigkeit im Feld (Pixel pro Sekunde, zum Magneten hin bzw. weg)
## und wie schnell sie erreicht wird (Pixel pro Sekunde^2).
@export var lift_speed := 240.0
@export var lift_accel := 1400.0
## Abstand zur Polplatte, ab dem er beim Anziehen schwebt (Pixel).
@export var hover_gap := 6.0

const TEXTURE := preload("res://graphics/sprites/objects/object_magnet_placeholder.png")
## Ein Bild im Atlas (aus, an) und die Breite der Enden, die nicht gestreckt werden.
const FRAME := Vector2(32, 24)
const CAP := 8.0
## Halbe Hoehe des Professors (Mitte ueber den Fuessen).
const PLAYER_HALF := 25.0
# Farben aus der Palette: Feldlinien, Rahmen im Editor.
const COLOR_FIELD := Color("8fd3ff")
const COLOR_FIELD_DARK := Color("4d9be6")

var _cycle := 0.0
var _flicker := 0.0
var _on := false
var _time: TimeAffected
var _shape: CollisionShape2D
var _hum: AudioStreamPlayer2D


func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	_shape = CollisionShape2D.new()
	_shape.shape = RectangleShape2D.new()
	add_child(_shape)
	_update_shape()
	if Engine.is_editor_hint():
		return
	# Vor dem Professor rechnen, damit er im selben Schritt bewegt wird.
	process_physics_priority = -1
	_time = TimeAffected.new()
	_time.bounds = Rect2(-_width() * 0.5, 0, _width(), FRAME.y)
	add_child(_time)
	_cycle = fposmod(start_offset, on_time + off_time)
	_on = _compute_on()


## Ist das Feld gerade an?
func is_on() -> bool:
	return _on


## Signal-Empfaenger
func activate() -> void:
	if not active:
		active = true
		_cycle = 0.0


func deactivate() -> void:
	active = false


func toggle() -> void:
	if active:
		deactivate()
	else:
		activate()


## Richtung des Felds in der Welt (von der Polplatte weg).
func get_field_direction() -> Vector2:
	return global_transform.y.normalized()


## Liegt der Punkt (global, Mitte des Professors) im Feld?
func is_in_field(center: Vector2) -> bool:
	var local := to_local(center)
	return absf(local.x) <= _width() * 0.5 and local.y >= FRAME.y - PLAYER_HALF and local.y <= FRAME.y + reach


func _width() -> float:
	return maxf(field_width, 32.0)


func _update_shape() -> void:
	if _shape == null:
		return
	(_shape.shape as RectangleShape2D).size = Vector2(_width(), FRAME.y)
	_shape.position = Vector2(0, FRAME.y * 0.5)


func _compute_on() -> bool:
	if not active:
		return false
	if always_on:
		return true
	return _cycle < on_time


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if active and not always_on:
		_cycle = fposmod(_cycle + delta * _time.time_scale, on_time + off_time)
	var now := _compute_on()
	if now != _on:
		_on = now
		switched.emit(_on)
	if _on and _hum == null:
		_hum = Sound.loop("magnet_loop", self, _time)
		_hum.position = Vector2(0, FRAME.y + 40)
	elif not _on and _hum != null:
		_hum.queue_free()
		_hum = null
	_flicker += delta
	queue_redraw()
	if not _on:
		return
	var professor := get_tree().get_first_node_in_group("player") as CharacterBody2D
	if professor == null or professor.get("is_dead") or not professor.has_method("apply_magnet_force"):
		return
	var center := professor.global_position + Vector2(0, -PLAYER_HALF)
	if not is_in_field(center):
		return
	var away := get_field_direction()
	if mode == Mode.REPEL:
		professor.apply_magnet_force(away, lift_speed, lift_accel)
		return
	# Anziehen: zum Magneten hin, dicht davor schweben.
	var gap := to_local(center).y - FRAME.y - PLAYER_HALF
	var target := lift_speed if gap > hover_gap + 12.0 else (lift_speed * 0.25 if gap > hover_gap else 0.0)
	professor.apply_magnet_force(-away, target, lift_accel)


func _draw() -> void:
	var on := _on and not Engine.is_editor_hint()
	var w := _width()
	var src_x := FRAME.x if on else 0.0
	var left := -w * 0.5
	# Enden ungestreckt, Mitte (Spule) auf die Breite gestreckt
	draw_texture_rect_region(TEXTURE, Rect2(left, 0, CAP, FRAME.y), Rect2(src_x, 0, CAP, FRAME.y))
	draw_texture_rect_region(TEXTURE, Rect2(left + CAP, 0, w - CAP * 2.0, FRAME.y), Rect2(src_x + CAP, 0, FRAME.x - CAP * 2.0, FRAME.y))
	draw_texture_rect_region(TEXTURE, Rect2(-left - CAP, 0, CAP, FRAME.y), Rect2(src_x + FRAME.x - CAP, 0, CAP, FRAME.y))
	var half := w * 0.5
	var toward := mode == Mode.ATTRACT
	if Engine.is_editor_hint():
		# Feld als gestrichelter Rahmen und Pfeile fuer die Richtung
		var y := FRAME.y
		while y < FRAME.y + reach:
			draw_rect(Rect2(-half, y, 1, 3), COLOR_FIELD_DARK)
			draw_rect(Rect2(half - 1, y, 1, 3), COLOR_FIELD_DARK)
			y += 6.0
		draw_rect(Rect2(-half, FRAME.y + reach - 1, w, 1), COLOR_FIELD_DARK)
		var ay := FRAME.y + 24.0
		while ay < FRAME.y + reach - 8.0:
			_draw_chevron(Vector2(0, ay), toward)
			ay += 48.0
		return
	if not on:
		return
	var left_time := on_time - _cycle
	if not always_on and left_time < warning_time and int(_flicker * 12.0) % 2 == 0:
		return
	# Feldlinien: Striche fliessen zum Magneten (Anziehen) bzw. weg (Abstossen)
	var lines := maxi(2, int(w / 14.0))
	for i in lines:
		var x := -half + 6.0 + i * (w - 12.0) / float(lines - 1)
		var offset := fposmod(_flicker * 60.0 + i * 17.0, 24.0)
		var y := FRAME.y + reach - offset if toward else FRAME.y + offset
		while y > FRAME.y - 1.0 and y < FRAME.y + reach:
			draw_rect(Rect2(roundf(x), roundf(y), 1, 8), COLOR_FIELD if i % 2 == 0 else COLOR_FIELD_DARK)
			y += -24.0 if toward else 24.0


func _draw_chevron(at: Vector2, up: bool) -> void:
	var s := -1.0 if up else 1.0
	for i in 4:
		draw_rect(Rect2(at.x - 4 + i, at.y + s * i, 1, 1), COLOR_FIELD)
		draw_rect(Rect2(at.x + 4 - i, at.y + s * i, 1, 1), COLOR_FIELD)
