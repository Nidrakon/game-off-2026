@tool
extends Interactable
## Fahrstuhl in der Werkstatt (Doku 2.9, 3.5): zu Beginn nicht nutzbar, weil
## die Keycard "geroestet" ist. Drueckt der Professor davor E, sagt er das
## in einer Sprechblase (Text-ID "text_id" aus dialogues/speech.json). Die
## Lampe am Keycard-Leser blinkt rot.
## Spaeter (Ende des Spiels, Schritt 23) faehrt er damit nach unten.
## Der Node liegt unten in der Mitte der Fahrstuhltuer (auf den Boden stellen).

## Was der Professor sagt, wenn er E drueckt (Kennung in dialogues/speech.json).
@export var text_id := "speech_elevator_keycard"

const TEXTURE := preload("res://graphics/sprites/objects/object_elevator_placeholder.png")
## Lage der Grafik: Tuermitte liegt bei x = 25 im Bild.
const TEXTURE_OFFSET := Vector2(-25, -80)
## Bereich, in dem E wirkt (Tuer und Keycard-Leser).
const AREA := Rect2(-25, -80, 62, 80)
## Lampe des Keycard-Lesers (relativ zum Node) und Blinktakt (Sekunden).
const LED_RECT := Rect2(31, -41, 3, 3)
const BLINK_TIME := 0.5
# Farben aus der Palette: Lampe an und aus.
const COLOR_LED := Color("e83b3b")
const COLOR_LED_OFF := Color("6e2727")

var _blink_left := BLINK_TIME
var _led_on := true


func _ready() -> void:
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = AREA.size
	shape.shape = rect
	shape.position = AREA.get_center()
	add_child(shape)
	super._ready()


func _process(delta: float) -> void:
	super._process(delta)
	if Engine.is_editor_hint():
		return
	_blink_left -= delta
	if _blink_left <= 0.0:
		_blink_left = BLINK_TIME
		_led_on = not _led_on
		queue_redraw()


func _on_interact(professor: Node2D) -> void:
	SpeechBubble.say(professor, text_id)


func _draw() -> void:
	draw_texture(TEXTURE, TEXTURE_OFFSET)
	draw_rect(LED_RECT, COLOR_LED if _led_on else COLOR_LED_OFF)
