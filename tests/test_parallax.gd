extends SceneTree
# Automatischer Test: Kamera mit Spielraum (seit v0.79). Das ganze Level ist
# immer zu sehen, die Kamera folgt trotzdem dem Professor; der Rand ist
# massive Wand, die hinteren Ebenen laufen langsamer (Parallax).
var fails := 0
func check(name: String, ok: bool, info := "") -> void:
	print(("PASS " if ok else "FAIL ") + name + "  (" + info + ")")
	if not ok: fails += 1


func view_rect(cam: Camera2D) -> Rect2:
	var size := Vector2(960, 540) / cam.zoom
	return Rect2(cam.get_screen_center_position() - size * 0.5, size)


func _initialize() -> void:
	await process_frame
	root.get_node("SaveGame").test_mode = true
	for path in ["res://scenes/levels/level_base.tscn", "res://scenes/levels/level_04.tscn"]:
		var old = current_scene
		change_scene_to_file(path)
		await process_frame
		while current_scene == null or current_scene == old or not current_scene.is_in_group("level"): await process_frame
		var level = current_scene
		var cam: Camera2D = level.get_node("Camera")
		var level_rect := Rect2(0, 0, 960, 544)
		check(path.get_file() + ": leicht herausgezoomt", cam.zoom.x < 1.0 and cam.zoom.x > 0.85, "%.3f" % cam.zoom.x)
		var p = level.get_node("Professor")
		for i in 30: await physics_frame
		var results := []
		var centers := []
		var deep := []
		var wall := []
		for x in [60.0, 820.0]:
			p.global_position = Vector2(x, 496)
			p.velocity = Vector2.ZERO
			for i in 90: await process_frame
			results.append(view_rect(cam).grow(0.5).encloses(level_rect))
			centers.append(cam.get_screen_center_position().x)
			deep.append(level.get_node("DeepBackground").position.x)
			wall.append(level.get_node("BackWall").position.x)
		check(path.get_file() + ": ganzes Level immer sichtbar", results.all(func(r): return r), str(results))
		check(path.get_file() + ": Kamera folgt dem Professor", centers[1] - centers[0] > 50.0, "%.0f px" % (centers[1] - centers[0]))
		check(path.get_file() + ": Parallax (tief langsamer als Wand)", deep[1] - deep[0] > wall[1] - wall[0] and wall[1] - wall[0] > 0.0, "tief %.0f, Wand %.0f" % [deep[1] - deep[0], wall[1] - wall[0]])
		var g: TileMapLayer = level.get_node("Ground")
		check(path.get_file() + ": Rand ist massive Wand", g.get_cell_source_id(Vector2i(-2, 10)) != -1 and g.get_cell_source_id(Vector2i(62, 10)) != -1)
	DirAccess.remove_absolute("user://savegame_test.json")
	print("Fehler: %d" % fails)
	quit(1 if fails else 0)
