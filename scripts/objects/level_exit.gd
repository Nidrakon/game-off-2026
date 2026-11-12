@tool
extends Area2D
## Ausgang eines Levels (Doku 2.9): Schiebetuer mit blinkendem Pfeil nach
## oben (das naechste Level liegt eine Etage hoeher). Laeuft der Professor
## hinein, geht die Tuer auf, er verschwindet darin und das naechste Level
## aus data/level_order.tres wird geladen.
## Der Node liegt unten in der Mitte der Tuer (auf den Boden stellen).

## Wird gesendet, wenn der Professor durch den Ausgang geht.
signal entered_exit

## Optional: statt des naechsten Levels aus der Reihenfolge diese Szene
## laden (z. B. fuer Abzweigungen oder Tests). Leer = Reihenfolge.
@export_file("*.tscn") var target_level := ""

const TEXTURE := preload("res://graphics/sprites/objects/object_level_exit_placeholder.png")
const SIZE := Vector2(32, 64)
## Ausloesebereich: Mitte der Tuer, etwas schmaler als die Oeffnung.
const TRIGGER_SIZE := Vector2(12, 48)
## Blinktakt des Pfeils (Sekunden).
const BLINK_TIME := 0.4
# Farben aus der Palette: Pfeil hell und dunkel.
const COLOR_ARROW := Color("1ebc73")
const COLOR_ARROW_DARK := Color("165a4c")

var _used := false
var _blink_left := BLINK_TIME
var _blink_on := true


func _ready() -> void:
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = TRIGGER_SIZE
	shape.shape = rect
	shape.position = Vector2(0, -TRIGGER_SIZE.y * 0.5)
	add_child(shape)
	if Engine.is_editor_hint():
		return
	body_entered.connect(_on_body_entered)


## Ist der Professor schon hindurchgegangen?
func is_used() -> bool:
	return _used


func _on_body_entered(body: Node2D) -> void:
	if _used or not body.is_in_group("player") or body.is_dead:
		return
	_used = true
	queue_redraw()
	body.leave_level()
	entered_exit.emit()
	if target_level != "":
		LevelFlow.go_to(target_level)
	else:
		LevelFlow.go_to_next()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_blink_left -= delta
	if _blink_left <= 0.0:
		_blink_left = BLINK_TIME
		_blink_on = not _blink_on
		queue_redraw()


func _draw() -> void:
	var frame := 1 if _used else 0
	draw_texture_rect_region(TEXTURE, Rect2(-SIZE.x * 0.5, -SIZE.y, SIZE.x, SIZE.y), Rect2(frame * SIZE.x, 0, SIZE.x, SIZE.y))
	# Pfeil nach oben im Lampenfeld (Mitte bei x = 0, y = -57)
	var color := COLOR_ARROW if (_blink_on or _used or Engine.is_editor_hint()) else COLOR_ARROW_DARK
	draw_rect(Rect2(-1, -60, 2, 1), color)
	draw_rect(Rect2(-2, -59, 4, 1), color)
	draw_rect(Rect2(-3, -58, 6, 1), color)
	draw_rect(Rect2(-1, -57, 2, 3), color)
