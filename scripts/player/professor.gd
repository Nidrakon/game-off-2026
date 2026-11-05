extends CharacterBody2D
## Die Spielfigur: Laufen und Springen.
## Alle Zahlenwerte kommen aus der Datendatei (MovementSettings), nicht aus
## dem Code.

## Bewegungswerte (data/professor_movement.tres).
@export var settings: MovementSettings

# Restzeit, in der nach dem Verlassen einer Kante noch gesprungen werden darf.
var _coyote_timer := 0.0
# Restzeit, in der ein zu frueh gedrueckter Sprung noch ausgefuehrt wird.
var _jump_buffer_timer := 0.0

@onready var _sprite: Sprite2D = $Sprite


func _physics_process(delta: float) -> void:
	_update_timers(delta)
	_apply_gravity(delta)
	_apply_horizontal_movement(delta)
	_handle_jump()
	move_and_slide()


func _update_timers(delta: float) -> void:
	# Am Boden ist Springen immer erlaubt; danach laeuft die Coyote Time ab.
	if is_on_floor():
		_coyote_timer = settings.coyote_time
	else:
		_coyote_timer = maxf(_coyote_timer - delta, 0.0)

	if Input.is_action_just_pressed("jump"):
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
	var direction := Input.get_axis("move_left", "move_right")
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
		if not Input.is_action_pressed("jump"):
			velocity.y *= settings.jump_release_multiplier

	# Taste beim Steigen losgelassen: Sprung abkuerzen (kleiner Sprung).
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= settings.jump_release_multiplier
