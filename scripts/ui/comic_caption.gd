class_name ComicCaption
extends PanelContainer
## Bilduntertext unter einem Comic-Panel (Intro und Ende, Doku 3.5): heller
## Kasten mit dunklem Rand wie in einem Comic, darin ein kurzer Satz zur
## Handlung. Die Texte stehen in dialogues/comic.json (Spieltexte, englisch),
## Kennung = Name des Panels, z. B. "intro_s1_left". Fehlt der Text, gibt es
## keinen Kasten. Der Kasten haengt am Panel: Er ploppt mit ihm auf und
## verschwindet mit ihm. Nur Palettenfarben.

const TEXT_FILE := "comic"
## Abstand zwischen Panel und Kasten (Pixel).
const GAP := 8.0
const FONT_SIZE := 16
const COLOR_BG := Color("c7dcd0")
const COLOR_BORDER := Color("2e222f")
const COLOR_TEXT := Color("2e222f")


## Haengt den Untertext zur Kennung "id" unter das Panel "panel".
## Gibt null zurueck, wenn es fuer das Panel keinen Text gibt.
static func attach(panel: Control, id: String) -> ComicCaption:
	var text := GameTexts.get_text(TEXT_FILE, id)
	if text == id or text.strip_edges() == "":
		return null
	var caption := ComicCaption.new()
	caption._build(text, panel.size.x)
	caption.position = Vector2(0, panel.size.y + GAP)
	panel.add_child(caption)
	return caption


## Der angezeigte Text (fuer Tests).
func get_text() -> String:
	return (get_child(0) as Label).text


func _build(text: String, width: float) -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size.x = width
	size.x = width
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_BG
	style.border_color = COLOR_BORDER
	style.set_border_width_all(2)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 5
	style.content_margin_bottom = 6
	add_theme_stylebox_override("panel", style)
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", COLOR_TEXT)
	label.add_theme_font_size_override("font_size", FONT_SIZE)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
