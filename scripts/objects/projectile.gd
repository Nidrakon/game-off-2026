extends AnimatableBody2D
## Projektil (Doku 2.4): fliegt waagrecht, bis es auf ein Hindernis trifft,
## und verschwindet dann. Oben kann der Professor stehen und mitfliegen, die
## Seiten sind toedlich (Kind-Node SideHazard). In der Zeitblase fliegt es
## langsamer oder schneller. Wird vom Werfer (projectile_launcher.gd) erzeugt.
## Der Node liegt in der Mitte des Projektils.

## Nach dem Verlassen der Oberseite ist die Seite so lange noch ungefaehrlich
## (Sekunden). Sonst stirbt man schon beim Herunterlaufen an der Kante.
const RIDE_GRACE_TIME := 0.15

## Flugrichtung: 1 = nach rechts, -1 = nach links.
var direction := 1.0
## Geschwindigkeit bei normalem Tempo (Pixel pro Sekunde).
var speed := 120.0
## Weiteste Flugstrecke, falls es nichts trifft (Pixel).
var max_distance := 4000.0
## Haelt den Strahl eines toedlichen Lasers auf (hinter dem Projektil ist er
## unterbrochen). Wird vom Werfer gesetzt.
var blocks_laser := false

var _flown := 0.0
var _ride_grace_left := 0.0
# Nimmt das Ergebnis der Hindernis-Pruefung auf (wird wiederverwendet).
var _collision := KinematicCollision2D.new()

@onready var _time: TimeAffected = $TimeAffected
@onready var _sprite: Sprite2D = $Sprite


func _ready() -> void:
	_sprite.flip_h = direction < 0.0


## Steht der Professor gerade oben drauf oder ist er eben erst herunter?
func is_ridden_recently() -> bool:
	return _ride_grace_left > 0.0


func _physics_process(delta: float) -> void:
	_update_ride_grace(delta)
	# Die Zeit des Projektils laeuft mit dem Tempo aus der Zeitblase.
	var motion := Vector2(direction * speed * _time.time_scale * delta, 0.0)
	# Vorab pruefen, ob der naechste Schritt ein Hindernis trifft (Ebene 1).
	if test_move(global_transform, motion, _collision):
		# Das getroffene Objekt erfaehrt davon, falls es darauf reagiert
		# (z. B. die Trefferflaeche). Eine einfache Wand hat die Funktion nicht.
		var hit_object := _collision.get_collider()
		if hit_object != null and hit_object.has_method("on_projectile_hit"):
			hit_object.on_projectile_hit()
		queue_free()
		return
	position += motion
	_flown += absf(motion.x)
	if _flown > max_distance:
		queue_free()


func _update_ride_grace(delta: float) -> void:
	_ride_grace_left = maxf(_ride_grace_left - delta, 0.0)
	var professor := get_tree().get_first_node_in_group("player") as CharacterBody2D
	if professor == null or not professor.is_on_floor():
		return
	# Nur Kontakte von oben zaehlen (Normale zeigt nach oben), nicht von der Seite.
	for i in professor.get_slide_collision_count():
		var collision := professor.get_slide_collision(i)
		if collision.get_collider() == self and collision.get_normal().y < -0.5:
			_ride_grace_left = RIDE_GRACE_TIME
			return
