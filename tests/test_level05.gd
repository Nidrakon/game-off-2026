extends SceneTree
# Automatischer Test: Level 5 (frueher 7), Laser dauerhaft an; die Lichtschranke schaltet
# ihn fuer 3 s ab, jedes weitere Ausloesen setzt den Countdown zurueck.
var fails := 0
func check(name: String, ok: bool, info := "") -> void:
	print(("PASS " if ok else "FAIL ") + name + "  (" + info + ")")
	if not ok: fails += 1


func wait(seconds: float) -> void:
	for i in roundi(seconds * 60.0): await physics_frame


func _initialize() -> void:
	await process_frame
	root.get_node("SaveGame").test_mode = true
	change_scene_to_file("res://scenes/levels/level_05.tscn")
	await process_frame
	while current_scene == null or not current_scene.is_in_group("level"): await process_frame
	var laser = current_scene.get_node("DeadlyLaser")
	var barrier = current_scene.get_node("LightBarrier")
	await wait(5.0)
	check("Laser dauerhaft an", laser.is_on())
	SignalSender.send(barrier.targets, barrier.action, barrier)
	await wait(0.1)
	check("Lichtschranke schaltet ab", not laser.is_on())
	await wait(2.0)
	SignalSender.send(barrier.targets, barrier.action, barrier)
	await wait(2.5)
	check("Erneutes Ausloesen setzt Countdown zurueck", not laser.is_on())
	await wait(0.6)
	check("Nach 3 s wieder an", laser.is_on())
	await wait(5.0)
	check("... und bleibt an", laser.is_on())
	DirAccess.remove_absolute("user://savegame_test.json")
	print("Fehler: %d" % fails)
	quit(1 if fails else 0)
