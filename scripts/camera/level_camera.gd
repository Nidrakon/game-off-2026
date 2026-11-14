extends Camera2D
## Kamera, die im Physik-Takt einem Ziel (dem Professor) folgt.
## Die Grenzen (limit_*) werden im Level an der Kamera eingestellt.
## Spielgefuehl (Schritt 25): Wackeln (shake, z. B. bei harter Landung).
## Staerke und Dauer setzt der Baustein "Feel" des Professors aus
## data/game_feel.tres. (Vorausblick und Zoom-Impuls am 14.11.2026 auf Wunsch
## des Nutzers wieder entfernt.)

## Node, dem die Kamera folgt.
@export var target: Node2D
## Versatz zum Ziel; negativ = Kamera etwas hoeher als die Fuesse der Figur.
@export var offset_to_target := Vector2(0, -32)

var _shake_strength := 0.0
var _shake_time := 0.0
var _shake_left := 0.0


func _physics_process(_delta: float) -> void:
	if target:
		global_position = target.global_position + offset_to_target


func _process(delta: float) -> void:
	# Wackeln klingt ab; echte Zeit, damit es auch im Hitstop wirkt
	var real := delta / maxf(Engine.time_scale, 0.001)
	if _shake_left > 0.0:
		_shake_left = maxf(_shake_left - real, 0.0)
		var amount := _shake_strength * (_shake_left / _shake_time)
		offset = Vector2(randf_range(-amount, amount), randf_range(-amount, amount)).round()
	elif offset != Vector2.ZERO:
		offset = Vector2.ZERO


## Kamera wackeln lassen (Pixel, Sekunden). Staerkeres Wackeln ersetzt
## schwaecheres.
func shake(strength: float, duration: float) -> void:
	if strength >= _shake_strength * (_shake_left / maxf(_shake_time, 0.001)):
		_shake_strength = strength
		_shake_time = maxf(duration, 0.01)
		_shake_left = _shake_time


## Wackelt die Kamera gerade? (fuer Tests)
func is_shaking() -> bool:
	return _shake_left > 0.0


## Kamera sofort aufs Ziel setzen, ohne weich hinzugleiten (z. B. beim
## Levelstart an der Klonstation).
func snap_to_target() -> void:
	if target:
		global_position = target.global_position + offset_to_target
		reset_smoothing()
