extends Node
## Entwickler-Menue (Doku 1.9), globales System (Autoload "DevMenu").
## Nur beim Start aus dem Editor aktiv (Debug-Build); im exportierten Spiel
## ist es abgeschaltet und alle Schalter bleiben aus.
##
## - F1: Menue oeffnen/schliessen (Spiel pausiert).
## - Strg + Linksklick: Professor an die Mausposition setzen (Teleport).
## - Unverwundbar, Zeit-Markierungen, Level neu starten, Level-Auswahl,
##   alle Upgrades freischalten bzw. zuruecksetzen.
## Texte sind englisch und bewusst nicht in Datendateien: Das Menue ist kein
## Teil des Spiels.

## Ordner, deren Szenen in der Level-Auswahl erscheinen.
const LEVEL_FOLDERS := ["res://scenes/levels", "res://scenes/test"]

# Farben aus der Palette.
const COLOR_BG := Color("2e222f")
const COLOR_BUTTON := Color("3e3546")
const COLOR_HOVER := Color("484a77")
const COLOR_PRESSED := Color("4d65b4")
const COLOR_BORDER := Color("7f708a")
const COLOR_TEXT := Color("c7dcd0")
const COLOR_TITLE := Color("f9c22b")

## Professor stirbt nicht (Hazards wirken nicht).
var invulnerable := false
## Objekte in der Zeitblase farbig umranden (nur zum Testen, Standard aus).
var show_time_markers := false
## Ist das Menue gerade offen?
var is_open := false

var _layer: CanvasLayer
var _level_list: VBoxContainer
var _invulnerable_button: Button
var _markers_button: Button


func _ready() -> void:
	if not OS.is_debug_build():
		set_process_input(false)
		set_process_unhandled_input(false)
		return
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Sprites aus Aseprite live nachladen (siehe Doku 1.8, Aseprite-Sync).
	add_child(preload("res://scripts/dev/sprite_hot_reload.gd").new())
	_build_ui()
	_layer.visible = false


func _input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key and key.pressed and not key.echo and key.physical_keycode == KEY_F1:
		_set_open(not is_open)
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	# Teleport: Strg + Linksklick setzt den Professor an die Mausposition.
	var button := event as InputEventMouseButton
	if button and button.pressed and button.button_index == MOUSE_BUTTON_LEFT and button.ctrl_pressed:
		_teleport_to(button.position)
		get_viewport().set_input_as_handled()


func _on_invulnerable_toggled(on: bool) -> void:
	invulnerable = on
	_invulnerable_button.text = "Invulnerable: " + ("ON" if on else "OFF")


func _on_markers_toggled(on: bool) -> void:
	show_time_markers = on
	_markers_button.text = "Time markers: " + ("ON" if on else "OFF")


func _set_open(open: bool) -> void:
	is_open = open
	_layer.visible = open
	get_tree().paused = open
	if open:
		_fill_level_list()


func _teleport_to(screen_position: Vector2) -> void:
	var professor := get_tree().get_first_node_in_group("player") as CharacterBody2D
	if professor == null:
		return
	# Bildschirm- in Weltkoordinaten umrechnen (Kamera beruecksichtigen).
	var world_position := get_viewport().get_canvas_transform().affine_inverse() * screen_position
	professor.global_position = world_position
	professor.velocity = Vector2.ZERO


func _restart_level() -> void:
	_set_open(false)
	get_tree().reload_current_scene()


func _load_level(path: String) -> void:
	_set_open(false)
	get_tree().change_scene_to_file(path)


## Sucht alle Szenen in den Level-Ordnern und baut je einen Knopf.
func _fill_level_list() -> void:
	for child in _level_list.get_children():
		child.queue_free()
	for folder in LEVEL_FOLDERS:
		var dir := DirAccess.open(folder)
		if dir == null:
			continue
		var files := dir.get_files()
		files.sort()
		for file in files:
			# Im Export heissen Szenen ".tscn.remap"; das Menue laeuft dort aber nicht.
			if not file.ends_with(".tscn"):
				continue
			var path: String = folder.path_join(file)
			var level_button := _make_button(file.get_basename())
			level_button.pressed.connect(_load_level.bind(path))
			_level_list.add_child(level_button)


func _build_ui() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 100
	add_child(_layer)

	var panel := PanelContainer.new()
	panel.position = Vector2(48, 48)
	panel.custom_minimum_size = Vector2(280, 0)
	panel.add_theme_stylebox_override("panel", _make_style(COLOR_BG, COLOR_BORDER, 8))
	_layer.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)

	box.add_child(_make_label("DEV MENU (F1)", COLOR_TITLE))

	# Einfacher Umschaltknopf statt CheckButton: dessen Standard-Symbol hat
	# geglaettete Kanten mit Farben ausserhalb der Palette.
	_invulnerable_button = _make_button("")
	_invulnerable_button.toggle_mode = true
	_invulnerable_button.toggled.connect(_on_invulnerable_toggled)
	box.add_child(_invulnerable_button)
	_on_invulnerable_toggled(false)

	_markers_button = _make_button("")
	_markers_button.toggle_mode = true
	_markers_button.toggled.connect(_on_markers_toggled)
	box.add_child(_markers_button)
	_on_markers_toggled(false)

	var restart := _make_button("Restart level")
	restart.pressed.connect(_restart_level)
	box.add_child(restart)

	var all_upgrades := _make_button("Unlock all upgrades")
	all_upgrades.pressed.connect(Upgrades.unlock_all)
	box.add_child(all_upgrades)

	var reset_upgrades := _make_button("Reset upgrades")
	reset_upgrades.pressed.connect(Upgrades.reset)
	box.add_child(reset_upgrades)

	box.add_child(_make_label("Levels", COLOR_TITLE))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 160)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	_level_list = VBoxContainer.new()
	_level_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_level_list)

	box.add_child(_make_label("Ctrl + left click: teleport", COLOR_TEXT))


func _make_label(text: String, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	return label


func _make_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_style_button(button)
	return button


func _style_button(button: Button) -> void:
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_stylebox_override("normal", _make_style(COLOR_BUTTON, COLOR_BUTTON, 4))
	button.add_theme_stylebox_override("hover", _make_style(COLOR_HOVER, COLOR_HOVER, 4))
	button.add_theme_stylebox_override("pressed", _make_style(COLOR_PRESSED, COLOR_PRESSED, 4))
	button.add_theme_stylebox_override("hover_pressed", _make_style(COLOR_PRESSED, COLOR_PRESSED, 4))
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color"]:
		button.add_theme_color_override(state, COLOR_TEXT)


func _make_style(fill: Color, border: Color, padding: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_content_margin_all(padding)
	style.anti_aliasing = false
	return style
