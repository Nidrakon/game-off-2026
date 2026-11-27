extends SceneTree
# Automatischer Test: Zeitblase pixelgenau, Schalter "time_shifter" je
# Baustein, Raketen von gedrehten Werfern rundum toedlich.
var fails := 0
func check(name: String, ok: bool, info := "") -> void:
	print(("PASS " if ok else "FAIL ") + name + "  (" + info + ")")
	if not ok: fails += 1
func frames(n: int) -> void:
	for i in n: await physics_frame

const BLOCKS := ["deadly_laser", "door", "flying_platform", "pendulum", "projectile_launcher", "steam_vent", "time_switch", "magnet", "deco_prop"]

func _initialize() -> void:
	await process_frame
	root.get_node("SaveGame").test_mode = true
	change_scene_to_file("res://scenes/test/fixtures/fixture_level_a.tscn")
	while current_scene == null or not current_scene.is_in_group("level"): await process_frame
	await frames(10)
	var level = current_scene
	var p = level.get_node("Professor")
	# In die Levelmitte: am Rand ist seit v0.79 massive Wand (Raketen zerschellen).
	p.global_position = Vector2(480, 496)
	for i in 5: await physics_frame
	var bubble = p.get_node("TimeBubble")
	bubble.stage = 0
	# Schalter in allen Bausteinen
	var missing := []
	for b in BLOCKS:
		var obj = load("res://scenes/objects/%s.tscn" % b).instantiate()
		if not ("time_shifter" in obj): missing.append(b)
		obj.free()
	check("Alle Zeit-Bausteine haben den Schalter time_shifter", missing.is_empty(), str(missing))
	var launcher_probe = load("res://scenes/objects/projectile_launcher.tscn").instantiate()
	check("Werfer: eigener Schalter fuer die Raketen", "projectile_time_shifter" in launcher_probe)
	launcher_probe.free()
	# Rakete ohne Bewegung neben die Blase legen (Pixel-Umriss)
	var rocket = load("res://scenes/objects/projectile.tscn").instantiate()
	rocket.speed = 0.0
	# Im Test frei verschieben (sonst uebernimmt der Koerper neue Positionen nicht)
	rocket.sync_to_physics = false
	level.add_child(rocket)
	var ta: TimeAffected = rocket.get_node("TimeAffected")
	var polys := ta.get_global_polygons()
	check("Pixel-Umriss statt Rechteck", polys.size() >= 1 and polys[0].size() > 4, "%d Punkte" % (polys[0].size() if polys.size() else 0))
	# Ecke des Rechtecks transparent? Dann darf die Blase dort noch nicht wirken.
	var img: Image = (rocket.get_node("Sprite") as Sprite2D).texture.get_image()
	var corner_free := img.get_pixel(img.get_width() - 1, img.get_height() - 1).a < 0.1
	check("Testbild hat eine transparente Ecke (Spitze unten rechts)", corner_free)
	var center: Vector2 = bubble.global_position
	var r: float = bubble.radius
	# Rakete links oberhalb der Blase: nur ihre rechte untere Rechteck-Ecke
	# (transparent) liegt 2 px in der Blase.
	var corner_target := center + Vector2(-1, -1).normalized() * (r - 2.0)
	rocket.global_position = corner_target - Vector2(32, 16)
	await frames(3)
	var rect_inside: bool = bubble.overlaps_rect(Rect2(rocket.global_position + Vector2(-32, -16), Vector2(64, 32)))
	check("Rechteck wuerde die Blase schon beruehren", rect_inside)
	check("Pixelgenau: noch kein Effekt (nur transparente Ecke in der Blase)", is_equal_approx(ta.time_scale, 1.0), str(ta.time_scale))
	rocket.global_position = center + Vector2(0, -r - 20.0)
	await frames(2)
	check("Ganz ausserhalb: kein Effekt", is_equal_approx(ta.time_scale, 1.0))
	rocket.global_position = center + Vector2(0, -r + 14.0)
	await frames(3)
	check("Sichtbare Pixel in der Blase: langsam", is_equal_approx(ta.time_scale, bubble.get_time_scale()), str(ta.time_scale))
	# Schalter aus: kein Effekt mehr
	ta.active = false
	await frames(2)
	check("Schalter aus: normales Tempo in der Blase", is_equal_approx(ta.time_scale, 1.0), str(ta.time_scale))
	rocket.queue_free()
	# Werfer: getrennte Schalter
	var launcher = load("res://scenes/objects/projectile_launcher.tscn").instantiate()
	launcher.time_shifter = false
	launcher.projectile_time_shifter = false
	launcher.first_shot_delay = 0.05
	launcher.global_position = center + Vector2(-40, -10)
	level.add_child(launcher)
	await frames(12)
	check("Werfer-Schalter aus: Werfer im normalen Tempo", is_equal_approx(launcher.get_node("TimeAffected").time_scale, 1.0))
	var spawned := level.find_children("*", "AnimatableBody2D", true, false).filter(func(n): return "time_shifter" in n and n != launcher)
	check("Rakete erbt den Raketen-Schalter", not spawned.is_empty() and spawned.all(func(s): return not s.time_shifter and not s.get_node("TimeAffected").active), str(spawned.size()))
	launcher.queue_free()
	for s in spawned: s.queue_free()
	# Gedrehte Rakete: rundum toedlich, etwas groesser als der Koerper
	var down = load("res://scenes/objects/projectile.tscn").instantiate()
	down.rotation = PI / 2
	down.speed = 0.0
	down.global_position = Vector2(-500, -500)
	level.add_child(down)
	var hz := (down.get_node("SideHazard/Collision") as CollisionShape2D).shape as RectangleShape2D
	check("Senkrechte Rakete: Gefahrenzone rundum groesser als der Koerper", hz.size.x >= 66.0 and hz.size.y >= 36.0, str(hz.size))
	check("Senkrechte Rakete: kein Mitfahren", not down.is_horizontal())
	var flat = load("res://scenes/objects/projectile.tscn").instantiate()
	flat.speed = 0.0
	flat.global_position = Vector2(-500, -800)
	level.add_child(flat)
	var hz2 := (flat.get_node("SideHazard/Collision") as CollisionShape2D).shape as RectangleShape2D
	check("Waagrechte Rakete unveraendert (oben mitfahren)", hz2.size == Vector2(66, 24), str(hz2.size))
	DirAccess.remove_absolute("user://savegame_test.json")
	print("Fehler: %d" % fails)
	quit(1 if fails else 0)
