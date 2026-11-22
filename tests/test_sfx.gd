extends SceneTree
# Automatischer Test: Soundtabelle, Dateien, Aufrufe im Code, Ambient je Level.
var fails := 0
func check(name: String, ok: bool, info := "") -> void:
	print(("PASS " if ok else "FAIL ") + name + "  (" + info + ")")
	if not ok: fails += 1
func frames(n: int) -> void:
	for i in n: await physics_frame

func _scan(dir: String, out: Array) -> void:
	for f in DirAccess.get_files_at(dir):
		if f.ends_with(".gd"): out.append(dir + "/" + f)
	for d in DirAccess.get_directories_at(dir):
		_scan(dir + "/" + d, out)

func _initialize() -> void:
	await process_frame
	root.get_node("SaveGame").test_mode = true
	var sfx = root.get_node("Sfx")
	var table: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/sfx.json"))
	check("Tabelle hat Eintraege", table.size() >= 40, str(table.size()))
	var missing := []
	var bad_loop := []
	for id in table:
		for f in table[id].files:
			var s = load("res://audio/sfx/%s.wav" % f)
			if not (s is AudioStreamWAV): missing.append(f)
		if table[id].get("loop", false):
			var st = sfx._pick(id)
			if st == null or st.loop_mode == AudioStreamWAV.LOOP_DISABLED: bad_loop.append(id)
	check("Alle Dateien laden", missing.is_empty(), str(missing))
	check("Schleifen sind als Schleife gesetzt", bad_loop.is_empty(), str(bad_loop))
	for bus in ["SFX", "Ambient", "Music"]:
		check("Bus " + bus, AudioServer.get_bus_index(bus) >= 0)
	# Jede im Code benutzte Kennung steht in der Tabelle
	var files := []
	_scan("res://scripts", files)
	var re := RegEx.new()
	re.compile("Sound\\.(?:play|play_at|loop|play_ambient)\\(\\[?\"([a-z_0-9]+)\"")
	var re2 := RegEx.new()
	re2.compile("\"((?:ambient|stage)_[a-z]+)\"")
	var unknown := []
	var used := {}
	for path in files:
		var text := FileAccess.get_file_as_string(path)
		for m in re.search_all(text):
			used[m.get_string(1)] = true
			if not table.has(m.get_string(1)): unknown.append(m.get_string(1) + " in " + path.get_file())
		for m in re2.search_all(text):
			if not table.has(m.get_string(1)): unknown.append(m.get_string(1) + " in " + path.get_file())
	check("Keine unbekannten Kennungen im Code", unknown.is_empty(), str(unknown))
	check("Viele Stellen benutzen Sounds", used.size() >= 30, str(used.size()))
	# Abspielen ohne Fehler, Ambient je Level
	change_scene_to_file("res://scenes/test/fixtures/fixture_level_a.tscn")
	while current_scene == null: await process_frame
	await frames(20)
	var level = current_scene
	check("Level startet sein Ambient", sfx.get_ambient_id() == level.AMBIENT_IDS[level.background_theme], sfx.get_ambient_id())
	for theme in level.AMBIENT_IDS:
		check("Ambient fuer Thema %d vorhanden" % theme, table.has(level.AMBIENT_IDS[theme]))
	# Sprung loest Signal aus
	var p = level.get_node("Professor")
	var jumped := [false]
	p.jumped.connect(func() -> void: jumped[0] = true)
	await frames(10)
	Input.action_press("jump")
	await frames(4)
	Input.action_release("jump")
	check("Sprung meldet sich", jumped[0])
	var landed := [-1.0]
	p.landed.connect(func(v: float) -> void: landed[0] = v)
	await frames(90)
	check("Landung meldet Fallgeschwindigkeit", landed[0] > 0.0, str(landed[0]))
	sfx.stop_ambient()
	check("Ambient aus", sfx.get_ambient_id() == "")
	print("Fehler: %d" % fails)
	quit(1 if fails else 0)
