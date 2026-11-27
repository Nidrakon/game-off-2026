extends SceneTree
# Automatischer Test: Steht der Professor auf einer waagrechten Rakete,
# erfasst schon die kleinste Zeitblase die Rakete, egal wo er steht (auch
# ganz vorn an der Spitze). Wunsch des Nutzers, v0.82.
var fails := 0
func check(name: String, ok: bool, info := "") -> void:
	print(("PASS " if ok else "FAIL ") + name + "  (" + info + ")")
	if not ok: fails += 1


func _initialize() -> void:
	await process_frame
	root.get_node("SaveGame").test_mode = true
	var upgrades = root.get_node("Upgrades")
	upgrades.reset()
	upgrades.unlock(3)
	change_scene_to_file("res://scenes/levels/level_base.tscn")
	await process_frame
	while current_scene == null or not current_scene.is_in_group("level"): await process_frame
	var level = current_scene
	var p = level.get_node("Professor")
	var bubble = p.get_node("TimeBubble")
	check("Ohne Radius-Upgrade: kleinste Blase", is_equal_approx(bubble.radius, bubble.settings.radius_min), "%.0f px" % bubble.radius)
	var free := []
	for dir in [1.0, -1.0]:
		var rocket = load("res://scenes/objects/projectile.tscn").instantiate()
		rocket.speed = 0.0
		rocket.direction = dir
		rocket.sync_to_physics = false
		rocket.position = Vector2(480, 300)
		level.add_child(rocket)
		await physics_frame
		var ta = rocket.get_node("TimeAffected")
		var top: float = rocket.global_position.y - 16.0
		bubble.stage = 0
		# Professor (18 px breit) steht auf der Rakete (64 px) von ganz links
		# bis ganz rechts.
		for dx in range(-40, 41, 2):
			p.global_position = Vector2(480 + dx, top)
			p.velocity = Vector2.ZERO
			await physics_frame
			await physics_frame
			if is_equal_approx(ta.time_scale, 1.0):
				free.append("%s:%d" % ["rechts" if dir > 0 else "links", dx])
		bubble.stage = 1
		rocket.queue_free()
		await physics_frame
	check("Rakete unter dem Professor ueberall erfasst", free.is_empty(), str(free))
	upgrades.reset()
	DirAccess.remove_absolute("user://savegame_test.json")
	print("Fehler: %d" % fails)
	quit(1 if fails else 0)
