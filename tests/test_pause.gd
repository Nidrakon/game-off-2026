extends SceneTree
# Automatischer Test: Spielmenue (Esc), Lautstaerke, Beenden mit Nachfrage.
var fails := 0
func check(name: String, ok: bool, info := "") -> void:
	print(("PASS " if ok else "FAIL ") + name + "  (" + info + ")")
	if not ok: fails += 1
func frames(n: int) -> void:
	for i in n: await process_frame
func esc() -> void:
	var ev := InputEventAction.new()
	ev.action = "pause"
	ev.pressed = true
	Input.parse_input_event(ev)
	await process_frame
	var up := InputEventAction.new()
	up.action = "pause"
	up.pressed = false
	Input.parse_input_event(up)
	await process_frame

func _initialize() -> void:
	await process_frame
	root.get_node("SaveGame").test_mode = true
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://settings_test.cfg"))
	var menu = root.get_node("PauseMenu")
	var sfx = root.get_node("Sfx")
	# Im Titel geht das Menue nicht auf
	change_scene_to_file("res://scenes/ui/title_screen.tscn")
	while current_scene == null: await process_frame
	await frames(5)
	await esc()
	check("Im Titel kein Spielmenue", not menu.is_open)
	change_scene_to_file("res://scenes/test/fixtures/fixture_level_a.tscn")
	await frames(3)
	while current_scene == null or not current_scene.is_in_group("level"): await process_frame
	await frames(30)
	await esc()
	check("Esc oeffnet das Menue im Level", menu.is_open and menu.visible)
	check("Spiel pausiert", paused)
	check("Hauptseite", menu.get_page() == "main")
	await esc()
	check("Esc schliesst wieder", not menu.is_open and not paused)
	await esc()
	menu._continue.pressed.emit()
	await process_frame
	check("Continue schliesst", not menu.is_open and not paused)
	# Bedienfeld oeffnet nicht, solange das Menue offen ist
	await esc()
	Input.action_press("time_shifter_panel")
	await frames(3)
	var panel = current_scene.get_node("TimeShifterPanel")
	check("Shift oeffnet kein Bedienfeld im Menue", not panel.visible and paused)
	Input.action_release("time_shifter_panel")
	await frames(3)
	check("Menue bleibt pausiert", paused and menu.is_open)
	# Einstellungen
	menu._settings_button.pressed.emit()
	await process_frame
	check("Einstellungen", menu.get_page() == "settings")
	check("Voreinstellung Gesamt 50 %", roundi(menu._sliders["Master"].value) == roundi(sfx.get_volume("Master") * 100.0), str(menu._sliders["Master"].value))
	menu._sliders["SFX"].value = 40
	check("Effekte-Lautstaerke gesetzt", absf(sfx.get_volume("SFX") - 0.4) < 0.01, str(sfx.get_volume("SFX")))
	menu._sliders["Music"].value = 0
	check("Musik 0 = stumm", AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")))
	var cfg := ConfigFile.new()
	check("In Test-Einstellungen gespeichert", cfg.load("user://settings_test.cfg") == OK and absf(float(cfg.get_value("volume", "SFX", 0)) - 0.4) < 0.01)
	sfx.set_volume("SFX", 1.0, false)
	sfx.load_volumes()
	check("Wird wieder geladen", absf(sfx.get_volume("SFX") - 0.4) < 0.01, str(sfx.get_volume("SFX")))
	menu._back.pressed.emit()
	await process_frame
	check("Zurueck zur Hauptseite", menu.get_page() == "main")
	# Beenden: Nachfrage, Nein, dann Ja
	menu._quit.pressed.emit()
	await process_frame
	check("Quit fragt nach", menu.get_page() == "confirm" and menu.is_open)
	menu._no.pressed.emit()
	await process_frame
	check("Nein = zurueck", menu.get_page() == "main" and menu.is_open)
	menu._quit.pressed.emit()
	await process_frame
	menu._yes.pressed.emit()
	await process_frame
	check("Ja schliesst und entpausiert", not menu.is_open and not paused)
	var t := 0
	while t < 200 and (current_scene == null or current_scene.scene_file_path != "res://scenes/ui/title_screen.tscn"):
		await process_frame
		t += 1
	check("Zurueck im Titel", current_scene != null and current_scene.scene_file_path == "res://scenes/ui/title_screen.tscn")
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://settings_test.cfg"))
	print("Fehler: %d" % fails)
	quit(1 if fails else 0)
