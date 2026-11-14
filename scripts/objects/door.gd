extends AnimatableBody2D
## Tuer: gleitet um "travel" auf und wieder zu. Geschlossen haelt sie den
## Professor und Projektile auf (Ebene 1). In der Zeitblase bewegt sie sich
## langsamer oder schneller. Steht beim Schliessen jemand im Weg, wartet sie.
##
## Signal-Empfaenger (Doku 2.4): activate() = oeffnen, deactivate() = schliessen,
## toggle() = umschalten.
##
## Der Node liegt in der Mitte der geschlossenen Tuer. Sie liegt hinter den
## Tiles, verschwindet also beim Oeffnen in der Decke, wenn dort Tiles sind.
## Die Werte gehoeren zum Level und werden je Tuer im Inspector gesetzt.

## Weg von geschlossen nach offen (Pixel). (0, -80) = um die eigene Hoehe nach oben.
@export var travel := Vector2(0, -80)
## Dauer des Oeffnens bzw. Schliessens bei normalem Tempo (Sekunden).
@export var move_time := 0.4
## Ist die Tuer beim Start offen?
@export var start_open := false

var _closed_position: Vector2
# Stellung: 0 = geschlossen, 1 = offen.
var _progress := 0.0
var _target := 0.0

@onready var _time: TimeAffected = $TimeAffected


func _ready() -> void:
	_closed_position = position
	if start_open:
		_progress = 1.0
		_target = 1.0
		position = _position_at(_progress)
		reset_physics_interpolation()


## Signal-Empfaenger: Tuer oeffnet.
func activate() -> void:
	if _target != 1.0:
		Sound.play_at("door_open", global_position)
	_target = 1.0


## Signal-Empfaenger: Tuer schliesst.
func deactivate() -> void:
	if _target != 0.0:
		Sound.play_at("door_close", global_position)
	_target = 0.0


## Signal-Empfaenger: offen <-> geschlossen.
func toggle() -> void:
	if _target == 1.0:
		deactivate()
	else:
		activate()


func _physics_process(delta: float) -> void:
	if _progress == _target:
		return
	# Die Zeit der Tuer laeuft mit dem Tempo aus der Zeitblase.
	var new_progress := move_toward(_progress, _target, delta * _time.time_scale / move_time)
	var new_position := _position_at(new_progress)
	# Beim Schliessen nicht in den Professor oder ein Projektil hineinfahren,
	# sonst wuerde er eingeklemmt. Die Tuer prueft dafuer die Ebenen 2 und 3.
	if _target < _progress and test_move(global_transform, new_position - position):
		return
	_progress = new_progress
	position = new_position


func _position_at(progress: float) -> Vector2:
	return _closed_position + travel * progress
