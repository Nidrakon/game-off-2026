@tool
extends StaticBody2D
## Elektromagnet (Doku 2.4, Teslakammer, Schritt 21): haengt an der Decke und
## geht im Takt an und aus. Solange er an ist, zieht er den Professor nach
## oben (Metallteile im Exoskelett), wenn dieser unter ihm im Feld steht;
## dicht unter dem Magneten schwebt er. So erreicht man hohe Vorspruenge.
## Kurz vor dem Ausschalten flackert das Feld als Warnung. Der Takt laeuft
## in der Zeitblase langsamer oder schneller (Regel 17), wenn die Blase den
## Magneten beruehrt.
##
## Signal-Empfaenger: activate() = einschalten (Takt laeuft), deactivate() =
## ganz aus, toggle() = umschalten.
## Fester Koerper auf Ebene 1. Der Node liegt oben in der Mitte (an die Decke
## setzen). Im Editor ist das Feld als gestrichelter Rahmen zu sehen (@tool).

## Wird gesendet, wenn das Feld an- oder ausgeht.
signal switched(is_on: bool)

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
## Wie weit das Feld nach unten reicht (Pixel ab Unterkante des Magneten).
@export var reach := 460.0:
	set(value):
		reach = value
		queue_redraw()
## Breite des Felds (Pixel).
@export var field_width := 48.0:
	set(value):
		field_width = value
		queue_redraw()
## Steiggeschwindigkeit im Feld (Pixel pro Sekunde) und wie schnell sie
## erreicht wird (Pixel pro Sekunde^2).
@export var lift_speed := 240.0
@export var lift_accel := 1400.0
## Abstand zwischen Kopf und Magnet, ab dem er schwebt (Pixel).
@export var hover_gap := 6.0

const TEXTURE := preload("res://graphics/sprites/objects/object_magnet_placeholder.png")
const SIZE := Vector2(32, 24)
## Hoehe des Professors (Kopf ueber den Fuessen, Pixel).
const PLAYER_HEIGHT := 50.0
# Farben aus der Palette: Feldlinien, Rahmen im Editor.
const COLOR_FIELD := Color("8fd3ff")
const COLOR_FIELD_DARK := Color("4d9be6")

var _cycle := 0.0
var _flicker := 0.0
var _on := false
var _time: TimeAffected


func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = SIZE
	shape.shape = rect
	shape.position = Vector2(0, SIZE.y * 0.5)
	add_child(shape)
	if Engine.is_editor_hint():
		return
	# Vor dem Professor rechnen, damit er im selben Schritt angehoben wird.
	process_physics_priority = -1
	_time = TimeAffected.new()
	_time.bounds = Rect2(-SIZE.x * 0.5, 0, SIZE.x, SIZE.y)
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


## Steht der Punkt (Fuesse des Professors, global) im Feld?
func is_in_field(feet: Vector2) -> bool:
	var local := to_local(feet)
	var head_y := local.y - PLAYER_HEIGHT
	return absf(local.x) <= field_width * 0.5 and head_y >= SIZE.y - 4.0 and head_y <= SIZE.y + reach


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
	_flicker += delta
	queue_redraw()
	if not _on:
		return
	var professor := get_tree().get_first_node_in_group("player") as CharacterBody2D
	if professor == null or professor.get("is_dead") or not professor.has_method("apply_magnet_lift"):
		return
	if not is_in_field(professor.global_position):
		return
	var head_y := to_local(professor.global_position).y - PLAYER_HEIGHT
	var gap := head_y - SIZE.y
	var target := lift_speed if gap > hover_gap + 12.0 else (lift_speed * 0.25 if gap > hover_gap else 0.0)
	professor.apply_magnet_lift(target, lift_accel)


func _draw() -> void:
	var on := _on and not Engine.is_editor_hint()
	draw_texture_rect_region(TEXTURE, Rect2(-SIZE.x * 0.5, 0, SIZE.x, SIZE.y), Rect2(SIZE.x if on else 0.0, 0, SIZE.x, SIZE.y))
	var half := field_width * 0.5
	if Engine.is_editor_hint():
		# Feld als gestrichelter Rahmen
		var y := SIZE.y
		while y < SIZE.y + reach:
			draw_rect(Rect2(-half, y, 1, 3), COLOR_FIELD_DARK)
			draw_rect(Rect2(half - 1, y, 1, 3), COLOR_FIELD_DARK)
			y += 6.0
		draw_rect(Rect2(-half, SIZE.y + reach - 1, field_width, 1), COLOR_FIELD_DARK)
		return
	if not on:
		return
	# Warnung: kurz vor dem Ausschalten flackert das Feld
	var left := on_time - _cycle
	if not always_on and left < warning_time and int(_flicker * 12.0) % 2 == 0:
		return
	# Feldlinien: wandernde Striche nach oben
	for i in 4:
		var x := -half + 6.0 + i * (field_width - 12.0) / 3.0
		var offset := fposmod(_flicker * 60.0 + i * 17.0, 24.0)
		var y := SIZE.y + reach - offset
		while y > SIZE.y:
			draw_rect(Rect2(roundf(x), roundf(y), 1, 8), COLOR_FIELD if i % 2 == 0 else COLOR_FIELD_DARK)
			y -= 24.0
