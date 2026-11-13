extends Control
## Intro-Comic (Doku 3.5, Schritt 22): vier Szenen ohne Text, Panels mit
## kleinen Animationsschleifen. Geteilte Szenen bauen sich Klick fuer Klick
## auf (erst ein Panel, dann das zweite; das erste bleibt stehen).
## Weiter: Leertaste, Enter, Sprung oder Mausklick. Esc: ganzes Intro
## ueberspringen. Danach startet das Spiel im ersten Level.
## Panels aus graphics/intro/ (halbe Groesse gezeichnet, doppelt angezeigt).

## Dauer eines Animationsbilds (Sekunden).
const FRAME_TIME := 0.28
## So lange nach jedem Schritt wird keine Eingabe angenommen (Sekunden).
const INPUT_DELAY := 0.25
## Darstellung: Faktor, Lage der Felder (links, rechts, breit).
const SCALE := 2.0
const SLOT_LEFT := Vector2(30, 60)
const SLOT_RIGHT := Vector2(490, 60)
const SLOT_WIDE := Vector2(30, 60)
const META_FILE := "res://graphics/intro/intro_panels.json"
## Ablauf: je Schritt die sichtbaren Panels. Szene 4: erst klingelt der Bote
## (rechts), dann erschrickt der Professor (links).
const STEPS := [
	["s1_left"], ["s1_left", "s1_right"],
	["s2"],
	["s3_left"], ["s3_left", "s3_right"],
	["s4_right"], ["s4_right", "s4_left"],
]
const COLOR_BG := Color("2e222f")
const COLOR_FACE := Color("c7dcd0")
const COLOR_EDGE := Color("2e222f")
const COLOR_SHADOW := Color("7f708a")

var _step := -1
var _panels := {}
var _meta := {}
var _wait := 0.0
var _anim := 0.0
var _hint: Control


func _ready() -> void:
	get_tree().paused = false
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(META_FILE))
	_meta = data if data is Dictionary else {}
	var bg := ColorRect.new()
	bg.color = COLOR_BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	_hint = Control.new()
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hint.draw.connect(_draw_hint)
	_hint.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_hint)
	next_step()


## Aktueller Schritt (0 bis Anzahl - 1), fuer Tests.
func get_step() -> int:
	return _step


## Weiter zum naechsten Schritt bzw. zum Spiel.
func next_step() -> void:
	_step += 1
	_wait = INPUT_DELAY
	if _step >= STEPS.size():
		finish()
		return
	var visible_names: Array = STEPS[_step]
	for name in _panels.keys():
		if not visible_names.has(name):
			_panels[name].queue_free()
			_panels.erase(name)
	for name in visible_names:
		if not _panels.has(name):
			_panels[name] = _make_panel(name)


## Intro beenden (oder ueberspringen) und das Spiel starten.
func finish() -> void:
	set_process_unhandled_input(false)
	LevelFlow.start_game()


func _make_panel(name: String) -> TextureRect:
	var info: Dictionary = _meta.get(name, {"w": 220, "h": 180, "frames": 1})
	var atlas := AtlasTexture.new()
	atlas.atlas = load("res://graphics/intro/intro_%s.png" % name)
	atlas.region = Rect2(0, 0, info.w, info.h)
	var rect := TextureRect.new()
	rect.texture = atlas
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.size = Vector2(info.w, info.h) * SCALE
	rect.position = SLOT_WIDE if name == "s2" else (SLOT_LEFT if name.ends_with("left") else SLOT_RIGHT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_meta("frames", int(info.frames))
	rect.set_meta("w", float(info.w))
	# Kurzes Aufploppen
	rect.pivot_offset = rect.size * 0.5
	rect.scale = Vector2(0.94, 0.94)
	create_tween().tween_property(rect, "scale", Vector2.ONE, 0.12)
	add_child(rect)
	move_child(_hint, -1)
	return rect


func _process(delta: float) -> void:
	_wait -= delta
	_anim += delta
	var frame := int(_anim / FRAME_TIME)
	for rect in _panels.values():
		var frames: int = rect.get_meta("frames")
		var w: float = rect.get_meta("w")
		var atlas := rect.texture as AtlasTexture
		atlas.region.position.x = (frame % frames) * w


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		finish()
		get_viewport().set_input_as_handled()
		return
	if _wait > 0.0:
		return
	var click := event as InputEventMouseButton
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("jump") or (click and click.pressed and click.button_index == MOUSE_BUTTON_LEFT):
		next_step()
		get_viewport().set_input_as_handled()


## Hinweis unten rechts (ohne Text): Tastenkappen fuer weiter und ueberspringen.
func _draw_hint() -> void:
	var y := 470.0
	var x := 930.0
	for entry in [["ESC", 2], ["SPACE", 1]]:
		var width := KeyCap.get_width(entry[0])
		var arrows: int = entry[1]
		x -= arrows * 8.0 + 4.0
		for i in arrows:
			var ax := x + 4.0 + i * 8.0
			for r in 5:
				_hint.draw_rect(Rect2(ax, y + 3 + r, 4 - absi(2 - r) * 2 + 1, 1), COLOR_FACE)
		x -= width + 4.0
		KeyCap.draw(_hint, Vector2(x, y), entry[0], COLOR_FACE, COLOR_EDGE, COLOR_SHADOW)
		x -= 20.0
