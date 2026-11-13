@tool
class_name Interactable
extends Area2D
## Grundlage fuer alles, womit der Professor per Taste E (Aktion "interact")
## interagiert (Doku 2.9). Steht er im Bereich, erscheint ueber dem Objekt
## eine Tastenkappe "E"; drueckt er E, wird _on_interact() aufgerufen und das
## Signal "interacted" gesendet.
## Abgeleitete Skripte legen die Form fest (CollisionShape2D als Kind oder im
## Code) und ueberschreiben _on_interact().
## Erkennt Ebene 2 "player" (collision_mask = 2 in der Szene).

## Wird gesendet, wenn der Professor hier E drueckt.
signal interacted

## Wo die Tastenkappe "E" erscheint (relativ zum Node, Mitte unten der Kappe).
@export var prompt_offset := Vector2(0, -88)
## Beschriftung der Tastenkappe.
const PROMPT_LABEL := "E"
# Farben aus der Palette: Tastenflaeche, Umriss und Schrift, untere Kante.
const COLOR_FACE := Color("ffffff")
const COLOR_EDGE := Color("2e222f")
const COLOR_SHADOW := Color("9babb2")
## Leichtes Auf und Ab der Kappe (Pixel, Sekunden pro Schwung).
const BOB_HEIGHT := 2.0
const BOB_TIME := 0.8

var _player: Node2D
var _prompt: Node2D
var _bob := 0.0


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_prompt = Node2D.new()
	_prompt.z_index = 40
	_prompt.visible = false
	_prompt.draw.connect(_draw_prompt)
	add_child(_prompt)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


## Steht der Professor gerade im Bereich (und kann interagieren)?
func is_player_near() -> bool:
	return _player != null and _can_act(_player)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var near := is_player_near()
	if _prompt.visible != near:
		_prompt.visible = near
	if near:
		_bob = fmod(_bob + delta, BOB_TIME)
		_prompt.position = prompt_offset + Vector2(0, -roundf(BOB_HEIGHT * 0.5 * (1.0 - cos(TAU * _bob / BOB_TIME))))
		_prompt.queue_redraw()
		if Input.is_action_just_pressed("interact"):
			_on_interact(_player)
			interacted.emit()


## Abgeleitete Skripte: was beim Druck auf E passiert.
func _on_interact(_professor: Node2D) -> void:
	pass


func _can_act(body: Node2D) -> bool:
	return not body.get("is_dead") and not body.get("is_leaving")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player = body


func _on_body_exited(body: Node2D) -> void:
	if body == _player:
		_player = null


func _draw_prompt() -> void:
	var width := KeyCap.get_width(PROMPT_LABEL)
	KeyCap.draw(_prompt, Vector2(-floorf(width * 0.5), -KeyCap.HEIGHT - 2.0), PROMPT_LABEL, COLOR_FACE, COLOR_EDGE, COLOR_SHADOW)
