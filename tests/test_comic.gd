extends SceneTree
# Automatischer Test: Bilduntertexte in Intro und Ende. Jedes Panel (ausser
# dem Fahrstuhl im Abspann) hat einen Text, er passt aufs Bild und ueberdeckt
# die Tastenhinweise nicht.
var fails := 0
func check(name: String, ok: bool, info := "") -> void:
	print(("PASS " if ok else "FAIL ") + name + "  (" + info + ")")
	if not ok: fails += 1


func open(path: String) -> Node:
	var old = current_scene
	change_scene_to_file(path)
	await process_frame
	while current_scene == null or current_scene == old: await process_frame
	await process_frame
	return current_scene


func captions_ok(scene: Node, prefix: String, skip: Array) -> Array:
	var problems := []
	for name in scene._panels:
		var panel: Control = scene._panels[name]
		var caps := panel.get_children().filter(func(c): return c is ComicCaption)
		if skip.has(name):
			if not caps.is_empty():
				problems.append(name + ": unerwarteter Text")
			continue
		if caps.size() != 1:
			problems.append(name + ": kein Text")
			continue
		var cap: ComicCaption = caps[0]
		var text := cap.get_text()
		var r := cap.get_global_rect()
		if text == prefix + name or text.length() < 5:
			problems.append(name + ": Text fehlt in comic.json")
		if r.end.y > 500.0 or r.position.x < 0.0 or r.end.x > 960.0:
			problems.append("%s: ragt heraus %s" % [name, r])
	return problems


func _initialize() -> void:
	await process_frame
	root.get_node("SaveGame").test_mode = true
	var intro = await open("res://scenes/ui/intro.tscn")
	var all := []
	for i in intro.STEPS.size():
		await process_frame
		await create_timer(0.2).timeout
		all += captions_ok(intro, "intro_", [])
		if i < intro.STEPS.size() - 1:
			intro.next_step()
	check("Intro: jedes Panel mit passendem Untertext", all.is_empty(), str(all))
	root.get_node("Sfx").stop_music()
	var ending = await open("res://scenes/ui/ending.tscn")
	all = []
	while true:
		await create_timer(0.2).timeout
		all += captions_ok(ending, "ending_", ["e4"])
		if ending.get_step() >= ending.STEPS.size() - 1:
			break
		ending.next_step()
	check("Ende: jedes Panel mit passendem Untertext, Fahrstuhl ohne", all.is_empty(), str(all))
	root.get_node("Sfx").stop_music()
	DirAccess.remove_absolute("user://savegame_test.json")
	print("Fehler: %d" % fails)
	quit(1 if fails else 0)
