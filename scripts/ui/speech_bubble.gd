class_name SpeechBubble
extends Node2D
## Sprechblase ueber einer Figur (Doku 2.8), einfache Fassung bis zum
## Sprechblasen-System in Schritt 18: weisser Kasten mit Umriss und Spitze
## nach unten, Text aus dialogues/speech.json. Haengt an der Figur (folgt ihr)
## und verschwindet nach einer Zeit, die sich nach der Textlaenge richtet.
## Das Spiel laeuft dabei weiter. Nur Palettenfarben.

## Grundzeit und Zusatzzeit pro Zeichen (Sekunden).
const BASE_TIME := 2.0
const TIME_PER_CHAR := 0.05
## Groesste Breite des Kastens (Pixel), danach wird umgebrochen.
const MAX_WIDTH := 220.0
const FONT_SIZE := 12
# Farben aus der Palette.
const COLOR_FILL := Color("ffffff")
const COLOR_EDGE := Color("2e222f")

var _time_left := 0.0
var _panel: PanelContainer


## Laesst "speaker" den Text mit dieser Kennung sagen. "height" = Abstand der
## Blasenspitze ueber dem Node der Figur (beim Professor ueber dem Kopf).
## Eine vorherige Blase derselben Figur verschwindet.
static func say(speaker: Node2D, text_id: String, height := 64.0) -> SpeechBubble:
	for child in speaker.get_children():
		if child is SpeechBubble:
			child.queue_free()
	var bubble := SpeechBubble.new()
	bubble._build(GameTexts.get_text("speech", text_id), height)
	speaker.add_child(bubble)
	return bubble


## Text der Blase (fuer Tests).
func get_text() -> String:
	return (_panel.get_child(0) as Label).text


func _build(text: String, height: float) -> void:
	z_index = 50
	_time_left = BASE_TIME + TIME_PER_CHAR * text.length()
	position = Vector2(0, -height)
	_panel = PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_FILL
	style.border_color = COLOR_EDGE
	style.set_border_width_all(1)
	style.set_content_margin_all(5)
	style.anti_aliasing = false
	_panel.add_theme_stylebox_override("panel", style)
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.show_behind_parent = true
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", COLOR_EDGE)
	label.add_theme_font_size_override("font_size", FONT_SIZE)
	var font := ThemeDB.fallback_font
	var natural := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x
	label.custom_minimum_size.x = minf(ceilf(natural) + 1.0, MAX_WIDTH)
	_panel.add_child(label)
	add_child(_panel)
	_panel.resized.connect(_place_panel)
	_place_panel()


## Kasten mittig ueber der Spitze ausrichten.
func _place_panel() -> void:
	_panel.position = Vector2(-floorf(_panel.size.x * 0.5), -_panel.size.y - 5.0)
	queue_redraw()


func _process(delta: float) -> void:
	_time_left -= delta
	if _time_left <= 0.0:
		queue_free()


func _draw() -> void:
	# Spitze nach unten zur Figur. Der Kasten wird vorher gezeichnet
	# (show_behind_parent), so unterbricht die erste Zeile seinen Rand.
	for i in 6:
		var half := 5 - i
		draw_rect(Rect2(-half - 1, -6 + i, half * 2 + 3, 1), COLOR_EDGE)
		if half > 0:
			draw_rect(Rect2(-half, -6 + i, half * 2 + 1, 1), COLOR_FILL)
