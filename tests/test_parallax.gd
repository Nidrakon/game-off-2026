extends SceneTree
# Automatischer Test: leichter Zoom (sichtbar etwa 75 % der Levelflaeche),
# die Kamera scrollt mit der Figur, die hinteren Ebenen laufen langsamer
# (urspruenglicher Parallax-Effekt).
var fails := 0
func check(name: String, ok: bool, info := "") -> void:
	print(("PASS " if ok else "FAIL ") + name + "  (" + info + ")")
	if not ok: fails += 1


func _initialize() -> void:
	await process_frame
	root.get_node("SaveGame").test_mode = true
	change_scene_to_file("res://scenes/levels/level_base.tscn")
	await process_frame
	while current_scene == null or not current_scene.is_in_group("level"): await process_frame
	var level = current_scene
	var cam: Camera2D = level.get_node("Camera")
	var view := Vector2(960, 540) / cam.zoom
	var share := (view.x * view.y) / (960.0 * 544.0)
	check("Sichtbar etwa 75 % des Levels", share > 0.7 and share < 0.8, "%.0f %%" % (share * 100.0))
	var p = level.get_node("Professor")
	for i in 30: await physics_frame
	p.global_position = Vector2(120, 496)
	cam.snap_to_target() if cam.has_method("snap_to_target") else null
	for i in 90: await process_frame
	var cam_left := cam.get_screen_center_position()
	var deep_left: Vector2 = level.get_node("DeepBackground").position
	var wall_left: Vector2 = level.get_node("BackWall").position
	p.global_position = Vector2(840, 496)
	for i in 120: await process_frame
	var cam_moved := cam.get_screen_center_position().x - cam_left.x
	var deep_moved: float = level.get_node("DeepBackground").position.x - deep_left.x
	var wall_moved: float = level.get_node("BackWall").position.x - wall_left.x
	check("Kamera scrollt mit der Figur", cam_moved > 60.0, "%.0f px" % cam_moved)
	check("Tiefe Ebene laeuft langsamer als die Rueckwand", deep_moved > wall_moved and wall_moved > 0.0, "tief %.0f, Wand %.0f" % [deep_moved, wall_moved])
	DirAccess.remove_absolute("user://savegame_test.json")
	print("Fehler: %d" % fails)
	quit(1 if fails else 0)
