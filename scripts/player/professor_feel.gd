extends Node
## Spielgefuehl des Professors (Doku 2.2, Schritt 25): Kind-Node "Feel".
## - Squash und Stretch: Streckung beim Absprung, Stauchung beim Landen (je
##   nach Fallgeschwindigkeit), federt zurueck.
## - Gewicht: harte Landung bremst kurz und laesst den Boden beben
##   (Kamerawackeln), Staubwoelkchen.
## - Staub beim Absprung und beim scharfen Richtungswechsel.
## - Tod und Einsammeln: kurzer Hitstop und Wackeln.
## - Zoom-Impuls der Kamera beim Umschalten der Zeitstufe; Blick in
##   Laufrichtung (Kamera).
## Werte in data/game_feel.tres. Gruppe "game_feel" (z. B. fuer on_pickup()).

@export var settings: GameFeelSettings = preload("res://data/game_feel.tres")

var _last_vx := 0.0
var _hitstop_running := false

@onready var _professor: CharacterBody2D = get_parent()
@onready var _sprite: Node2D = get_parent().get_node("Sprite")


func _ready() -> void:
	add_to_group("game_feel")
	_professor.jumped.connect(_on_jumped)
	_professor.landed.connect(_on_landed)
	_professor.died.connect(_on_died)
	var bubble := _professor.get_node_or_null("TimeBubble")
	if bubble:
		bubble.stage_changed.connect(_on_stage_changed)
	_configure_camera.call_deferred()


func _process(delta: float) -> void:
	# Zurueckfedern in die Grundform
	var k := clampf(delta / maxf(settings.return_time, 0.01) * 4.0, 0.0, 1.0)
	_sprite.scale = _sprite.scale.lerp(Vector2.ONE, k)


func _physics_process(_delta: float) -> void:
	# Scharfer Richtungswechsel am Boden: Staub
	var vx := _professor.velocity.x
	if _professor.is_on_floor() and absf(_last_vx) > 150.0 and signf(vx) != signf(_last_vx) and vx != 0.0:
		_dust(settings.turn_dust, 70.0)
	_last_vx = vx


## Aktuelle Form des Sprites (fuer Tests).
func get_squash() -> Vector2:
	return _sprite.scale


## Von aussen: etwas eingesammelt (z. B. Schrotthaufen).
func on_pickup() -> void:
	_shake(settings.pickup_shake)
	hitstop(settings.pickup_hitstop)


## Kurzes Einfrieren des Spiels (echte Sekunden).
func hitstop(duration: float) -> void:
	if duration <= 0.0 or _hitstop_running:
		return
	_hitstop_running = true
	Engine.time_scale = 0.05
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0
	_hitstop_running = false


func _on_jumped() -> void:
	_sprite.scale = settings.jump_stretch
	_dust(settings.jump_dust, 45.0)


func _on_landed(fall_speed: float) -> void:
	if fall_speed < settings.land_squash_min_speed:
		return
	var strength := clampf((fall_speed - settings.land_squash_min_speed) / maxf(_professor.settings.max_fall_speed - settings.land_squash_min_speed, 1.0), 0.0, 1.0)
	_sprite.scale = Vector2.ONE.lerp(settings.land_squash, clampf(strength * 1.6, 0.25, 1.0))
	_dust(roundi(lerpf(2.0, float(settings.land_dust), strength)), lerpf(40.0, 110.0, strength))
	if fall_speed >= settings.hard_landing_speed:
		_shake(settings.land_shake * strength)
		if _professor.has_method("slow_down"):
			_professor.slow_down(settings.hard_landing_speed_factor, settings.hard_landing_recover_time)


func _on_died() -> void:
	_shake(settings.death_shake)
	hitstop(settings.death_hitstop)


func _on_stage_changed(_stage: int) -> void:
	var camera := get_viewport().get_camera_2d()
	if camera and camera.has_method("punch_zoom"):
		camera.punch_zoom(settings.stage_zoom_punch)


func _dust(count: int, speed: float) -> void:
	var scene := get_tree().current_scene
	if count > 0 and scene:
		DustPuff.spawn(scene, _professor.global_position, count, speed)


func _shake(strength: float) -> void:
	var camera := get_viewport().get_camera_2d()
	if camera and camera.has_method("shake") and strength > 0.0:
		camera.shake(strength, settings.shake_time)


func _configure_camera() -> void:
	var camera := get_viewport().get_camera_2d()
	if camera and "look_ahead" in camera:
		camera.look_ahead = settings.look_ahead
		camera.look_ahead_speed = settings.look_ahead_speed
