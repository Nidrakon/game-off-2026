extends SceneTree
# Automatischer Test: Freischalten des Time Shifters und Aufbau der ersten
# Level (v0.65). Level 1 und 2: Time Shifter ganz gesperrt; Level 3 bringt
# ihn (nur langsam), Level 5 die Stufe "schnell".
var fails := 0
func check(name: String, ok: bool, info := "") -> void:
	print(("PASS " if ok else "FAIL ") + name + "  (" + info + ")")
	if not ok: fails += 1


func open_level(path: String) -> Node:
	var old = current_scene
	change_scene_to_file(path)
	await process_frame
	while current_scene == null or current_scene == old or not current_scene.is_in_group("level"): await process_frame
	await process_frame
	return current_scene


func hints_of(level: Node) -> Array:
	var hints := []
	for n in level.find_children("*", "", true, false):
		if "keys" in n and "text_id" in n: hints.append(" ".join(n.keys))
	return hints


func heaps_of(level: Node) -> Array:
	return level.find_children("*", "Area2D", true, false).filter(func(n): return "upgrade" in n and n.has_signal("collected"))


func _initialize() -> void:
	await process_frame
	root.get_node("SaveGame").test_mode = true
	var upgrades = root.get_node("Upgrades")
	upgrades.reset()
	var order: Array = root.get_node("LevelFlow").get_levels()
	check("Level 5 und 6 in der Reihenfolge (alte 7/8)", order.size() >= 6 and order[4].ends_with("level_05.tscn") and order[5].ends_with("level_06.tscn"), str(order))

	# Level 1: klein, keine sichtbare Klonstation, kein Sprung-Hinweis
	var l1 = await open_level("res://scenes/levels/level_01.tscn")
	var used: Rect2i = l1.get_node("Ground").get_used_rect()
	check("Level 1: 36 x 17 Tiles", used.size == Vector2i(36, 17), str(used))
	check("Level 1: Klonstation unsichtbar", not l1.get_node("CloneStation").visible)
	check("Level 1: kein Sprung-Hinweis", not ("SPACE" in hints_of(l1)), str(hints_of(l1)))
	check("Level 1: Ausgang im Raum", l1.get_node("LevelExit").position.x < 36 * 16, str(l1.get_node("LevelExit").position))

	# Level 2: Sprung-Hinweis, Time Shifter gesperrt
	var l2 = await open_level("res://scenes/levels/level_02.tscn")
	check("Level 2: nur Sprung-Hinweis", hints_of(l2) == ["SPACE"], str(hints_of(l2)))
	var bubble = l2.get_node("Professor/TimeBubble")
	var panel = l2.get_node("TimeShifterPanel")
	bubble.stage = 0
	check("Level 2: keine Zeitstufe ausser normal", bubble.stage == 1, str(bubble.stage))
	check("Level 2: Shift oeffnet kein Bedienfeld", not panel.is_unlocked())
	check("Level 2: Zeitanzeige versteckt", not l2.get_node("TimeStageIndicator").get_child(0).visible if l2.get_node("TimeStageIndicator").get_child_count() > 0 else true)

	# Level 3: Haufen "Time Shifter" am Anfang, Hinweis Shift + Rad runter
	var l3 = await open_level("res://scenes/levels/level_03.tscn")
	var h3 := heaps_of(l3)
	check("Level 3: Haufen Time Shifter am Anfang", h3.size() == 1 and h3[0].upgrade == 3 and h3[0].position.x < 200, str(h3.size()))
	check("Level 3: Hinweis SHIFT + WHEEL DOWN", hints_of(l3) == ["SHIFT + WHEEL DOWN"], str(hints_of(l3)))
	check("Level 3: vor dem Haufen noch gesperrt", not upgrades.has(3))

	# Level 4: Time Shifter da (nur langsam), keine Hinweise
	var l4 = await open_level("res://scenes/levels/level_04.tscn")
	check("Level 4: Time Shifter eingebaut", upgrades.has(3))
	check("Level 4: kein Steuerungshinweis", hints_of(l4).is_empty(), str(hints_of(l4)))
	bubble = l4.get_node("Professor/TimeBubble")
	panel = l4.get_node("TimeShifterPanel")
	bubble.stage = 0
	check("Level 4: langsam moeglich", bubble.stage == 0, str(bubble.stage))
	bubble.stage = 2
	check("Level 4: schnell gesperrt", bubble.stage == 0, str(bubble.stage))
	bubble.stage = 1
	panel.visible = true
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	wheel.pressed = true
	panel._input(wheel)
	check("Level 4: Mausrad hoch bleibt auf normal", bubble.stage == 1, str(bubble.stage))
	panel.visible = false
	check("Level 4: kein Radius, keine Form", not upgrades.has(0) and not upgrades.has(1))
	# Bedienfeld: im Editor ausgeblendet (visible = false in der Vorlage),
	# im Spiel oeffnet Shift es trotzdem.
	check("Bedienfeld startet ausgeblendet", not panel.visible)
	Input.action_press("time_shifter_panel")
	await process_frame
	await process_frame
	check("Shift oeffnet das Bedienfeld", panel.visible)
	Input.action_release("time_shifter_panel")
	await process_frame
	await process_frame
	check("Loslassen schliesst es", not panel.visible and not paused)

	# Level 5: Haufen "schnell" am Anfang, Hinweis Shift + Rad hoch
	var l5 = await open_level("res://scenes/levels/level_05.tscn")
	var h5 := heaps_of(l5)
	check("Level 5: Haufen schnell am Anfang", h5.size() == 1 and h5[0].upgrade == 2 and h5[0].position.x < 200, str(h5.size()))
	check("Level 5: Hinweis SHIFT + WHEEL UP", hints_of(l5) == ["SHIFT + WHEEL UP"], str(hints_of(l5)))
	upgrades.unlock(2)
	bubble = l5.get_node("Professor/TimeBubble")
	bubble.stage = 2
	check("Mit Upgrade schnell moeglich", bubble.stage == 2, str(bubble.stage))
	upgrades.reset()
	check("Zuruecksetzen schaltet auf normal", bubble.stage == 1, str(bubble.stage))
	upgrades.set_ids(PackedStringArray(["upgrade_fast", "upgrade_time_shifter"]))
	check("Kennungen im Spielstand", upgrades.has(2) and upgrades.has(3), str(upgrades.get_ids()))
	upgrades.reset()

	# Level 6 bringt beides mit (direkt gestartet)
	await open_level("res://scenes/levels/level_06.tscn")
	check("Level 6: Time Shifter und schnell da", upgrades.has(3) and upgrades.has(2))
	upgrades.reset()

	# Level 8: Haufen "Form" am Anfang
	var l8 = await open_level("res://scenes/levels/level_08.tscn")
	var h8 := heaps_of(l8)
	check("Level 8: Haufen Form am Anfang", h8.size() == 1 and h8[0].upgrade == 1 and h8[0].position.x < 200, str(h8.size()))
	upgrades.reset()

	# Zwei Einblendungen kurz hintereinander: die zweite wartet
	var m1 = UpgradeMessage.show_for(2, self)
	var m2 = UpgradeMessage.show_for(3, self)
	await process_frame
	check("Erste Einblendung sichtbar, zweite wartet", m1.visible and not m2.visible)
	m1.queue_free()
	await process_frame
	await process_frame
	check("Danach erscheint die zweite", is_instance_valid(m2) and m2.visible)
	DirAccess.remove_absolute("user://savegame_test.json")
	print("Fehler: %d" % fails)
	quit(1 if fails else 0)
