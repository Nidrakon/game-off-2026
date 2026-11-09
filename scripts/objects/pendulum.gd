@tool
extends Node2D
## Pendel bzw. rotierende Gefahr (Doku 2.4): eine Stachelkugel an einer
## Stange. Sie schwingt hin und her (SWING) oder dreht sich im Kreis (ROTATE).
## Nur die Kugel ist toedlich (Kind-Node Weight mit hazard.gd), die Stange
## nicht. In der Zeitblase bewegt sie sich langsamer oder schneller.
##
## Der Node ist der Aufhaengepunkt. Im Editor sieht man das Pendel sofort an
## seiner Startstellung (@tool). Die Werte gehoeren zum Level und werden je
## Pendel im Inspector gesetzt.

enum Mode { SWING, ROTATE }

## Schwingen (hin und her) oder Drehen (im Kreis).
@export var mode := Mode.SWING:
	set(value):
		mode = value
		_reset_motion()
## Abstand Aufhaengepunkt -> Mitte der Kugel (Pixel).
@export var length := 96.0:
	set(value):
		length = value
		_reset_motion()
## Nur beim Schwingen: groesster Ausschlag zu jeder Seite (Grad, 0 = senkrecht).
@export_range(0.0, 180.0) var amplitude := 45.0:
	set(value):
		amplitude = value
		_reset_motion()
## Dauer einer ganzen Schwingung (hin und zurueck) bzw. einer ganzen Drehung
## bei normalem Tempo (Sekunden).
@export var period := 1.6
## Stellung beim Start (0 bis 1, Anteil von period). Schwingen: 0 = unten in
## der Mitte, 0,25 = ganz rechts, 0,75 = ganz links. Drehen: 0 = unten.
## Damit lassen sich mehrere Pendel gegeneinander versetzen.
@export_range(0.0, 1.0) var start_phase := 0.0:
	set(value):
		start_phase = value
		_reset_motion()
## Nur beim Drehen: im Uhrzeigersinn (an) oder dagegen (aus).
@export var clockwise := true:
	set(value):
		clockwise = value
		_reset_motion()

# Farben aus der Palette: Stange (Rand, Kern) und Aufhaengung.
const COLOR_ROD_EDGE := Color("2e222f")
const COLOR_ROD_CORE := Color("7f708a")
const COLOR_PIVOT := Color("9babb2")

# Fortschritt der Bewegung in ganzen Schwingungen bzw. Drehungen.
var _phase := 0.0
# Winkel im letzten und im aktuellen Physik-Schritt (fuer ein ruckelfreies Bild).
var _previous_angle := 0.0
var _angle := 0.0

@onready var _weight: Area2D = $Weight
@onready var _sprite: Sprite2D = $Sprite
@onready var _time: TimeAffected = $TimeAffected


func _ready() -> void:
	_reset_motion()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	# Die Zeit des Pendels laeuft mit dem Tempo aus der Zeitblase.
	_phase += delta * _time.time_scale / period
	_previous_angle = _angle
	_angle = _angle_at(_phase)
	# Die toedliche Kugel steht immer genau an der Stelle aus der Physik.
	_weight.position = _offset_at(_angle)


func _process(_delta: float) -> void:
	# Bild zwischen zwei Physik-Schritten weich ueberblenden (wie die
	# Physik-Interpolation bei den anderen Objekten). Stange, Kugel und
	# Markierung nutzen denselben Winkel und passen so immer zusammen.
	var fraction := 1.0 if Engine.is_editor_hint() else Engine.get_physics_interpolation_fraction()
	var shown := lerp_angle(_previous_angle, _angle, fraction)
	# Die Kugel dreht sich nicht mit, sonst passen Licht und Schatten nicht.
	_sprite.position = _offset_at(shown)
	_time.position = _sprite.position
	queue_redraw()


## Winkel der Stange (Bogenmass, 0 = senkrecht nach unten, positiv = im
## Uhrzeigersinn).
func _angle_at(phase: float) -> float:
	if mode == Mode.ROTATE:
		return phase * TAU * (1.0 if clockwise else -1.0)
	# Schwingen: Sinus-Kurve, aussen langsam, unten am schnellsten. Das Minus
	# sorgt dafuer, dass 0,25 rechts ist.
	return -deg_to_rad(amplitude) * sin(phase * TAU)


func _offset_at(angle: float) -> Vector2:
	return Vector2(0.0, length).rotated(angle)


func _reset_motion() -> void:
	_phase = start_phase
	_angle = _angle_at(_phase)
	_previous_angle = _angle
	if is_node_ready():
		_weight.position = _offset_at(_angle)
		_process(0.0)


func _draw() -> void:
	var end := _sprite.position if is_node_ready() else _offset_at(_angle)
	# Stange: 3 px dunkler Rand, 1 px heller Kern.
	draw_line(Vector2.ZERO, end, COLOR_ROD_EDGE, 3.0)
	draw_line(Vector2.ZERO, end, COLOR_ROD_CORE, 1.0)
	# Aufhaengung: kleiner Bolzen.
	draw_rect(Rect2(-3, -3, 6, 6), COLOR_ROD_EDGE)
	draw_rect(Rect2(-2, -2, 4, 4), COLOR_PIVOT)
