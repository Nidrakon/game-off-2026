@tool
extends Area2D
## Schrotthaufen (Doku 2.3, Freischalten): Fundstelle, an der der Professor
## den Time Shifter um eine Funktion erweitert. Beruehrt er den Haufen, wird
## das Upgrade eingebaut ("upgrade" im Inspector), es erscheint eine kurze
## Einblendung, vom Haufen bleiben nur Reste.
## Ist das Upgrade schon da (z. B. nach einem Neustart des Levels), liegen
## von Anfang an nur die Reste da.
## Der Node liegt unten in der Mitte des Haufens (auf den Boden stellen).
## Funkeln, Aufblitzen und Funken sind im Code gezeichnet.

## Wird gesendet, wenn der Professor das Upgrade hier einbaut.
signal collected(upgrade: TimeShifterUpgrades.Upgrade)

## Welches Upgrade dieser Haufen bringt.
@export var upgrade := TimeShifterUpgrades.Upgrade.RADIUS

const TEXTURE := preload("res://graphics/sprites/objects/object_scrap_heap_placeholder.png")
const SIZE := Vector2(32, 24)
## Wechsel des Funkelns (Sekunden).
const SPARKLE_TIME := 0.18
## Dauer des Funkenregens beim Einbau (Sekunden).
const BURST_TIME := 0.6
const BURST_SPARKS := 10
# Farben aus der Palette: Funkeln und Funken.
const COLOR_SPARKLE := Color("fbff86")
const COLOR_SPARKLE_CORE := Color("ffffff")
const COLOR_BURST := Color("f9c22b")

var _collected := false
var _sparkle_left := 0.0
var _sparkle_pos := Vector2.ZERO
var _burst_left := 0.0
var _burst_dirs: Array[Vector2] = []


func _ready() -> void:
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = SIZE
	shape.shape = rect
	shape.position = Vector2(0, -SIZE.y * 0.5)
	add_child(shape)
	if Engine.is_editor_hint():
		return
	_collected = Upgrades.has(upgrade)
	body_entered.connect(_on_body_entered)
	# Aendern sich die Upgrades von aussen (Entwickler-Menue), passt sich der
	# Haufen an: alle freigeschaltet = Reste, zurueckgesetzt = wieder voll.
	Upgrades.changed.connect(_on_upgrades_changed)


func _on_upgrades_changed() -> void:
	if _collected != Upgrades.has(upgrade):
		_collected = Upgrades.has(upgrade)
		queue_redraw()


## Ist das Upgrade hier schon eingebaut?
func is_collected() -> bool:
	return _collected


func _on_body_entered(body: Node2D) -> void:
	if _collected or not body.is_in_group("player"):
		return
	if "is_dead" in body and body.is_dead:
		return
	_collected = true
	_burst_left = BURST_TIME
	_burst_dirs.clear()
	for i in BURST_SPARKS:
		_burst_dirs.append(Vector2.from_angle(randf_range(PI * 1.1, PI * 1.9)) * randf_range(20.0, 44.0))
	Upgrades.unlock(upgrade)
	Sound.play("scrap_pickup")
	get_tree().call_group("game_feel", "on_pickup")
	UpgradeMessage.show_for(upgrade, get_tree())
	collected.emit(upgrade)
	queue_redraw()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if _burst_left > 0.0:
		_burst_left -= delta
		queue_redraw()
	if _collected:
		return
	# Funkeln an zufaelligen Stellen ueber dem Haufen, damit man ihn bemerkt.
	_sparkle_left -= delta
	if _sparkle_left <= 0.0:
		_sparkle_left = SPARKLE_TIME
		_sparkle_pos = Vector2(randi_range(-12, 12), randi_range(-22, -8))
		queue_redraw()


func _draw() -> void:
	var collected_look := _collected and not Engine.is_editor_hint()
	var frame := 1 if collected_look else 0
	draw_texture_rect_region(TEXTURE, Rect2(-SIZE.x * 0.5, -SIZE.y, SIZE.x, SIZE.y), Rect2(0, frame * SIZE.y, SIZE.x, SIZE.y))
	if not collected_look and not Engine.is_editor_hint():
		# Kleines Kreuz-Funkeln
		var p := _sparkle_pos.floor()
		draw_rect(Rect2(p.x - 1, p.y, 3, 1), COLOR_SPARKLE)
		draw_rect(Rect2(p.x, p.y - 1, 1, 3), COLOR_SPARKLE)
		draw_rect(Rect2(p, Vector2.ONE), COLOR_SPARKLE_CORE)
	if _burst_left > 0.0:
		# Funken fliegen nach oben auseinander.
		var t := 1.0 - _burst_left / BURST_TIME
		for dir in _burst_dirs:
			var p := (Vector2(0, -12) + dir * t + Vector2(0, 30.0 * t * t)).floor()
			draw_rect(Rect2(p, Vector2(2, 2)), COLOR_BURST if t < 0.6 else COLOR_SPARKLE)
