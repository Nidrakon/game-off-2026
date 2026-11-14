extends Camera2D
## Kamera, die im Physik-Takt einem Ziel (dem Professor) folgt.
## Die Grenzen (limit_*) werden im Level an der Kamera eingestellt.
## Spielgefuehl (Schritt 25): Blick in Laufrichtung (look_ahead), Wackeln
## (shake, z. B. bei harter Landung) und Zoom-Impuls (punch_zoom, beim
## Umschalten der Zeitstufe). Werte setzt der Baustein "Feel" des Professors
## aus data/game_feel.tres.

## Node, dem die Kamera folgt.
@export var target: Node2D
## Versatz zum Ziel; negativ = Kamera etwas hoeher als die Fuesse der Figur.
@export var offset_to_target := Vector2(0, -32)
## Blick in Laufrichtung (Pixel) und wie schnell er nachzieht.
@export var look_ahead := 40.0
@export var look_ahead_speed := 2.5

var _look := 0.0
var _look_dir := 0.0
var _shake_strength := 0.0
var _shake_time := 0.0
var _shake_left := 0.0
var _zoom_punch := 0.0


func _physics_process(delta: float) -> void:
	if target == null:
		return
	var vx: float = target.get("velocity").x if target.get("velocity") != null else 0.0
	if absf(vx) > 30.0:
		_look_dir = signf(vx)
	_look = move_toward(_look, _look_dir * look_ahead, look_ahead * look_ahead_speed * delta)
	global_position = target.global_position + offset_to_target + Vector2(_look, 0)


func _process(delta: float) -> void:
	# Wackeln klingt ab; echte Zeit, damit es auch im Hitstop wirkt
	var real := delta / maxf(Engine.time_scale, 0.001)
	if _shake_left > 0.0:
		_shake_left = maxf(_shake_left - real, 0.0)
		var amount := _shake_strength * (_shake_left / _shake_time)
		offset = Vector2(randf_range(-amount, amount), randf_range(-amount, amount)).round()
	elif offset != Vector2.ZERO:
		offset = Vector2.ZERO
	if _zoom_punch > 0.0:
		_zoom_punch = maxf(_zoom_punch - real * 0.25, 0.0)
		zoom = Vector2.ONE * (1.0 + _zoom_punch)
	elif zoom != Vector2.ONE:
		zoom = Vector2.ONE


## Kamera wackeln lassen (Pixel, Sekunden). Staerkeres Wackeln ersetzt
## schwaecheres.
func shake(strength: float, duration: float) -> void:
	if strength >= _shake_strength * (_shake_left / maxf(_shake_time, 0.001)):
		_shake_strength = strength
		_shake_time = maxf(duration, 0.01)
		_shake_left = _shake_time


## Kurzer Zoom-Impuls (Anteil, z. B. 0,04 = 4 % naeher), klingt ab.
func punch_zoom(amount: float) -> void:
	_zoom_punch = maxf(_zoom_punch, amount)


## Wackelt die Kamera gerade? (fuer Tests)
func is_shaking() -> bool:
	return _shake_left > 0.0


## Kamera sofort aufs Ziel setzen, ohne weich hinzugleiten (z. B. beim
## Levelstart an der Klonstation).
func snap_to_target() -> void:
	if target:
		global_position = target.global_position + offset_to_target + Vector2(_look, 0)
		reset_smoothing()
