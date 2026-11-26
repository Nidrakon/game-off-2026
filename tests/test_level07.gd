extends SceneTree
# Automatischer Test: Level 7 und seine Kopie Level 8. Zwei gleich schnelle, versetzte
# Zeitschaltuhren loesen je einen Raketenwerfer aus; die Tuer geht nur auf,
# wenn beide Raketen (fast) gleichzeitig ihre Trefferflaeche treffen. Dazu
# muss man eine Uhr mit dem Time Shifter in Gleichtakt bringen.
var fails := 0
func check(name: String, ok: bool, info := "") -> void:
	print(("PASS " if ok else "FAIL ") + name + "  (" + info + ")")
	if not ok: fails += 1


func wait(seconds: float) -> void:
	for i in roundi(seconds * 60.0): await physics_frame


var level_path := "res://scenes/levels/level_07.tscn"


func load_level() -> Node:
	var old = current_scene
	change_scene_to_file(level_path)
	await process_frame
	while current_scene == null or current_scene == old or not current_scene.is_in_group("level"): await process_frame
	await process_frame
	return current_scene


## Phasenunterschied der beiden Uhren (Sekunden, 0 = Gleichtakt).
func phase_gap(a, b) -> float:
	var d := fposmod(a._time_left - b._time_left, a.duration)
	return minf(d, a.duration - d)


func _initialize() -> void:
	await process_frame
	root.get_node("SaveGame").test_mode = true
	for path in ["res://scenes/levels/level_07.tscn", "res://scenes/levels/level_08.tscn"]:
		level_path = path
		print("-- ", path.get_file())
		root.get_node("Upgrades").reset()
		await run_puzzle()
	DirAccess.remove_absolute("user://savegame_test.json")
	print("Fehler: %d" % fails)
	quit(1 if fails else 0)


func run_puzzle() -> void:
	var level = await load_level()
	var clock1 = level.get_node("TimeSwitch")
	var clock2 = level.get_node("TimeSwitch2")
	var door = level.get_node("Door")
	var gate = level.get_node("SyncGate")
	check("Time Shifter in Level 7 da", root.get_node("Upgrades").has(3))
	check("Uhren gleich schnell", is_equal_approx(clock1.duration, clock2.duration))
	check("Uhren versetzt", phase_gap(clock1, clock2) > 1.0, "%.2f s" % phase_gap(clock1, clock2))
	# Ohne Time Shifter: Raketen kommen nie gleichzeitig, Tuer bleibt zu
	var hits := [0]
	level.get_node("ImpactSwitch").triggered.connect(func(): hits[0] += 1)
	await wait(14.0)
	check("Raketen treffen die Schalter", hits[0] >= 2, str(hits[0]))
	check("Ohne Time Shifter bleibt die Tuer zu", not gate.is_done())
	# Mit Time Shifter: neben Uhr 2 stellen (Uhr 1 ausserhalb der Blase),
	# langsam schalten, bis beide im Gleichtakt sind.
	level = await load_level()
	clock1 = level.get_node("TimeSwitch")
	clock2 = level.get_node("TimeSwitch2")
	gate = level.get_node("SyncGate")
	var p = level.get_node("Professor")
	var bubble = p.get_node("TimeBubble")
	await wait(1.0)
	p.global_position = Vector2(clock2.global_position.x - 40, 496)
	await wait(0.3)
	bubble.stage = 0
	var t := 0.0
	while phase_gap(clock1, clock2) > 0.08 and t < 12.0:
		await physics_frame
		t += 1.0 / 60.0
	bubble.stage = 1
	check("Uhren mit der Zeitblase in Gleichtakt gebracht", phase_gap(clock1, clock2) <= 0.08, "nach %.1f s, Rest %.2f s" % [t, phase_gap(clock1, clock2)])
	await wait(9.0)
	var door_y: float = level.get_node("Door").position.y
	check("Gleichzeitige Treffer oeffnen die Tuer", gate.is_done() and door_y < 456.0 - 60.0, "Tuer y %.0f" % door_y)
