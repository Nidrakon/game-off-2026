extends Control
## Ende und Abspann (Doku 3.5, Schritt 23), erscheint nach dem letzten Level.
## 1. Comic ohne Text: Der Professor nimmt oben die Pizza entgegen, haelt die
##    Keycard an den Fahrstuhl - gruen, sie war nie kaputt (Pointe).
##    Weiter mit Klick/Taste oder automatisch nach AUTO_ADVANCE Sekunden.
## 2. Fahrstuhlfahrt nach unten: links isst der Professor seine Pizza, rechts
##    laufen die Credits (dialogues/credits.json). Danach "THE END" und die
##    Zahl der verbrauchten Klone; eine Taste fuehrt zum Titelbildschirm.
## Esc springt direkt ans Ende. Bilder in graphics/ending/.

const FRAME_TIME := 0.28
const INPUT_DELAY := 0.4
## Comic-Schritt wechselt von selbst nach dieser Zeit (Sekunden).
const AUTO_ADVANCE := 4.0
## Tempo der Credits (Pixel pro Sekunde).
const CREDITS_SPEED := 34.0
const SCALE := 2.0
const SLOT_LEFT := Vector2(30, 60)
const SLOT_RIGHT := Vector2(490, 60)
const META_FILE := "res://graphics/ending/ending_panels.json"
const STEPS := [["e1"], ["e2_left"], ["e2_left", "e2_right"], ["e3"]]
const COLOR_BG := Color("2e222f")
const COLOR_TEXT := Color("c7dcd0")
const COLOR_TITLE := Color("f9c22b")
const COLOR_HINT := Color("9babb2")

enum Phase { COMIC, CREDITS, END }

var phase := Phase.COMIC
var _step := -1
var _panels := {}
var _meta := {}
var _wait := 0.0
var _anim := 0.0
var _step_time := 0.0
var _credits: VBoxContainer
var _end_box: VBoxContainer


func _ready() -> void:
	get_tree().paused = false
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(META_FILE))
	_meta = data if data is Dictionary else {}
	var bg := ColorRect.new()
	bg.color = COLOR_BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	SaveGame.set_flag("story_finished")
	SaveGame.save_game()
	next_step()


## Aktueller Comic-Schritt (fuer Tests).
func get_step() -> int:
	return _step


func next_step() -> void:
	_step += 1
	_wait = INPUT_DELAY
	_step_time = 0.0
	if _step >= STEPS.size():
		return
	var names: Array = STEPS[_step]
	for name in _panels.keys():
		if not names.has(name):
			_panels[name].queue_free()
			_panels.erase(name)
	for name in names:
		if not _panels.has(name):
			_panels[name] = _make_panel(name)
	if names.has("e3"):
		_start_credits()


## Direkt ans Ende (THE END), z. B. mit Esc.
func skip_to_end() -> void:
	while _step < STEPS.size() - 1:
		next_step()
	if phase == Phase.CREDITS or phase == Phase.COMIC:
		_show_end()


## Zum Titelbildschirm.
func go_to_title() -> void:
	set_process_unhandled_input(false)
	LevelFlow.go_to(LevelFlow.TITLE_SCENE)


func _make_panel(name: String) -> TextureRect:
	var info: Dictionary = _meta.get(name, {"w": 220, "h": 180, "frames": 1})
	var atlas := AtlasTexture.new()
	atlas.atlas = load("res://graphics/ending/ending_%s.png" % name)
	atlas.region = Rect2(0, 0, info.w, info.h)
	var rect := TextureRect.new()
	rect.texture = atlas
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.size = Vector2(info.w, info.h) * SCALE
	rect.position = SLOT_RIGHT if name.ends_with("right") else SLOT_LEFT
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_meta("frames", int(info.frames))
	rect.set_meta("w", float(info.w))
	rect.pivot_offset = rect.size * 0.5
	rect.scale = Vector2(0.94, 0.94)
	create_tween().tween_property(rect, "scale", Vector2.ONE, 0.12)
	add_child(rect)
	return rect


func _start_credits() -> void:
	phase = Phase.CREDITS
	_credits = VBoxContainer.new()
	_credits.position = Vector2(500, 560)
	_credits.custom_minimum_size = Vector2(430, 0)
	_credits.add_theme_constant_override("separation", 4)
	add_child(_credits)
	var first := true
	for line in GameTexts.get_list("credits", "credits_lines"):
		var label := Label.new()
		label.text = str(line)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_color_override("font_color", COLOR_TITLE if first else COLOR_TEXT)
		label.add_theme_font_size_override("font_size", 32 if first else 18)
		_credits.add_child(label)
		first = false


func _show_end() -> void:
	phase = Phase.END
	_wait = INPUT_DELAY
	if _credits:
		_credits.visible = false
	_end_box = VBoxContainer.new()
	_end_box.position = Vector2(500, 170)
	_end_box.custom_minimum_size = Vector2(430, 0)
	_end_box.add_theme_constant_override("separation", 14)
	add_child(_end_box)
	var texts := [
		[GameTexts.get_text("credits", "credits_end"), COLOR_TITLE, 40],
		[GameTexts.get_text("credits", "credits_clones").replace("{n}", str(SaveGame.clone_number)), COLOR_TEXT, 20],
		[GameTexts.get_text("credits", "credits_continue"), COLOR_HINT, 16],
	]
	for t in texts:
		var label := Label.new()
		label.text = t[0]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_color_override("font_color", t[1])
		label.add_theme_font_size_override("font_size", t[2])
		_end_box.add_child(label)


func _process(delta: float) -> void:
	_wait -= delta
	_anim += delta
	_step_time += delta
	var frame := int(_anim / FRAME_TIME)
	for rect in _panels.values():
		var frames: int = rect.get_meta("frames")
		(rect.texture as AtlasTexture).region.position.x = (frame % frames) * float(rect.get_meta("w"))
	if phase == Phase.COMIC and _step_time >= AUTO_ADVANCE:
		next_step()
	elif phase == Phase.CREDITS and _credits:
		_credits.position.y -= CREDITS_SPEED * delta
		if _credits.position.y + _credits.size.y < 120.0:
			_show_end()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if phase == Phase.END:
			go_to_title()
		else:
			skip_to_end()
		get_viewport().set_input_as_handled()
		return
	if _wait > 0.0:
		return
	var click := event as InputEventMouseButton
	var pressed := event.is_action_pressed("ui_accept") or event.is_action_pressed("jump") or (click and click.pressed and click.button_index == MOUSE_BUTTON_LEFT)
	if phase == Phase.END and (pressed or (event is InputEventKey and event.is_pressed() and not event.is_echo())):
		go_to_title()
		get_viewport().set_input_as_handled()
	elif phase == Phase.COMIC and pressed:
		next_step()
		get_viewport().set_input_as_handled()
