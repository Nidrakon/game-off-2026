@tool
extends AnimatableBody2D
## Fliegende Plattform: faehrt zwischen Startpunkt und Startpunkt + travel hin
## und her, an den Enden weich abgebremst. In der Zeitblase faehrt sie
## langsamer oder schneller. Der Professor kann darauf stehen und mitfahren.
## Von unten kann man durch sie hindurchspringen (Einweg-Kollision).
## Die Werte gehoeren zum Level und werden je Plattform im Inspector gesetzt.
##
## Signal-Empfaenger (Doku 2.4): Ausloeser wie die Lichtschranke rufen
## activate(), deactivate() oder toggle() auf. Ausgeschaltet bleibt die
## Plattform an ihrer aktuellen Stelle stehen.
##
## Im Editor zeigt sie ihre Strecke: gestrichelte Linie zum Wendepunkt, dort
## ein Umriss der Plattform, und eine Raute, wo sie beim Levelstart steht
## (start_offset). Im Spiel ist davon nichts zu sehen.

## Strecke vom Startpunkt zum Wendepunkt (Pixel). (160, 0) = 10 Tiles nach rechts.
@export var travel := Vector2(160, 0):
	set(value):
		travel = value
		queue_redraw()
## Dauer einer Fahrt von einem Ende zum anderen bei normalem Tempo (Sekunden).
@export var travel_time := 1.5
## Wo auf der Strecke die Plattform beim Start ist (0 = Startpunkt, 1 = Wendepunkt).
@export_range(0.0, 1.0) var start_offset := 0.0:
	set(value):
		start_offset = value
		queue_redraw()
## Faehrt die Plattform beim Start? Aus = sie wartet auf ein Signal.
@export var active := true
## Pause an jedem Ende der Strecke (Sekunden, laeuft in der Zeitblase mit).
@export var wait_time := 0.0

## Groesse der Plattform (fuer die Anzeige im Editor).
const SIZE := Vector2(64, 16)
# Farben aus der Palette fuer die Anzeige im Editor: Strecke, Wendepunkt, Start.
const COLOR_PATH := Color("f9c22b")
const COLOR_GHOST := Color("4d9be6")
const COLOR_START := Color("1ebc73")

var _start_position: Vector2
# Fortschritt auf der Strecke: 0 -> 1 = hin, 1 -> 2 = zurueck.
var _phase := 0.0
# Restzeit der Pause am Ende der Strecke.
var _wait_left := 0.0

@onready var _time: TimeAffected = $TimeAffected


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_start_position = position
	_phase = start_offset
	position = _position_at(_phase)


## Signal-Empfaenger: Plattform faehrt los.
func activate() -> void:
	active = true


## Signal-Empfaenger: Plattform bleibt stehen.
func deactivate() -> void:
	active = false


## Signal-Empfaenger: an <-> aus.
func toggle() -> void:
	active = not active


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or not active:
		return
	# Die Zeit der Plattform laeuft mit dem Tempo aus der Zeitblase.
	var step := delta * _time.time_scale
	if _wait_left > 0.0:
		_wait_left -= step
		return
	var new_phase := _phase + step / travel_time
	# Am Wendepunkt (1) bzw. zurueck am Startpunkt (2 = 0) kurz warten.
	if _phase < 1.0 and new_phase >= 1.0:
		new_phase = 1.0
		_wait_left = wait_time
	elif new_phase >= 2.0:
		new_phase = 0.0
		_wait_left = wait_time
	_phase = new_phase
	position = _position_at(_phase)


func _position_at(phase: float) -> Vector2:
	# Kosinus-Kurve: 0 -> 1 -> 0, an den Enden langsam, in der Mitte schnell.
	var t := (1.0 - cos(phase * PI)) * 0.5
	return _start_position + travel * t


## Anzeige der Strecke, nur im Editor.
func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	var center := SIZE * 0.5
	# Gestrichelte Linie von der Mitte am Startpunkt zur Mitte am Wendepunkt
	var length := travel.length()
	if length > 0.0:
		var dir := travel / length
		var d := 0.0
		while d < length:
			draw_line(center + dir * d, center + dir * minf(d + 4.0, length), COLOR_PATH, 1.0)
			d += 8.0
	# Umriss der Plattform am Wendepunkt
	var ghost := Rect2(travel, SIZE)
	draw_rect(Rect2(ghost.position, Vector2(ghost.size.x, 1)), COLOR_GHOST)
	draw_rect(Rect2(ghost.position.x, ghost.end.y - 1, ghost.size.x, 1), COLOR_GHOST)
	draw_rect(Rect2(ghost.position, Vector2(1, ghost.size.y)), COLOR_GHOST)
	draw_rect(Rect2(ghost.end.x - 1, ghost.position.y, 1, ghost.size.y), COLOR_GHOST)
	# Raute: Position beim Levelstart (start_offset)
	var t := (1.0 - cos(start_offset * PI)) * 0.5
	var at := (center + travel * t).round()
	for i in 4:
		draw_rect(Rect2(at.x - 3 + i, at.y - i, 7 - i * 2, 1), COLOR_START)
		draw_rect(Rect2(at.x - 3 + i, at.y + i, 7 - i * 2, 1), COLOR_START)
