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

## Upgrades, die man zu Beginn dieses Levels sicher hat (aus frueheren
## Leveln). Werden beim Start still eingebaut, damit das Level auch direkt
## aus dem Editor (F6) oder aus einem alten Spielstand passt.
@export var required_upgrades: Array[TimeShifterUpgrades.Upgrade] = []

## Kameragrenzen automatisch aus den Tiles von "Ground" setzen.
@export var auto_camera_limits := true
## Spielraum der Kamera (Pixel, waagrecht; senkrecht im Bildverhaeltnis):
## Die Kamera zoomt so weit heraus, dass das ganze Level immer zu sehen ist
## und sie trotzdem um diesen Betrag dem Professor folgen kann. Den Rand
## rundherum fuellt massive Wand; so wirkt auch der Parallax-Effekt
## (seit v0.79). 0 = aus (Zoom der Kamera bleibt, z. B. Werkstatt).
@export_range(0.0, 200.0, 1.0) var camera_follow_room := 80.0

## Musik (Song-ID, Doku 1.7); Auto = passend zum Hintergrund-Thema
## (Werkstatt 3, Fabrik 4, Chemie 7 Lo-Fi, Elektro/Quanten 5, Magnet 8 Lo-Fi).
@export_enum("Auto:0", "1 Time Shifter:1", "2 Pizza on the Line:2", "3 Tinkering:3", "4 Clockwork Lab:4", "5 Quantum Climb:5", "6 Going Down:6", "7 Coffee Break Circuits (Lo-Fi):7", "8 Late Night Lab (Lo-Fi):8") var music := 0

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
# Bemalte Flaeche des Bodens (Zellen) vor dem Auffuellen des Kamera-Rands.
var _ground_rect_before_fill := Rect2i()

## Umgebungsgeraeusch je Hintergrund-Thema (data/sfx.json).
## Gruppe aller laufenden Level (z. B. fuer das Spielmenue).
const GROUP := "level"
const AUTO_MUSIC := {
	BackgroundTheme.Kind.WORKSHOP: 3, BackgroundTheme.Kind.FACTORY: 4, BackgroundTheme.Kind.CHEMICAL: 7,
	BackgroundTheme.Kind.ELECTRO: 5, BackgroundTheme.Kind.MAGNET: 8, BackgroundTheme.Kind.QUANTUM: 5,
}
const AMBIENT_IDS := {
	BackgroundTheme.Kind.WORKSHOP: "ambient_workshop", BackgroundTheme.Kind.FACTORY: "ambient_factory",
	BackgroundTheme.Kind.CHEMICAL: "ambient_chemical", BackgroundTheme.Kind.ELECTRO: "ambient_electro",
	BackgroundTheme.Kind.MAGNET: "ambient_magnet", BackgroundTheme.Kind.QUANTUM: "ambient_quantum",
}


func _ready() -> void:
	apply_background()
	if Engine.is_editor_hint():
		return
	add_to_group(GROUP)
	for upgrade in required_upgrades:
		Upgrades.unlock(upgrade)
	if auto_camera_limits:
		_fit_camera_to_ground()
	SaveGame.on_level_started(scene_file_path)
	Sound.play_ambient(AMBIENT_IDS[background_theme])
	Sound.play_music(get_music_id())


## Song-ID dieses Levels (Auto aufgeloest).
func get_music_id() -> int:
	return music if music > 0 else AUTO_MUSIC[background_theme]


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
	var ground := get_node_or_null("Ground") as TileMapLayer
	var rect := _ground_rect(ground)
	if camera == null or rect.size == Vector2.ZERO:
		return
	if camera_follow_room > 0.0:
		_fit_with_follow_room(camera, ground, rect)
		return
	# Ist der Raum kleiner als der sichtbare Ausschnitt (z. B. die Werkstatt),
	# die Grenzen um ihn herum erweitern, damit er mittig im Bild steht.
	var view := get_viewport_rect().size / camera.zoom
	if rect.size.x < view.x:
		rect = rect.grow_individual((view.x - rect.size.x) * 0.5, 0, (view.x - rect.size.x) * 0.5, 0)
	if rect.size.y < view.y:
		rect = rect.grow_individual(0, (view.y - rect.size.y) * 0.5, 0, (view.y - rect.size.y) * 0.5)
	camera.limit_left = roundi(rect.position.x)
	camera.limit_top = roundi(rect.position.y)
	camera.limit_right = roundi(rect.end.x)
	camera.limit_bottom = roundi(rect.end.y)


## Zoom und Grenzen mit Spielraum: Sichtbar ist immer das ganze Level plus
## ein Rand; die Kamera folgt dem Professor um die Breite dieses Rands.
## Die Grenzen liegen so, dass an jeder Kameraposition das ganze Level im
## Bild ist. Der Rand wird mit massiver Wand gefuellt.
func _fit_with_follow_room(camera: Camera2D, ground: TileMapLayer, rect: Rect2) -> void:
	var screen := get_viewport_rect().size
	var want := rect.size + Vector2(camera_follow_room, camera_follow_room * screen.y / screen.x)
	var zoom := minf(screen.x / want.x, screen.y / want.y)
	camera.zoom = Vector2(zoom, zoom)
	var view := screen / zoom
	var room := (view - rect.size).max(Vector2.ZERO)
	var limits := rect.grow_individual(room.x, room.y, room.x, room.y)
	camera.limit_left = roundi(limits.position.x)
	camera.limit_top = roundi(limits.position.y)
	camera.limit_right = roundi(limits.end.x)
	camera.limit_bottom = roundi(limits.end.y)
	_fill_outside(ground, limits)
	_hide_wall_seams(get_node_or_null("BackWall") as TileMapLayer, ground)


## Fuellt alles ausserhalb der bemalten Flaeche bis zur Kameragrenze mit
## dem Tile aus der linken oberen Ecke (massive Wand).
func _fill_outside(ground: TileMapLayer, area: Rect2) -> void:
	var used := ground.get_used_rect()
	_ground_rect_before_fill = used
	var source := ground.get_cell_source_id(used.position)
	if source == -1:
		return
	var atlas := ground.get_cell_atlas_coords(used.position)
	var tile := Vector2(ground.tile_set.tile_size)
	var from := Vector2i((ground.to_local(area.position) / tile).floor()) - Vector2i.ONE
	var to := Vector2i((ground.to_local(area.end) / tile).ceil()) + Vector2i.ONE
	for y in range(from.y, to.y + 1):
		for x in range(from.x, to.x + 1):
			var cell := Vector2i(x, y)
			if not used.has_point(cell):
				ground.set_cell(cell, source, atlas)


## Unter den Aussenwaenden hat die Rueckwand eine Spalte mit Warnstreifen.
## Bewegt sich die Kamera, schiebt der Parallax sie ein paar Pixel ins Bild;
## deshalb dort das normale Wandmuster einsetzen (4 Spalten bzw. Zeilen
## weiter innen, das Muster wiederholt sich alle 4 Tiles).
func _hide_wall_seams(wall: TileMapLayer, ground: TileMapLayer) -> void:
	if wall == null:
		return
	# Bemalte Flaeche vor dem Auffuellen: Aussenwaende = erste/letzte Spalte
	# und Decke = erste Zeile innerhalb der Kameragrenzen-Flaeche des Levels.
	var rect := _ground_rect_before_fill
	if rect.size == Vector2i.ZERO:
		return
	var left := rect.position.x
	var right := rect.end.x - 1
	var top := rect.position.y
	for y in range(top, rect.end.y):
		_copy_wall_cell(wall, Vector2i(left, y), Vector2i(left + 4, y))
		_copy_wall_cell(wall, Vector2i(right, y), Vector2i(right - 4, y))
	for x in range(left, right + 1):
		_copy_wall_cell(wall, Vector2i(x, top), Vector2i(x, top + 4))


func _copy_wall_cell(wall: TileMapLayer, to: Vector2i, from: Vector2i) -> void:
	# Loch im Muster (dort sieht man die tiefe Ebene): Loch fortsetzen.
	if wall.get_cell_source_id(from) == -1:
		wall.erase_cell(to)
		return
	wall.set_cell(to, wall.get_cell_source_id(from), wall.get_cell_atlas_coords(from), wall.get_cell_alternative_tile(from))
