class_name UpgradeMessage
extends CanvasLayer
## Einblendung nach dem Einbau eines Upgrades (Doku 2.3): Kasten oben in der
## Mitte mit Ueberschrift, Name des Upgrades und kurzem Bedienhinweis. Steht
## "DURATION" Sekunden und verschwindet dann. Die Texte stehen in
## dialogues/upgrades.json (Spieltexte, englisch). Nur Palettenfarben, keine
## Transparenz.

## So lange bleibt die Einblendung stehen (Sekunden, Spielzeit).
const DURATION := 5.0
## Datei mit den Texten.
const TEXT_FILE := "res://dialogues/upgrades.json"
## Breite des Kastens (Pixel).
const BOX_WIDTH := 440.0

# Farben aus der Palette.
const COLOR_BG := Color("2e222f")
const COLOR_BORDER := Color("f9c22b")
const COLOR_HEADER := Color("f9c22b")
const COLOR_TITLE := Color("c7dcd0")
const COLOR_HINT := Color("9babb2")

var _time_left := DURATION


## Zeigt die Einblendung fuer ein Upgrade im aktuellen Level.
static func show_for(upgrade: TimeShifterUpgrades.Upgrade, tree: SceneTree) -> UpgradeMessage:
	# Nur eine Einblendung gleichzeitig.
	for old in tree.get_nodes_in_group("upgrade_message"):
		old.queue_free()
	var message := UpgradeMessage.new()
	message._build(upgrade)
	tree.current_scene.add_child(message)
	return message


func _build(upgrade: TimeShifterUpgrades.Upgrade) -> void:
	add_to_group("upgrade_message")
	layer = 5
	var texts := _load_texts()
	var entry: Dictionary = texts.get(TimeShifterUpgrades.IDS[upgrade], {})

	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_BG
	style.border_color = COLOR_BORDER
	style.set_border_width_all(2)
	style.set_content_margin_all(12)
	panel.add_theme_stylebox_override("panel", style)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.custom_minimum_size.x = BOX_WIDTH
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.offset_left = -BOX_WIDTH * 0.5
	panel.offset_right = BOX_WIDTH * 0.5
	panel.offset_top = 40.0
	add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_label(str(texts.get("upgrade_header", "")), COLOR_HEADER, 14))
	box.add_child(_label(str(entry.get("title", "")), COLOR_TITLE, 20))
	box.add_child(_label(str(entry.get("hint", "")), COLOR_HINT, 14))


func _label(text: String, color: Color, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", font_size)
	return label


func _load_texts() -> Dictionary:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(TEXT_FILE))
	return data if data is Dictionary else {}


func _process(delta: float) -> void:
	_time_left -= delta
	if _time_left <= 0.0:
		queue_free()
