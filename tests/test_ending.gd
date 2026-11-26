extends SceneTree
# Automatischer Test: Ende. Comic (Pointe mit der Keycard), danach faehrt
# der Professor im Fahrstuhl nach unten, daneben laufen die Credits, dazu
# die Fahrstuhlmusik (Song 6).
var fails := 0
func check(name: String, ok: bool, info := "") -> void:
	print(("PASS " if ok else "FAIL ") + name + "  (" + info + ")")
	if not ok: fails += 1


func _initialize() -> void:
	await process_frame
	root.get_node("SaveGame").test_mode = true
	var sfx = root.get_node("Sfx")
	sfx.stop_music()
	change_scene_to_file("res://scenes/ui/ending.tscn")
	await process_frame
	await process_frame
	var ending = current_scene
	check("Comic: noch keine Fahrstuhlmusik", sfx.get_music_id() != 6, str(sfx.get_music_id()))
	while ending.get_step() < ending.STEPS.size() - 1:
		ending.next_step()
	await process_frame
	check("Letzter Schritt ist der Fahrstuhl", ending.STEPS[ending.get_step()] == ["e4"], str(ending.STEPS[ending.get_step()]))
	check("Fahrstuhl-Panel sichtbar", ending._panels.has("e4") and ending._panels["e4"].texture.atlas.get_width() > 220)
	check("Credits laufen", ending.phase == ending.Phase.CREDITS)
	check("Fahrstuhlmusik (Song 6)", sfx.get_music_id() == 6, str(sfx.get_music_id()))
	var y0: float = ending._credits.position.y
	for i in 30: await process_frame
	check("Credits scrollen nach oben", ending._credits.position.y < y0)
	ending.skip_to_end()
	check("Esc: THE END", ending.phase == ending.Phase.END)
	sfx.stop_music()
	DirAccess.remove_absolute("user://savegame_test.json")
	print("Fehler: %d" % fails)
	quit(1 if fails else 0)
