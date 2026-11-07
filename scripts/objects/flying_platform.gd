extends AnimatableBody2D
## Fliegende Plattform: faehrt zwischen Startpunkt und Startpunkt + travel hin
## und her, an den Enden weich abgebremst. In der Zeitblase faehrt sie
## langsamer oder schneller. Der Professor kann darauf stehen und mitfahren.
## Die Werte gehoeren zum Level und werden je Plattform im Inspector gesetzt.
##
## Signal-Empfaenger (Doku 2.4): Ausloeser wie die Lichtschranke rufen
## activate(), deactivate() oder toggle() auf. Ausgeschaltet bleibt die
## Plattform an ihrer aktuellen Stelle stehen.

## Strecke vom Startpunkt zum Wendepunkt (Pixel). (160, 0) = 10 Tiles nach rechts.
@export var travel := Vector2(160, 0)
## Dauer einer Fahrt von einem Ende zum anderen bei normalem Tempo (Sekunden).
@export var travel_time := 1.5
## Wo auf der Strecke die Plattform beim Start ist (0 = Startpunkt, 1 = Wendepunkt).
@export_range(0.0, 1.0) var start_offset := 0.0
## Faehrt die Plattform beim Start? Aus = sie wartet auf ein Signal.
@export var active := true
## Pause an jedem Ende der Strecke (Sekunden, laeuft in der Zeitblase mit).
@export var wait_time := 0.0

var _start_position: Vector2
# Fortschritt auf der Strecke: 0 -> 1 = hin, 1 -> 2 = zurueck.
var _phase := 0.0
# Restzeit der Pause am Ende der Strecke.
var _wait_left := 0.0

@onready var _time: TimeAffected = $TimeAffected


func _ready() -> void:
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
	if not active:
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
