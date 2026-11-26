extends SceneTree
# Automatischer Test: Spielgefuehl (Squash/Stretch, harte Landung, Staub,
# Schritt-Takt, keine Kamera-Spielereien, Blase nur bei langsam/schnell).
var fails := 0
func check(name: String, ok: bool, info := "") -> void:
	print(("PASS " if ok else "FAIL ") + name + "  (" + info + ")")
	if not ok: fails += 1
func frames(n: int) -> void:
	for i in n: await physics_frame
var _feel
var _cam
var _sprite: AnimatedSprite2D
var _squash := [Vector2.ONE]
var _shook := [false]
var _landed := [0.0]
var _step_frames := []
func _on_landed(v: float) -> void:
	_landed[0] = v
	_squash[0] = _feel.get_squash()
	_shook[0] = _cam.is_shaking()
func _on_stepped() -> void:
	_step_frames.append(_sprite.frame)
func _initialize() -> void:
	await process_frame
	root.get_node("SaveGame").test_mode = true
	# Zeitstufen brauchen den eingebauten Time Shifter (Upgrade, seit v0.65).
	root.get_node("Upgrades").unlock_all()
	change_scene_to_file("res://scenes/test/fixtures/fixture_level_a.tscn")
	while current_scene == null: await process_frame
	await frames(60)
	var level = current_scene
	var p: CharacterBody2D = level.get_node("Professor")
	var feel = p.get_node("Feel")
	var cam: Camera2D = level.get_node("Camera")
	_feel = feel; _cam = cam; _sprite = p.get_node("Sprite")
	check("Feel-Baustein in Gruppe", feel.is_in_group("game_feel"))
	check("Steht in Grundform", feel.get_squash().is_equal_approx(Vector2.ONE), str(feel.get_squash()))
	# Sprung: Streckung
	Input.action_press("jump")
	await frames(2)
	Input.action_release("jump")
	var s: Vector2 = feel.get_squash()
	check("Absprung streckt", s.y > 1.05 and s.x < 0.95, str(s))
	await frames(80)
	check("Federt zurueck", feel.get_squash().distance_to(Vector2.ONE) < 0.05, str(feel.get_squash()))
	# Harte Landung aus der Hoehe
	p.global_position += Vector2(0, -300)
	p.velocity = Vector2(300, 0)
	p.landed.connect(_on_landed, CONNECT_ONE_SHOT)
	var vx_after := 0.0
	for i in 120:
		await physics_frame
		if _landed[0] > 0.0:
			vx_after = absf(p.velocity.x)
			break
	check("Harte Landung erkannt", _landed[0] >= 700.0, str(_landed[0]))
	await process_frame
	check("Landung staucht", _squash[0].x > 1.05 and _squash[0].y < 0.95, str(_squash[0]))
	check("Landung nur halb so stark wie frueher", _squash[0].x <= 1.15 and _squash[0].y >= 0.85, str(_squash[0]))
	check("Boden bebt (Kamera wackelt)", _shook[0])
	check("Harte Landung bremst", vx_after < 250.0, str(vx_after))
	check("Staub erscheint", level.get_children().any(func(c): return c is DustPuff))
	await frames(60)
	check("Wackeln klingt ab", not cam.is_shaking() and cam.offset == Vector2.ZERO, str(cam.offset))
	# Laufen: Kamera ohne Vorausblick, Schritt-Sound genau beim Aufsetzen
	cam.limit_left = -100000; cam.limit_right = 100000
	p.stepped.connect(_on_stepped)
	Input.action_press("move_right")
	await frames(90)
	var ahead := cam.global_position.x - p.global_position.x
	Input.action_release("move_right")
	check("Kamera ohne Vorausblick", absf(ahead) < 1.0, str(ahead))
	check("Schritte beim Laufen", _step_frames.size() >= 3, str(_step_frames))
	check("Schritt nur auf Bild 3 und 7 (Aseprite 8 und 12)", _step_frames.all(func(f): return f == 3 or f == 7), str(_step_frames))
	# Einsammeln: Hitstop endet wieder
	call_group("game_feel", "on_pickup")
	await create_timer(0.3, true, false, true).timeout
	check("Hitstop endet", is_equal_approx(Engine.time_scale, 1.0), str(Engine.time_scale))
	# Zeitstufe: kein Zoom; Blase nur bei langsam/schnell sichtbar
	var bubble = p.get_node("TimeBubble")
	bubble.stage = 0
	await process_frame
	await process_frame
	check("Kein Zoom-Impuls", cam.zoom == Vector2.ONE, str(cam.zoom))
	check("Blase bei langsam sichtbar", bubble.get_lens().visible)
	bubble.stage = 1
	await process_frame
	await process_frame
	check("Blase bei normal unsichtbar", not bubble.get_lens().visible)
	print("Fehler: %d" % fails)
	quit(1 if fails else 0)
