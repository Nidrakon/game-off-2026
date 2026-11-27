extends SceneTree
# Automatischer Test: Sprechblasen stoeren das Springen nicht. Sprueche
# kommen nur im Stillstand, verschwinden beim Losrennen; Blasen sind klein.
# Wichtige Hinweise (z. B. Fahrstuhl) bleiben stehen.
var fails := 0
func check(name: String, ok: bool, info := "") -> void:
	print(("PASS " if ok else "FAIL ") + name + "  (" + info + ")")
	if not ok: fails += 1


func bubble_of(p: Node) -> SpeechBubble:
	for c in p.get_children():
		if c is SpeechBubble and not c.is_queued_for_deletion():
			return c
	return null


func wait(seconds: float) -> void:
	for i in roundi(seconds * 60.0): await physics_frame


func _initialize() -> void:
	await process_frame
	root.get_node("SaveGame").test_mode = true
	change_scene_to_file("res://scenes/levels/level_base.tscn")
	await process_frame
	while current_scene == null or not current_scene.is_in_group("level"): await process_frame
	var p = current_scene.get_node("Professor")
	var quips = p.get_node("Quips")
	await wait(1.5)
	# Faellig, aber er rennt: kein Spruch
	Input.action_press("move_right")
	await wait(0.3)
	quips._next_quip = 0.0
	await wait(1.0)
	check("Kein Spruch beim Rennen", bubble_of(p) == null)
	Input.action_release("move_right")
	await wait(2.2)
	var b := bubble_of(p)
	check("Spruch kommt, sobald er still steht", b != null)
	if b:
		var w: float = b._panel.size.x
		check("Blase klein (hoechstens 150 px breit)", w <= 150.0, "%.0f px" % w)
	# Losrennen: Spruch verschwindet sofort
	Input.action_press("move_left")
	await wait(0.5)
	Input.action_release("move_left")
	check("Spruch verschwindet beim Losrennen", bubble_of(p) == null)
	# Fahrstuhl-Hinweis bleibt auch beim Laufen stehen
	await wait(1.0)
	SpeechBubble.say(p, "speech_elevator_keycard")
	Input.action_press("move_right")
	await wait(0.5)
	Input.action_release("move_right")
	check("Wichtiger Hinweis bleibt beim Laufen", bubble_of(p) != null)
	# Am linken Rand: Kasten bleibt im Bild
	await wait(3.0)
	for c in p.get_children():
		if c is SpeechBubble: c.queue_free()
	p.global_position = Vector2(30, 496)
	p.velocity = Vector2.ZERO
	await wait(0.5)
	var edge := SpeechBubble.say_text(p, "Without my exoskeleton I'd never have survived that drop.")
	await wait(0.1)
	var r: Rect2 = edge._panel.get_global_rect()
	# Sichtbarer Ausschnitt in Weltkoordinaten (Kamera kann herausgezoomt sein).
	var view: Rect2 = current_scene.get_viewport().get_canvas_transform().affine_inverse() * current_scene.get_viewport().get_visible_rect()
	check("Blase am Rand bleibt im Bild", view.grow(0.5).encloses(r), "%s in %s" % [r, view])
	DirAccess.remove_absolute("user://savegame_test.json")
	print("Fehler: %d" % fails)
	quit(1 if fails else 0)
