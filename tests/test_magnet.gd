extends SceneTree
# Automatischer Test: Elektromagnet, Parameter "mode" (Anziehen/Abstossen).
var fails := 0
func check(name: String, ok: bool, info := "") -> void:
	print(("PASS " if ok else "FAIL ") + name + "  (" + info + ")")
	if not ok: fails += 1


func _initialize() -> void:
	await process_frame
	root.get_node("SaveGame").test_mode = true
	# Eigener Boden-Magnet (180 Grad gedreht) im Modus Abstossen, in einem
	# leeren Level ohne Gefahren.
	change_scene_to_file("res://scenes/levels/level_06.tscn")
	await process_frame
	while current_scene == null or not current_scene.is_in_group("level"): await process_frame
	for n in current_scene.find_children("*", "StaticBody2D", true, false):
		if "lift_speed" in n: n.queue_free()
	var magnet = load("res://scenes/objects/magnet.tscn").instantiate()
	magnet.position = Vector2(480, 496)
	magnet.rotation = PI
	magnet.mode = 1
	current_scene.add_child(magnet)
	for i in 60: await physics_frame
	var p = current_scene.get_node("Professor")
	magnet.always_on = true
	p.global_position = magnet.global_position + Vector2(0, -40)
	var y0: float = p.global_position.y
	for i in 30: await physics_frame
	check("Abstossen: Professor fliegt vom Boden-Magneten weg (nach oben)", p.global_position.y < y0 - 40.0, "%.0f -> %.0f" % [y0, p.global_position.y])
	# Anziehen: derselbe Magnet haelt ihn unten
	magnet.mode = 0
	p.global_position = magnet.global_position + Vector2(0, -120)
	p.velocity = Vector2.ZERO
	for i in 60: await physics_frame
	var gap: float = magnet.global_position.y - p.global_position.y
	check("Anziehen: Professor bleibt dicht am Boden-Magneten", gap < 60.0, "Abstand %.0f" % gap)
	DirAccess.remove_absolute("user://savegame_test.json")
	print("Fehler: %d" % fails)
	quit(1 if fails else 0)
