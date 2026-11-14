@tool
class_name Level
extends Node2D
## Grundlage jedes Levels (Doku 2.9, Level-Vorlage): Wurzel der Szene
## scenes/levels/level_base.tscn, von der alle Level erben.
## - Stellt beim Start die Kameragrenzen automatisch auf die bemalte Flaeche
##   des Bodens (Node "Ground").
## - Meldet den Start dem Spielstand (automatisches Speichern, Doku 2.7).
## - Hintergrund-Thema je Level (Gruppe "Hintergrund" im Inspector): faerbt
##   die Rueckwand passend ein und verteilt dezente Silhouetten (Node
##   "BackgroundScatter"). Im Editor sofort sichtbar (@tool).
## - Parallax (Node "ParallaxDriver"): tiefe Ebene, Rueckwand mit
##   Silhouetten und hintere Rohre laufen langsamer als der Vordergrund.

## Kameragrenzen automatisch aus den Tiles von "Ground" setzen.
@export var auto_camera_limits := true

@export_group("Hintergrund")
## Thema: Farbe der Rueckwand und Art der Silhouetten.
@export var background_theme := BackgroundTheme.Kind.WORKSHOP:
	set(value):
		background_theme = value
		_queue_background()
## Startwert der Zufallsverteilung (anderer Wert = andere Anordnung).
@export var background_seed := 1:
	set(value):
		background_seed = value
		_queue_background()
## Wie dicht die Silhouetten stehen (0 = keine, 1 = in jedem Rasterfeld eine).
@export_range(0.0, 1.0, 0.05) var background_density := 0.45:
	set(value):
		background_density = value
		_queue_background()
## Rueckwand passend zum Thema einfaerben (Muster bleibt erhalten).
@export var tint_back_wall := true:
	set(value):
		tint_back_wall = value
		_queue_background()

var _background_queued := false


func _ready() -> void:
	apply_background()
	if Engine.is_editor_hint():
		return
	if auto_camera_limits:
		_fit_camera_to_ground()
	SaveGame.on_level_started(scene_file_path)


## Thema anwenden: Rueckwand einfaerben, Silhouetten neu verteilen.
func apply_background() -> void:
	_background_queued = false
	if not is_inside_tree():
		return
	var ground := get_node_or_null("Ground") as TileMapLayer
	var wall := get_node_or_null("BackWall") as TileMapLayer
	if tint_back_wall and wall != null:
		BackWall.recolor(wall, BackgroundTheme.wall_variant(background_theme))
	var rect := _ground_rect(ground)
	var driver := get_node_or_null("ParallaxDriver") as ParallaxDriver
	if driver != null:
		driver.anchor = rect.get_center()
	var deep := get_node_or_null("DeepBackground") as DeepBackground
	if deep != null and rect.size != Vector2.ZERO:
		# Rand passend zur groessten Verschiebung der tiefen Ebene
		var factor := driver.deep_factor if driver else 0.55
		deep.area = rect.grow(maxf(rect.size.x, rect.size.y) * 0.5 * (1.0 - factor) + 64.0)
	var scatter := get_node_or_null("BackgroundScatter") as BackgroundScatter
	if scatter != null:
		scatter.theme = background_theme
		scatter.seed_value = background_seed
		scatter.density = background_density
		scatter.area = _ground_rect(ground)
		scatter.rebuild()


func _queue_background() -> void:
	if _background_queued or not is_inside_tree():
		return
	_background_queued = true
	apply_background.call_deferred()


## Bemalte Flaeche des Bodens in Weltkoordinaten (leer, wenn kein Boden).
func _ground_rect(ground: TileMapLayer) -> Rect2:
	if ground == null or ground.tile_set == null:
		return Rect2()
	var used := ground.get_used_rect()
	if used.size == Vector2i.ZERO:
		return Rect2()
	var tile := Vector2(ground.tile_set.tile_size)
	var top_left := ground.to_global(Vector2(used.position) * tile)
	var bottom_right := ground.to_global(Vector2(used.end) * tile)
	return Rect2(top_left, bottom_right - top_left)


func _fit_camera_to_ground() -> void:
	var camera := get_node_or_null("Camera") as Camera2D
	var rect := _ground_rect(get_node_or_null("Ground") as TileMapLayer)
	if camera == null or rect.size == Vector2.ZERO:
		return
	camera.limit_left = roundi(rect.position.x)
	camera.limit_top = roundi(rect.position.y)
	camera.limit_right = roundi(rect.end.x)
	camera.limit_bottom = roundi(rect.end.y)
