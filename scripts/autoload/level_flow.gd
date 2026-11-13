extends Node
## Levelfolge (Doku 2.9), globales System (Autoload "LevelFlow"). Kennt die
## Reihenfolge aus data/level_order.tres und wechselt zum naechsten Level,
## mit kurzem Abblenden (Rastermuster, dann ganz dunkel; nur Palettenfarben,
## keine Transparenz).
##
## Liegt das aktuelle Level nicht in der Reihenfolge (z. B. das Testlevel),
## fuehrt der Ausgang zum ersten Level der Reihenfolge.

## Wird gesendet, nachdem ein neues Level geladen wurde.
signal level_changed(path: String)

## Datei mit der Reihenfolge.
const ORDER_FILE := "res://data/level_order.tres"
## Titelbildschirm (Hauptmenue).
const TITLE_SCENE := "res://scenes/ui/title_screen.tscn"
## Intro-Comic nach New Game.
const INTRO_SCENE := "res://scenes/ui/intro.tscn"
## Ende und Abspann nach dem letzten Level (Schritt 23).
const END_SCENE := "res://scenes/ui/ending.tscn"
## Dauer je Abblend-Stufe (Sekunden).
const STEP_TIME := 0.12
const DITHER_TEXTURE := preload("res://graphics/ui/ui_dither_dark.png")
const COLOR_DARK := Color("2e222f")

var _order: LevelOrder
var _busy := false
var _layer: CanvasLayer
var _dither: TextureRect
var _solid: ColorRect


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_overlay()


## Alle Level in Spielreihenfolge (Szenen-Pfade).
func get_levels() -> Array[String]:
	if _order == null:
		_order = load(ORDER_FILE) as LevelOrder
	return _order.levels if _order else ([] as Array[String])


## Kennung eines Levels: Dateiname ohne Endung (z. B. "level_example_1").
func get_level_id(path: String) -> String:
	return path.get_file().get_basename()


## Position des Levels in der Reihenfolge (-1 = nicht enthalten).
func index_of(path: String) -> int:
	return get_levels().find(path)


## Position des laufenden Levels in der Reihenfolge (-1 = nicht enthalten).
func current_index() -> int:
	var scene := get_tree().current_scene
	return index_of(scene.scene_file_path) if scene else -1


## Wohin der Ausgang des laufenden Levels fuehrt.
func next_level_path() -> String:
	var levels := get_levels()
	var i := current_index()
	if i < 0:
		return levels[0] if not levels.is_empty() else END_SCENE
	return levels[i + 1] if i + 1 < levels.size() else END_SCENE


## Laeuft gerade ein Levelwechsel?
func is_changing() -> bool:
	return _busy


## Zum naechsten Level wechseln.
func go_to_next() -> void:
	go_to(next_level_path())


## Zum ersten Level der Reihenfolge (Spielbeginn).
func start_game() -> void:
	var levels := get_levels()
	go_to(levels[0] if not levels.is_empty() else END_SCENE)


## Mit Abblenden zu einer bestimmten Szene wechseln.
func go_to(path: String) -> void:
	if _busy:
		return
	_busy = true
	await _fade(true)
	get_tree().change_scene_to_file(path)
	# Warten, bis die neue Szene steht (Klonstation setzt den Professor).
	await get_tree().process_frame
	await get_tree().process_frame
	level_changed.emit(path)
	await _fade(false)
	_busy = false


## Abblenden (cover = true) bzw. wieder aufblenden.
func _fade(cover: bool) -> void:
	if _layer == null:
		_build_overlay()
	_layer.visible = true
	if cover:
		_dither.visible = true
		await get_tree().create_timer(STEP_TIME).timeout
		_solid.visible = true
		await get_tree().create_timer(STEP_TIME).timeout
	else:
		_solid.visible = false
		await get_tree().create_timer(STEP_TIME).timeout
		_dither.visible = false
		_layer.visible = false


func _build_overlay() -> void:
	if _layer != null:
		return
	_layer = CanvasLayer.new()
	_layer.layer = 90
	_layer.visible = false
	add_child(_layer)
	_dither = TextureRect.new()
	_dither.texture = DITHER_TEXTURE
	_dither.stretch_mode = TextureRect.STRETCH_TILE
	_dither.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dither.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dither.visible = false
	_layer.add_child(_dither)
	_solid = ColorRect.new()
	_solid.color = COLOR_DARK
	_solid.set_anchors_preset(Control.PRESET_FULL_RECT)
	_solid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_solid.visible = false
	_layer.add_child(_solid)
