extends Node
## Waehlt die Animation des Professors (Kind-Node "Animator" im Professor).
## Der Professor ruft update() nach jeder Bewegung auf.
##
## - Am Boden: "run", wenn er sich bewegt, sonst "idle".
## - Sprung ("jump"): Bild nach der senkrechten Geschwindigkeit (Steigen,
##   Hoehepunkt, Fallen). Absprung- und Landungsbild stehen eine kurze,
##   einstellbare Zeit. Faellt er ohne Sprung von einer Kante, gibt es kein
##   Absprungbild.
## Alle Werte: data/professor_animation.tres.

## Einstellungen (data/professor_animation.tres).
@export var settings: ProfessorAnimationSettings

var _was_on_floor := true
# Restzeit des Absprung- bzw. Landungsbilds.
var _takeoff_left := 0.0
var _landing_left := 0.0

@onready var _body: CharacterBody2D = get_parent()
@onready var _sprite: AnimatedSprite2D = get_parent().get_node("Sprite")


func update(delta: float) -> void:
	var on_floor := _body.is_on_floor()
	if on_floor != _was_on_floor:
		if on_floor:
			_landing_left = settings.landing_time
		else:
			# Nur ein echter Absprung (nach oben) zeigt das Absprungbild.
			_takeoff_left = settings.takeoff_time if _body.velocity.y < 0.0 else 0.0
		_was_on_floor = on_floor
	_takeoff_left = maxf(_takeoff_left - delta, 0.0) if not on_floor else 0.0

	if not on_floor:
		_landing_left = 0.0
		_show_jump_frame(_air_frame())
		return
	if _landing_left > 0.0:
		_landing_left -= delta
		_show_jump_frame(settings.landing_frame)
		return
	var target := &"run" if absf(_body.velocity.x) > settings.run_min_speed else &"idle"
	if _sprite.animation != target or not _sprite.is_playing():
		_sprite.play(target)


## Bild in der Luft: Absprung, Steigen, Hoehepunkt oder Fallen.
func _air_frame() -> int:
	if _takeoff_left > 0.0:
		return settings.takeoff_frame
	var vy := _body.velocity.y
	if absf(vy) <= settings.apex_speed:
		return settings.apex_frame
	return settings.rise_frame if vy < 0.0 else settings.fall_frame


## Zeigt ein festes Bild der Sprung-Animation (ohne Abspielen nach Zeit).
func _show_jump_frame(frame: int) -> void:
	if not _sprite.sprite_frames.has_animation(&"jump"):
		return
	frame = clampi(frame, 0, _sprite.sprite_frames.get_frame_count(&"jump") - 1)
	if _sprite.animation != &"jump":
		_sprite.animation = &"jump"
	if _sprite.is_playing():
		_sprite.pause()
	if _sprite.frame != frame:
		_sprite.frame = frame
