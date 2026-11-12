extends CharacterBody2D
## Die Spielfigur: Laufen, Springen, Sterben und Erscheinen.
## Alle Zahlenwerte kommen aus der Datendatei (MovementSettings), nicht aus
## dem Code. Liegt in der Gruppe "player", damit Klonstation und andere
## Objekte ihn finden.

## Wird gesendet, wenn der Professor stirbt (die Klonstation startet dann neu).
signal died

## Bewegungswerte (data/professor_movement.tres).
@export var settings: MovementSettings

## Wie schnell das Bild beim Sterben und Erscheinen flackert (Sekunden je Wechsel).
const FLICKER_STEP := 0.05
## Dauer des Flackerns beim Sterben (Sekunden), danach ist er verschwunden.
const DEATH_FLICKER_TIME := 0.5

## true, sobald der Professor tot ist; dann reagiert er auf nichts mehr.
var is_dead := false

# Restzeit, in der nach dem Verlassen einer Kante noch gesprungen werden darf.
var _coyote_timer := 0.0
# Restzeit, in der ein zu frueh gedrueckter Sprung noch ausgefuehrt wird.
var _jump_buffer_timer := 0.0

# Restzeit, in der die Steuerung gesperrt ist (beim Erscheinen).
var _controls_locked := 0.0
# Restzeit des Flackerns und Zeit bis zum naechsten Wechsel.
var _flicker_left := 0.0
var _flicker_step_left := 0.0

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _animator: Node = $Animator


func _ready() -> void:
	add_to_group("player")


## Toedlich getroffen: Bewegung stoppt, das Bild flackert und verschwindet.
func die() -> void:
	if is_dead or _is_invulnerable():
		return
	is_dead = true
	velocity = Vector2.ZERO
	_start_flicker(DEATH_FLICKER_TIME)
	died.emit()


## Erscheinen in der Klonstation: kurz flackern, Steuerung so lange gesperrt.
func play_spawn(duration: float) -> void:
	velocity = Vector2.ZERO
	_controls_locked = duration
	_start_flicker(duration)


func _process(delta: float) -> void:
	if _flicker_left <= 0.0:
		return
	_flicker_left -= delta
	_flicker_step_left -= delta
	if _flicker_step_left <= 0.0:
		_flicker_step_left = FLICKER_STEP
		_sprite.visible = not _sprite.visible
	if _flicker_left <= 0.0:
		# Ende: beim Sterben verschwunden, beim Erscheinen sichtbar.
		_sprite.visible = not is_dead


func _start_flicker(duration: float) -> void:
	_flicker_left = duration
	_flicker_step_left = FLICKER_STEP


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	_controls_locked = maxf(_controls_locked - delta, 0.0)
	_update_timers(delta)
	_apply_gravity(delta)
	_apply_horizontal_movement(delta)
	_handle_jump()
	move_and_slide()
	# Animation passend zur Bewegung waehlen (Kind-Node Animator).
	_animator.update(delta)


func _update_timers(delta: float) -> void:
	# Am Boden ist Springen immer erlaubt; danach laeuft die Coyote Time ab.
	if is_on_floor():
		_coyote_timer = settings.coyote_time
	else:
		_coyote_timer = maxf(_coyote_timer - delta, 0.0)

	if _controls_enabled() and Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = settings.jump_buffer_time
	else:
		_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)


func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		return
	# Beim Fallen staerkere Schwerkraft: der Sprung fuehlt sich knackiger an.
	var gravity := settings.get_rise_gravity()
	if velocity.y > 0.0:
		gravity *= settings.fall_gravity_multiplier
	velocity.y = minf(velocity.y + gravity * delta, settings.max_fall_speed)


func _apply_horizontal_movement(delta: float) -> void:
	var direction := 0.0
	if _controls_enabled():
		direction = Input.get_axis("move_left", "move_right")
	var target_speed := direction * settings.run_speed

	var rate: float
	if not is_on_floor():
		rate = settings.air_acceleration
	elif direction != 0.0:
		rate = settings.ground_acceleration
	else:
		rate = settings.ground_deceleration
	velocity.x = move_toward(velocity.x, target_speed, rate * delta)

	# Figur in Laufrichtung drehen (der Sprite schaut nach rechts).
	if direction != 0.0:
		_sprite.flip_h = direction < 0.0


func _handle_jump() -> void:
	# Sprung, wenn er gedrueckt (oder kurz vorher gepuffert) wurde und der
	# Professor am Boden steht oder die Kante gerade erst verlassen hat.
	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = -settings.get_jump_velocity()
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0
		# Gepufferter Sprung, Taste aber schon wieder losgelassen: kleiner Sprung.
		if not (_controls_enabled() and Input.is_action_pressed("jump")):
			velocity.y *= settings.jump_release_multiplier

	# Taste beim Steigen losgelassen: Sprung abkuerzen (kleiner Sprung).
	if _controls_enabled() and Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= settings.jump_release_multiplier


## Schalter "Unverwundbar" im Entwickler-Menue (falls vorhanden).
func _is_invulnerable() -> bool:
	var dev_menu := get_node_or_null("/root/DevMenu")
	return dev_menu != null and dev_menu.invulnerable


func _controls_enabled() -> bool:
	return _controls_locked <= 0.0
