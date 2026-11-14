@tool
extends Node2D
## Dampfaustritt (Doku 2.9, Rohre): stoesst im Takt Dampfwolken aus, z. B. an
## einem Rohrende. Reine Dekoration, keine Kollision. Der Takt laeuft in der
## Zeitblase langsamer oder schneller mit (Regel 17).
## Der Node liegt an der Austrittsstelle; "direction" gibt die Richtung an.

## Richtung des Dampfs.
enum Direction { UP, RIGHT, DOWN, LEFT }

@export var direction := Direction.UP:
	set(value):
		direction = value
		queue_redraw()
@export_group("Takt")
## Abstand zwischen zwei Stoessen (Sekunden, bei normalem Tempo).
@export_range(0.2, 20.0, 0.05, "or_greater") var interval := 2.0
## So lange dauert ein Stoss (Sekunden).
@export_range(0.1, 10.0, 0.05, "or_greater") var puff_time := 0.8
## Versatz im Takt beim Levelstart (Sekunden), fuer mehrere Austritte.
@export_range(0.0, 20.0, 0.05, "or_greater") var start_offset := 0.0
@export_group("")
## Wie weit der Dampf steigt (Pixel).
@export var reach := 28.0
## Wolken pro Stoss.
const PUFFS := 5
const DIRECTIONS := [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
# Farben aus der Palette: Kern, Rand, verblassend.
const COLOR_CORE := Color("ffffff")
const COLOR_EDGE := Color("c7dcd0")
const COLOR_FADE := Color("9babb2")

var _time := 0.0
var _was_puffing := false

@onready var _time_affected: TimeAffected = $TimeAffected


func _ready() -> void:
	_time = start_offset


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_time += delta * _time_affected.time_scale
	queue_redraw()
	var puffing := is_puffing()
	if puffing and not _was_puffing:
		Sound.play_at("steam_hiss", global_position, 0.0, clampf(_time_affected.time_scale, 0.4, 2.0))
	_was_puffing = puffing


## Stoesst gerade Dampf aus?
func is_puffing() -> bool:
	return fposmod(_time, interval) < puff_time


func _draw() -> void:
	# Im Editor eine Wolke in halber Hoehe als Vorschau.
	var t := fposmod(_time, interval) if not Engine.is_editor_hint() else puff_time * 0.5
	if t >= puff_time:
		return
	var dir: Vector2 = DIRECTIONS[direction]
	var side := dir.orthogonal()
	for i in PUFFS:
		# Jede Wolke startet etwas spaeter und steigt; Groesse waechst, Farbe verblasst.
		var age := t / puff_time - float(i) / PUFFS * 0.6
		if age < 0.0 or age > 1.0:
			continue
		var wobble := sin(float(i) * 2.3 + age * 6.0) * 3.0
		var center := (dir * reach * age + side * wobble).round()
		var radius := roundf(2.0 + age * 4.0)
		var color := COLOR_CORE if age < 0.35 else (COLOR_EDGE if age < 0.7 else COLOR_FADE)
		draw_rect(Rect2(center - Vector2(radius, radius - 1), Vector2(radius * 2, radius * 2 - 2)), color)
		draw_rect(Rect2(center - Vector2(radius - 1, radius), Vector2(radius * 2 - 2, radius * 2)), color)
