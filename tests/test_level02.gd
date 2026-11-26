extends SceneTree
# Automatischer Test: Level 2 (Projektil-Regen direkt nach der Werkstatt).
# Gedrehte Werfer schiessen nach unten (Takte zufaellig verteilt); mit
# Time Shifter ist hier noch gesperrt; nur der Sprung-Hinweis.
var fails := 0
func check(name: String, ok: bool, info := "") -> void:
	print(("PASS " if ok else "FAIL ") + name + "  (" + info + ")")
	if not ok: fails += 1

const LEVEL := "res://scenes/levels/level_02.tscn"

var _died := false

func _on_died() -> void:
	_died = true

## Neu laden und den Professor holen.
func load_level() -> Node:
	var old = current_scene
	change_scene_to_file(LEVEL)
	await process_frame
	while current_scene == null or current_scene == old or not current_scene.is_in_group("level"): await process_frame
	_died = false
	current_scene.get_node("Professor").died.connect(_on_died)
	return current_scene


## Ein Versuch: ab start_delay nach rechts laufen (Blase normal) und nach
## slow_after Sekunden Laufen auf langsam schalten (< 0 = nie). Loesung fuer
## Spieler: losrennen, sobald eine Welle aufschlaegt, gleich auf langsam
## schalten (Shift pausiert das Spiel, kostet also keine Zeit); die Blase
## bremst die naechste Welle direkt vor der Figur gerade lange genug.
## Ergebnis: "exit", "dead" oder "timeout".
func run_attempt(start_delay: float, slow_after: float) -> String:
	var level = await load_level()
	var p = level.get_node("Professor")
	var bubble = p.get_node("TimeBubble")
	bubble.stage = 1
	# In Physik-Schritten warten (wie die Werfer zaehlen): reproduzierbar
	for i in roundi(start_delay * 60.0): await physics_frame
	Input.action_press("move_right")
	var result := "timeout"
	var t := 0.0
	while t < 6.0:
		await physics_frame
		t += 1.0 / 60.0
		if slow_after >= 0.0 and t >= slow_after and is_instance_valid(bubble):
			bubble.stage = 0
		if _died or not is_instance_valid(p):
			result = "dead"
			break
		if p.is_leaving or level.get_node("LevelExit").is_used():
			result = "exit"
			break
	Input.action_release("move_right")
	# Nach einem Tod laedt die Klonstation das Level verzoegert neu: abwarten,
	# sonst ueberschreibt das den naechsten Versuch.
	if result == "dead":
		await create_timer(1.5).timeout
	return result


func _initialize() -> void:
	await process_frame
	root.get_node("SaveGame").test_mode = true
	root.get_node("Upgrades").reset()
	var order: Array = root.get_node("LevelFlow").get_levels()
	check("Level 2 kommt direkt nach der Werkstatt", order.size() > 1 and order[0].ends_with("level_01.tscn") and order[1] == LEVEL, str(order.slice(0, 3)))
	change_scene_to_file(LEVEL)
	await process_frame
	while current_scene == null or not current_scene.is_in_group("level"): await process_frame
	var level = current_scene
	var hints := []
	for n in level.find_children("*", "", true, false):
		if "keys" in n: hints.append(" ".join(n.keys))
	check("Level 2: nur der Sprung-Hinweis", hints == ["SPACE"], str(hints))
	var w1 = load("res://scenes/levels/level_01.tscn").instantiate()
	var w_hints := []
	for n in w1.find_children("*", "", true, false):
		if "keys" in n: w_hints.append(" ".join(n.keys))
	w1.free()
	check("Werkstatt ohne Shift-Hinweis", not ("SHIFT" in w_hints), str(w_hints))
	# Gedrehte Werfer schiessen nach unten
	await create_timer(2.3).timeout
	var projectiles := level.find_children("*", "AnimatableBody2D", true, false)
	var down := projectiles.filter(func(pr): return absf(pr.rotation - PI / 2) < 0.01)
	check("Projektile fliegen nach unten", projectiles.size() >= 10 and down.size() == projectiles.size(), "%d/%d" % [down.size(), projectiles.size()])
	var y0: float = projectiles[0].global_position.y if not projectiles.is_empty() else 0.0
	await create_timer(0.3).timeout
	check("... und fallen tatsaechlich", not projectiles.is_empty() and is_instance_valid(projectiles[0]) and projectiles[0].global_position.y > y0 + 20.0)
	# Takte zufaellig verteilt (Wunsch des Nutzers): Intervall 2-4 s,
	# erster Schuss 1-2 s.
	var launchers := level.get_node("Launchers").get_children().filter(func(n): return "fire_interval" in n)
	var in_range := launchers.filter(func(l): return l.fire_interval >= 2.0 and l.fire_interval <= 4.0 and l.first_shot_delay >= 1.0 and l.first_shot_delay <= 2.0)
	var intervals := {}
	for l in launchers: intervals[l.fire_interval] = true
	check("Werfer-Takte 2-4 s, Start 1-2 s, verschieden", launchers.size() == 16 and in_range.size() == 16 and intervals.size() >= 6, "%d/%d, %d Takte" % [in_range.size(), launchers.size(), intervals.size()])
	# Schaffbarkeit ohne Time Shifter (seit v0.65 in Level 2 gesperrt).
	# Scan ueber 300 Startzeitpunkte 0-30 s: 3 Treffer (8,1 / 10,5 / 20,9 s).
	var normal_results := []
	for delay in [8.1, 10.5, 20.9]:
		normal_results.append(await run_attempt(delay, -1.0))
	check("Ohne Time Shifter schaffbar (knapp)", normal_results.count("exit") >= 2, str(normal_results))
	DirAccess.remove_absolute("user://savegame_test.json")
	print("Fehler: %d" % fails)
	quit(1 if fails else 0)
