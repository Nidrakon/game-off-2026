extends StaticBody2D
## Projektil-Werfer: feuert in festem Takt Projektile nach links oder rechts.
## Sein Takt laeuft in der Zeitblase langsamer oder schneller.
## Ein Ladebalken im Gehaeuse fuellt sich bis zum naechsten Schuss; ist er
## voll, feuert der Werfer. Er laeuft mit demselben Takt (auch in der Blase).
## Signal-Empfaenger (Doku 2.4): activate(), deactivate(), toggle().
## Der Node liegt in der Mitte des Werfers. Die Werte gehoeren zum Level und
## werden je Werfer im Inspector gesetzt.

enum Direction { RIGHT, LEFT }

const PROJECTILE_SCENE := preload("res://scenes/objects/projectile.tscn")
## Abstand Mitte Werfer -> Mitte neues Projektil (halbe Breiten + 1 Pixel).
const MUZZLE_DISTANCE := 49.0
## Fuellflaeche des Ladebalkens relativ zur Werfer-Mitte (Muendung rechts).
## Bei Schussrichtung links wird sie gespiegelt wie das Bild.
const BAR_RECT := Rect2(-7, -11, 6, 22)
## Farben aus der Palette: Fuellung und heller oberer Rand der Fuellung.
const COLOR_BAR := Color("f9c22b")
const COLOR_BAR_TOP := Color("fbff86")

## Schussrichtung.
@export var direction := Direction.RIGHT:
	set(value):
		direction = value
		if is_node_ready():
			_sprite.flip_h = direction == Direction.LEFT
			_bar.queue_redraw()
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
# Gesamtdauer des laufenden Ladevorgangs (erster Schuss bzw. Takt).
var _charge_time := 0.0
# Zuletzt gezeichnete Fuellhoehe in Pixeln (nur neu zeichnen, wenn sie sich aendert).
var _bar_pixels := -1

@onready var _time: TimeAffected = $TimeAffected
@onready var _sprite: Sprite2D = $Sprite
@onready var _bar: Node2D = $ChargeBar


func _ready() -> void:
	_sprite.flip_h = direction == Direction.LEFT
	_time_left = first_shot_delay
	_charge_time = first_shot_delay
	_bar.draw.connect(_draw_bar)


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
		_charge_time = fire_interval
		_fire()
	_update_bar()


## Anteil des Ladebalkens (0 = leer, 1 = voll).
func get_charge() -> float:
	if _charge_time <= 0.0:
		return 1.0
	return clampf(1.0 - _time_left / _charge_time, 0.0, 1.0)


func _update_bar() -> void:
	var pixels := int(get_charge() * BAR_RECT.size.y)
	if pixels != _bar_pixels:
		_bar_pixels = pixels
		_bar.queue_redraw()


func _draw_bar() -> void:
	var pixels := int(get_charge() * BAR_RECT.size.y)
	if pixels <= 0:
		return
	var rect := BAR_RECT
	# Spiegeln wie das Bild, wenn der Werfer nach links schiesst.
	if direction == Direction.LEFT:
		rect.position.x = -rect.end.x
	# Von unten nach oben fuellen, oberste Zeile heller.
	var fill := Rect2(rect.position.x, rect.end.y - pixels, rect.size.x, pixels)
	_bar.draw_rect(fill, COLOR_BAR)
	_bar.draw_rect(Rect2(fill.position, Vector2(fill.size.x, 1)), COLOR_BAR_TOP)


func _fire() -> void:
	var sign_x := -1.0 if direction == Direction.LEFT else 1.0
	var projectile := PROJECTILE_SCENE.instantiate()
	projectile.direction = sign_x
	projectile.speed = projectile_speed
	projectile.max_distance = max_distance
	# Position VOR dem Einhaengen setzen: Ein AnimatableBody2D, das schon im
	# Level haengt, uebernimmt eine neue Position erst im naechsten
	# Physik-Schritt. Dazwischen stuende es fuer ein Bild bei (0, 0).
	var parent := get_parent() as Node2D
	projectile.position = parent.to_local(global_position + Vector2(sign_x * MUZZLE_DISTANCE, 0.0))
	# Neben den Werfer in den Level haengen: Der Werfer bleibt davon unberuehrt.
	parent.add_child(projectile)
	projectile.add_collision_exception_with(self)
	# Keine Bild-Glaettung von einer frueheren Stelle her (Physik-Interpolation).
	projectile.reset_physics_interpolation()
