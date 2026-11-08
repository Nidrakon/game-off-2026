extends StaticBody2D
## Projektil-Werfer: feuert in festem Takt Projektile nach links oder rechts.
## Sein Takt laeuft in der Zeitblase langsamer oder schneller.
## Signal-Empfaenger (Doku 2.4): activate(), deactivate(), toggle().
## Der Node liegt in der Mitte des Werfers. Die Werte gehoeren zum Level und
## werden je Werfer im Inspector gesetzt.

enum Direction { RIGHT, LEFT }

const PROJECTILE_SCENE := preload("res://scenes/objects/projectile.tscn")
## Abstand Mitte Werfer -> Mitte neues Projektil (halbe Breiten + 1 Pixel).
const MUZZLE_DISTANCE := 49.0

## Schussrichtung.
@export var direction := Direction.RIGHT:
	set(value):
		direction = value
		if is_node_ready():
			_sprite.flip_h = direction == Direction.LEFT
## Zeit zwischen zwei Schuessen bei normalem Tempo (Sekunden).
@export var fire_interval := 4.0
## Zeit bis zum ersten Schuss (Sekunden). Damit lassen sich Werfer versetzt
## einstellen, z. B. fuer Synchron-Raetsel.
@export var first_shot_delay := 1.0
## Geschwindigkeit der Projektile bei normalem Tempo (Pixel pro Sekunde).
@export var projectile_speed := 120.0
## Weiteste Flugstrecke der Projektile (Pixel).
@export var max_distance := 4000.0
## Feuert der Werfer beim Start? Aus = er wartet auf ein Signal.
@export var active := true

var _time_left := 0.0

@onready var _time: TimeAffected = $TimeAffected
@onready var _sprite: Sprite2D = $Sprite


func _ready() -> void:
	_sprite.flip_h = direction == Direction.LEFT
	_time_left = first_shot_delay


## Signal-Empfaenger: Werfer feuert.
func activate() -> void:
	active = true


## Signal-Empfaenger: Werfer stoppt.
func deactivate() -> void:
	active = false


## Signal-Empfaenger: an <-> aus.
func toggle() -> void:
	active = not active


func _physics_process(delta: float) -> void:
	if not active:
		return
	_time_left -= delta * _time.time_scale
	if _time_left <= 0.0:
		_time_left += fire_interval
		_fire()


func _fire() -> void:
	var sign_x := -1.0 if direction == Direction.LEFT else 1.0
	var projectile := PROJECTILE_SCENE.instantiate()
	projectile.direction = sign_x
	projectile.speed = projectile_speed
	projectile.max_distance = max_distance
	# Neben den Werfer in den Level haengen: Der Werfer bleibt davon unberuehrt.
	get_parent().add_child(projectile)
	projectile.global_position = global_position + Vector2(sign_x * MUZZLE_DISTANCE, 0.0)
	projectile.add_collision_exception_with(self)
	projectile.reset_physics_interpolation()
