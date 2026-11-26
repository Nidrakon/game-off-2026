extends SceneTree
# Automatischer Test: Ueber Rohre laufen, ohne an Rohrkanten (Ecken,
# T-Stuecke, Kreuzungen) haengen zu bleiben.
var fails := 0
func check(name: String, ok: bool, info := "") -> void:
	print(("PASS " if ok else "FAIL ") + name + "  (" + info + ")")
	if not ok: fails += 1


func _initialize() -> void:
	await process_frame
	root.get_node("SaveGame").test_mode = true
	# Leere Level-Vorlage, damit nichts anderes im Weg steht.
	change_scene_to_file("res://scenes/levels/level_base.tscn")
	await process_frame
	while current_scene == null or not current_scene.is_in_group("level"): await process_frame
	var level = current_scene
	var pipes: TileMapLayer = level.get_node("PipesFront")
	pipes.clear()
	# Rohr in Zeile 26 von x 4 bis 40, Beine nach unten (Ecken, T-Stuecke),
	# eine Kreuzung und ein Rohr, das nach oben abgeht (dort ist eine Wand).
	for x in range(4, 41): pipes.set_cell(Vector2i(x, 26), 0, Vector2i(0, 0))
	for x in [4, 10, 16, 22, 40]:
		for y in range(27, 31): pipes.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
	pipes.set_cell(Vector2i(28, 25), 0, Vector2i(0, 0))
	pipes.set_cell(Vector2i(28, 27), 0, Vector2i(0, 0))
	await process_frame
	await process_frame
	var p = level.get_node("Professor")
	for i in 40: await physics_frame
	# Nach rechts: von der linken Ecke bis vor die Kreuzung mit Rohr nach oben
	p.global_position = Vector2(4 * 16 + 8, 26 * 16 - 6)
	p.velocity = Vector2.ZERO
	for i in 20: await physics_frame
	Input.action_press("move_right")
	var start: float = p.global_position.x
	for i in 150: await physics_frame
	Input.action_release("move_right")
	check("Ueber Ecke und T-Stuecke nach rechts", p.global_position.x > 26 * 16, "%.0f -> %.0f" % [start, p.global_position.x])
	check("... dabei oben auf dem Rohr geblieben", p.global_position.y < 26 * 16 + 4, "y %.0f" % p.global_position.y)
	# Zurueck nach links bis zur linken Ecke
	Input.action_press("move_left")
	for i in 150: await physics_frame
	Input.action_release("move_left")
	check("Nach links ueber alle Kanten zurueck", p.global_position.x < 6 * 16, "x %.0f" % p.global_position.x)
	# Kreuzung ohne Rohr nach oben: rechts hinter x 28 die Strecke bis 40
	pipes.erase_cell(Vector2i(28, 25))
	await process_frame
	await process_frame
	p.global_position = Vector2(24 * 16, 26 * 16 - 6)
	p.velocity = Vector2.ZERO
	for i in 20: await physics_frame
	Input.action_press("move_right")
	for i in 120: await physics_frame
	Input.action_release("move_right")
	check("Ueber T-Stueck/Ecke am rechten Ende", p.global_position.x > 38 * 16, "x %.0f" % p.global_position.x)
	DirAccess.remove_absolute("user://savegame_test.json")
	print("Fehler: %d" % fails)
	quit(1 if fails else 0)
