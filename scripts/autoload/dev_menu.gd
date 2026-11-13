extends Node
## Entwickler-Menue (Doku 1.9), globales System (Autoload "DevMenu").
## Nur beim Start aus dem Editor aktiv (Debug-Build); im exportierten Spiel
## ist es abgeschaltet und alle Schalter bleiben aus.
##
## - F1: Menue oeffnen/schliessen (Spiel pausiert).
## - Strg + Linksklick: Professor an die Mausposition setzen (Teleport).
## - Unverwundbar, Zeit-Markierungen, Level neu starten, Level-Auswahl,
##   alle Upgrades freischalten bzw. zuruecksetzen, Hauptmenue.
## - Test-Szenarien (data/dev_scenarios/*.json): laden einen Spielstand und
##   ein Level, als haette man bis dahin gespielt. Danach laeuft der
##   Testmodus (gespeichert wird in eine Testdatei, der echte Spielstand
##   bleibt unberuehrt). "Save state as scenario" legt aus dem aktuellen
##   Stand ein neues Szenario an.
## Texte sind englisch und bewusst nicht in Datendateien: Das Menue ist kein
## Teil des Spiels.

## Ordner, deren Szenen in der Level-Auswahl erscheinen.
const LEVEL_FOLDERS := ["res://scenes/levels", "res://scenes/test"]
## Ordner der Test-Szenarien.
const SCENARIO_FOLDER := "res://data/dev_scenarios"

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
var _scenario_list: VBoxContainer
var _title_label: Label
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
		_fill_scenario_list()
		_title_label.text = "DEV MENU (F1)" + ("  -  TEST MODE" if SaveGame.test_mode else "")


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


func _go_to_main_menu() -> void:
	_set_open(false)
	LevelFlow.go_to(LevelFlow.TITLE_SCENE)


## Alle Test-Szenarien. Schluessel = Kennung (Dateiname ohne Endung).
func get_scenarios() -> Dictionary:
	var result := {}
	var dir := DirAccess.open(SCENARIO_FOLDER)
	if dir == null:
		return result
	for file in dir.get_files():
		if file.ends_with(".json"):
			var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(SCENARIO_FOLDER.path_join(file)))
			if data is Dictionary:
				result[file.get_basename()] = data
	return result


## Szenario mit allem, worauf es aufbaut ("based_on"), zusammengefuehrt.
## Listen im Spielstand (Upgrades, Marken) werden vereinigt, sonst gilt der
## Wert des Szenarios selbst.
func resolve_scenario(id: String, all := {}, depth := 0) -> Dictionary:
	if all.is_empty():
		all = get_scenarios()
	var own: Dictionary = all.get(id, {})
	if own.is_empty() or depth > 16:
		return {}
	var result := {}
	var save := {}
	var base_id := str(own.get("based_on", ""))
	if base_id != "":
		result = resolve_scenario(base_id, all, depth + 1)
		save = result.get("save", {}).duplicate(true)
	for key in own:
		if key != "save":
			result[key] = own[key]
	var own_save: Dictionary = own.get("save", {})
	for key in own_save:
		if own_save[key] is Array and save.get(key) is Array:
			var merged: Array = save[key].duplicate()
			for item in own_save[key]:
				if not merged.has(item):
					merged.append(item)
			save[key] = merged
		else:
			save[key] = own_save[key]
	result["save"] = save
	return result


## Laedt ein Test-Szenario: Spielstand uebernehmen, Testmodus an, Level laden,
## Professor an den Startpunkt ("marker" bzw. "position") setzen.
func load_scenario(id: String) -> void:
	var data := resolve_scenario(id)
	if data.is_empty():
		push_warning("Szenario nicht gefunden: " + id)
		return
	_set_open(false)
	SaveGame.test_mode = true
	SaveGame.apply_data(data.get("save", {}))
	LevelFlow.go_to(str(data.get("scene", "")))
	await LevelFlow.level_changed
	var professor := get_tree().get_first_node_in_group("player") as Node2D
	if professor == null:
		return
	var marker := str(data.get("marker", ""))
	var at: Node2D = null
	if marker != "":
		at = get_tree().current_scene.get_node_or_null(marker) as Node2D
	if at:
		professor.global_position = at.global_position
	elif data.get("position") is Array and data.position.size() == 2:
		professor.global_position = Vector2(data.position[0], data.position[1])


## Legt aus dem aktuellen Stand ein neues Szenario an (Level, Position des
## Professors, Spielstand). Gibt die Kennung zurueck.
func save_state_as_scenario() -> String:
	var scene := get_tree().current_scene
	if scene == null:
		return ""
	var stamp := Time.get_datetime_string_from_system().replace(":", "").replace("-", "").replace("T", "_")
	var id := "saved_" + stamp
	var data := {
		"name": "Saved %s (%s)" % [scene.scene_file_path.get_file().get_basename(), stamp],
		"order": 100,
		"scene": scene.scene_file_path,
		"marker": "",
		"save": SaveGame.get_data(),
	}
	var professor := get_tree().get_first_node_in_group("player") as Node2D
	if professor:
		data["position"] = [roundi(professor.global_position.x), roundi(professor.global_position.y)]
	DirAccess.make_dir_recursive_absolute(SCENARIO_FOLDER)
	var file := FileAccess.open(SCENARIO_FOLDER.path_join(id + ".json"), FileAccess.WRITE)
	if file == null:
		push_warning("Szenario kann nicht gespeichert werden.")
		return ""
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	if is_open:
		_fill_scenario_list()
	return id


func _fill_scenario_list() -> void:
	for child in _scenario_list.get_children():
		child.queue_free()
	var all := get_scenarios()
	var ids := all.keys()
	ids.sort_custom(func(a, b):
		var oa := float(all[a].get("order", 0))
		var ob := float(all[b].get("order", 0))
		if oa != ob:
			return oa < ob
		return str(all[a].get("name", a)) < str(all[b].get("name", b)))
	for id in ids:
		var scenario_button := _make_button(str(all[id].get("name", id)))
		scenario_button.pressed.connect(load_scenario.bind(id))
		_scenario_list.add_child(scenario_button)


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
	panel.position = Vector2(24, 24)
	panel.add_theme_stylebox_override("panel", _make_style(COLOR_BG, COLOR_BORDER, 8))
	_layer.add_child(panel)

	# Zwei Spalten: links Schalter und Aktionen, rechts Szenarien und Level.
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 16)
	panel.add_child(columns)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	box.custom_minimum_size = Vector2(260, 0)
	columns.add_child(box)
	var right := VBoxContainer.new()
	right.add_theme_constant_override("separation", 6)
	right.custom_minimum_size = Vector2(300, 0)
	columns.add_child(right)

	_title_label = _make_label("DEV MENU (F1)", COLOR_TITLE)
	box.add_child(_title_label)

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

	var main_menu := _make_button("Main menu")
	main_menu.pressed.connect(_go_to_main_menu)
	box.add_child(main_menu)

	box.add_child(_make_label("Ctrl + left click: teleport", COLOR_TEXT))

	right.add_child(_make_label("Test scenarios", COLOR_TITLE))
	var scenario_scroll := ScrollContainer.new()
	scenario_scroll.custom_minimum_size = Vector2(0, 140)
	scenario_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	right.add_child(scenario_scroll)
	_scenario_list = VBoxContainer.new()
	_scenario_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scenario_scroll.add_child(_scenario_list)
	var save_scenario := _make_button("Save state as scenario")
	save_scenario.pressed.connect(save_state_as_scenario)
	right.add_child(save_scenario)

	right.add_child(_make_label("Levels", COLOR_TITLE))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 160)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	right.add_child(scroll)
	_level_list = VBoxContainer.new()
	_level_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_level_list)


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
