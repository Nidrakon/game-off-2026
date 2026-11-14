extends CharacterBody2D
## Die Spielfigur: Laufen, Springen, Sterben und Erscheinen.
## Alle Zahlenwerte kommen aus der Datendatei (MovementSettings), nicht aus
## dem Code. Liegt in der Gruppe "player", damit Klonstation und andere
## Objekte ihn finden.

## Wird gesendet, wenn der Professor stirbt (die Klonstation startet dann neu).
signal died
## Wird gesendet, wenn ein Sprung beginnt.
signal jumped
## Wird gesendet, wenn er aufsetzt; "fall_speed" = Fallgeschwindigkeit davor
## (Pixel pro Sekunde, fuer Landungs-Sound, Staub und Erschuetterung).
signal landed(fall_speed: float)

## Bewegungswerte (data/professor_movement.tres).
@export var settings: MovementSettings

## Wie schnell das Bild beim Sterben und Erscheinen flackert (Sekunden je Wechsel).
const FLICKER_STEP := 0.05
## Dauer des Flackerns beim Sterben (Sekunden), danach ist er verschwunden.
const DEATH_FLICKER_TIME := 0.5
## Schritt-Sound alle so viele Pixel Laufweg am Boden.
const STEP_DISTANCE := 30.0
## Ab dieser Fallgeschwindigkeit klingt die Landung hart (Pixel pro Sekunde).
const HARD_LANDING_SPEED := 700.0

var _step_left := STEP_DISTANCE
# Laufgeschwindigkeit als Anteil (nach harter Landung kurz weniger, siehe
# slow_down) und wie schnell sie zurueck auf 1 geht (Anteil pro Sekunde).
var _speed_factor := 1.0
var _speed_recover := 0.0

## true, sobald der Professor tot ist; dann reagiert er auf nichts mehr.
var is_dead := false
## true, sobald er das Level durch den Ausgang verlassen hat.
var is_leaving := false

# Restzeit, in der nach dem Verlassen einer Kante noch gesprungen werden darf.
var _coyote_timer := 0.0
# Restzeit, in der ein zu frueh gedrueckter Sprung noch ausgefuehrt wird.
var _jump_buffer_timer := 0.0

# Zieht bzw. stoesst ein Elektromagnet ihn in diesem Physik-Schritt?
# (Richtung, Zielgeschwindigkeit in diese Richtung, Beschleunigung; gesetzt
# von magnet.gd vor dem Physik-Schritt des Professors)
var _magnet_active := false
var _magnet_dir := Vector2.ZERO
var _magnet_target := 0.0
var _magnet_accel := 0.0

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
	if is_dead or is_leaving or _is_invulnerable():
		return
	is_dead = true
	velocity = Vector2.ZERO
	Sound.play("death")
	_start_flicker(DEATH_FLICKER_TIME)
	var save := get_node_or_null("/root/SaveGame")
	if save:
		save.register_death()
	died.emit()


## Verlaesst das Level durch den Ausgang: Steuerung dauerhaft gesperrt,
## unsichtbar (er ist durch die Tuer gegangen), Gefahren wirken nicht mehr.
func leave_level() -> void:
	is_leaving = true
	velocity = Vector2.ZERO
	_controls_locked = INF
	_flicker_left = 0.0
	_sprite.visible = false


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
	if is_dead or is_leaving:
		return
	_controls_locked = maxf(_controls_locked - delta, 0.0)
	_update_timers(delta)
	_apply_gravity(delta)
	_apply_horizontal_movement(delta)
	_handle_jump()
	_apply_magnet(delta)
	var was_on_floor := is_on_floor()
	var fall_speed := velocity.y
	move_and_slide()
	if not was_on_floor and is_on_floor() and fall_speed > 60.0:
		Sound.play("land_hard" if fall_speed >= HARD_LANDING_SPEED else "land", linear_to_db(clampf(fall_speed / 500.0, 0.3, 1.0)))
		landed.emit(fall_speed)
	_update_steps(delta)
	# Animation passend zur Bewegung waehlen (Kind-Node Animator).
	_animator.update(delta)


## Schritt-Sounds nach Laufweg am Boden.
func _update_steps(delta: float) -> void:
	if not is_on_floor() or absf(velocity.x) < 40.0:
		_step_left = STEP_DISTANCE * 0.5
		return
	_step_left -= absf(velocity.x) * delta
	if _step_left <= 0.0:
		_step_left += STEP_DISTANCE
		Sound.play("step")


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


## Vom Elektromagneten jeden Physik-Schritt aufgerufen, solange der
## Professor in seinem Feld steht: Die Geschwindigkeit in Richtung "direction"
## (Einheitsvektor) geht auf "target_speed" (0 = schweben). Zeigt die Kraft
## nach oben, wirkt die Schwerkraft so lange nicht.
func apply_magnet_force(direction: Vector2, target_speed: float, accel: float) -> void:
	_magnet_active = true
	_magnet_dir = direction
	_magnet_target = target_speed
	_magnet_accel = accel


## Wirkung des Magneten nach Schwerkraft und Laufen (siehe apply_magnet_force).
func _apply_magnet(delta: float) -> void:
	if not _magnet_active:
		return
	_magnet_active = false
	var along := velocity.dot(_magnet_dir)
	var wanted := move_toward(along, _magnet_target, _magnet_accel * delta)
	velocity += _magnet_dir * (wanted - along)


func _apply_gravity(delta: float) -> void:
	# Ein Magnet, der nach oben zieht bzw. stoesst, hebt die Schwerkraft auf.
	if _magnet_active and _magnet_dir.y < -0.3:
		return
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
	_speed_factor = move_toward(_speed_factor, 1.0, _speed_recover * delta)
	var target_speed := direction * settings.run_speed * _speed_factor

	var rate: float
	if not is_on_floor():
		rate = settings.air_acceleration
	elif direction != 0.0:
		rate = settings.ground_acceleration
	else:
		rate = settings.ground_deceleration
	# Zieht ein Magnet seitlich, bremst ohne Eingabe nichts dagegen: Der
	# Magnet bestimmt dann die Bewegung zur Seite (mit Eingabe kann man
	# dagegen anlaufen).
	if direction == 0.0 and _magnet_active and absf(_magnet_dir.x) > 0.3:
		rate = 0.0
	velocity.x = move_toward(velocity.x, target_speed, rate * delta)

	# Figur in Laufrichtung drehen (der Sprite schaut nach rechts).
	if direction != 0.0:
		_sprite.flip_h = direction < 0.0


## Bremst ihn kurz (Spielgefuehl, z. B. harte Landung): Laufgeschwindigkeit
## sofort auf "factor", in "recover_time" Sekunden wieder voll.
func slow_down(factor: float, recover_time: float) -> void:
	_speed_factor = clampf(factor, 0.0, 1.0)
	velocity.x *= _speed_factor
	_speed_recover = (1.0 - _speed_factor) / maxf(recover_time, 0.01)


func _handle_jump() -> void:
	# Sprung, wenn er gedrueckt (oder kurz vorher gepuffert) wurde und der
	# Professor am Boden steht oder die Kante gerade erst verlassen hat.
	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = -settings.get_jump_velocity()
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0
		Sound.play("jump")
		jumped.emit()
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
