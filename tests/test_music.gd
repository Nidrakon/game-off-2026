extends SceneTree
# Automatischer Test: Musik (Songs mit fester ID, Level-Auswahl, Daempfen).
var fails := 0
func check(name: String, ok: bool, info := "") -> void:
	print(("PASS " if ok else "FAIL ") + name + "  (" + info + ")")
	if not ok: fails += 1
func frames(n: int) -> void:
	for i in n: await process_frame

func _initialize() -> void:
	await process_frame
	root.get_node("SaveGame").test_mode = true
	var sfx = root.get_node("Sfx")
	var table: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/music.json"))
	check("Acht Songs in der Tabelle", table.size() == 8, str(table.keys()))
	var bad := []
	for id in table:
		var s = load("res://audio/music/%s.ogg" % table[id].file)
		if not (s is AudioStreamOggVorbis) or s.get_length() < 20.0: bad.append(id)
	check("Alle Songs laden (OGG, > 20 s)", bad.is_empty(), str(bad))
	# Titel spielt Song 1
	change_scene_to_file("res://scenes/ui/title_screen.tscn")
	while current_scene == null: await process_frame
	await frames(5)
	check("Titel: Song 1", sfx.get_music_id() == 1, str(sfx.get_music_id()))
	var active = sfx._music[sfx._music_active]
	check("Song laeuft als Schleife", active.playing and active.stream.loop)
	# Level: Auto nach Thema
	change_scene_to_file("res://scenes/test/fixtures/fixture_level_a.tscn")
	await frames(3)
	while current_scene == null or not current_scene.is_in_group("level"): await process_frame
	await frames(10)
	var level = current_scene
	check("Level: Song passend zum Thema", sfx.get_music_id() == level.AUTO_MUSIC[level.background_theme], "%d" % sfx.get_music_id())
	for theme in level.AUTO_MUSIC:
		check("Thema %d hat einen Song" % theme, table.has(str(level.AUTO_MUSIC[theme])))
	level.music = 5
	check("Eigene Auswahl im Inspector", level.get_music_id() == 5)
	# Gleicher Song startet nicht neu
	var pos_before: float = sfx._music[sfx._music_active].get_playback_position()
	await frames(20)
	sfx.play_music(sfx.get_music_id())
	await frames(2)
	check("Gleicher Song laeuft weiter", sfx._music[sfx._music_active].get_playback_position() > pos_before)
	# Spielmenue daempft
	var menu = root.get_node("PauseMenu")
	menu.open()
	await create_timer(0.4, true, false, true).timeout
	check("Spielmenue daempft die Musik", sfx.is_music_muffled())
	menu.close()
	await create_timer(0.4, true, false, true).timeout
	check("Danach wieder klar", not sfx.is_music_muffled())
	# Wechsel mit Ueberblendung
	sfx.play_music(6)
	await frames(2)
	var playing := 0
	for p in sfx._music:
		if p.playing: playing += 1
	check("Ueberblendung: beide Spieler kurz aktiv", playing == 2, str(playing))
	await create_timer(2.0).timeout
	playing = 0
	for p in sfx._music:
		if p.playing: playing += 1
	check("Danach nur noch der neue Song", playing == 1 and sfx.get_music_id() == 6)
	check("Songname", sfx.get_music_name(6) == "Going Down (with Pizza)")
	sfx.stop_music()
	check("Musik aus", sfx.get_music_id() == 0)
	print("Fehler: %d" % fails)
	quit(1 if fails else 0)
