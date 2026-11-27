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


## Uhren von links nach rechts.
func clocks_of(level: Node) -> Array:
	var clocks := level.find_children("TimeSwitch*", "", false, false)
	clocks.sort_custom(func(a, b): return a.position.x < b.position.x)
	return clocks


func run_puzzle() -> void:
	var level = await load_level()
	var clocks := clocks_of(level)
	var gate = level.get_node("SyncGate")
	check("Time Shifter da", root.get_node("Upgrades").has(3))
	# Optik: linke Uhr gehoert zum linken Werfer usw.
	var target_x := clocks.map(func(c): return c.targets[0].position.x)
	var sorted_x := target_x.duplicate()
	sorted_x.sort()
	check("Uhren in derselben Reihenfolge wie ihre Werfer", target_x == sorted_x, str(target_x))
	check("Gleichzeitig-Schalter hat alle Trefferflaechen", gate.sources.size() == clocks.size(), "%d/%d" % [gate.sources.size(), clocks.size()])
	var same := clocks.all(func(c): return is_equal_approx(c.duration, clocks[0].duration))
	check("Uhren gleich schnell", same)
	var ref = clocks[clocks.size() / 2]
	var gaps := clocks.map(func(c): return phase_gap(c, ref))
	check("Uhren versetzt", gaps.filter(func(g): return g > 0.5).size() == clocks.size() - 1, str(gaps))
	# Ohne Time Shifter: Raketen kommen nie gleichzeitig, Tuer bleibt zu
	var hits := [0]
	clocks[0].targets[0].get_parent().get_node(NodePath(str(gate.sources[0]).trim_prefix("../"))).triggered.connect(func(): hits[0] += 1)
	await wait(14.0)
	check("Raketen treffen die Schalter", hits[0] >= 2, str(hits[0]))
	check("Ohne Time Shifter bleibt die Tuer zu", not gate.is_done())
	# Mit Time Shifter: jede andere Uhr von aussen her verlangsamen, bis sie
	# mit der mittleren (Bezug) im Gleichtakt ist.
	level = await load_level()
	clocks = clocks_of(level)
	gate = level.get_node("SyncGate")
	ref = clocks[clocks.size() / 2]
	var p = level.get_node("Professor")
	var bubble = p.get_node("TimeBubble")
	await wait(1.0)
	for c in clocks:
		if c == ref:
			continue
		var side := -40.0 if c.position.x < ref.position.x else 40.0
		p.global_position = Vector2(c.global_position.x + side, c.global_position.y + 16)
		await wait(0.2)
		bubble.stage = 0
		var t := 0.0
		while phase_gap(c, ref) > 0.06 and t < 12.0:
			await physics_frame
			t += 1.0 / 60.0
		bubble.stage = 1
		check("Uhr bei x %d in Gleichtakt gebracht" % c.position.x, phase_gap(c, ref) <= 0.06, "nach %.1f s, Rest %.2f s" % [t, phase_gap(c, ref)])
	p.global_position = Vector2(100, 496)
	await wait(9.0)
	var door_y: float = level.get_node("Door").position.y
	check("Gleichzeitige Treffer oeffnen die Tuer", gate.is_done() and door_y < 456.0 - 60.0, "Tuer y %.0f" % door_y)
