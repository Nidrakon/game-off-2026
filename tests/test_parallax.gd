extends SceneTree
# Automatischer Test: Parallax ohne Zoom. Das Level fuellt den Bildschirm,
# die Kamera steht still; trotzdem wandert die tiefe Ebene mit der Figur.
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
	check("Kein Zoom", cam.zoom == Vector2.ONE, str(cam.zoom))
	var p = level.get_node("Professor")
	for i in 30: await physics_frame
	p.global_position = Vector2(120, 496)
	for i in 120: await process_frame
	var deep_left: Vector2 = level.get_node("DeepBackground").position
	var wall_left: Vector2 = level.get_node("BackWall").position
	var cam_left := cam.get_screen_center_position()
	p.global_position = Vector2(840, 496)
	for i in 120: await process_frame
	var deep_right: Vector2 = level.get_node("DeepBackground").position
	var wall_right: Vector2 = level.get_node("BackWall").position
	check("Kamera steht still", cam_left.distance_to(cam.get_screen_center_position()) < 1.0)
	check("Tiefe Ebene wandert mit der Figur", deep_right.x - deep_left.x > 40.0, "%.0f -> %.0f" % [deep_left.x, deep_right.x])
	check("Rueckwand bleibt stehen (keine Raender sichtbar)", wall_left == wall_right, "%s -> %s" % [wall_left, wall_right])
	DirAccess.remove_absolute("user://savegame_test.json")
	print("Fehler: %d" % fails)
	quit(1 if fails else 0)
