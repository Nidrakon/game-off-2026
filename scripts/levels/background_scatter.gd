@tool
class_name BackgroundScatter
extends Node2D
## Hintergrund-Silhouetten (Doku 2.9): dezente, einfarbige Formen, zufaellig
## ueber den Raum verteilt, damit die Szene lebendiger wirkt. Liegt vor der
## Rueckwand, aber hinter Deko und Spielobjekten. Thema, Startwert und Dichte
## kommen von der Level-Wurzel (level.gd); gleicher Startwert = gleiche
## Anordnung. Im Editor sofort sichtbar (@tool).
## Die Formen sind weiss gezeichnet und werden mit einer Palettenfarbe
## eingefaerbt (weiss x Farbe = genau diese Farbe).

const TEXTURE := preload("res://graphics/sprites/background/bg_silhouettes.png")
## Rastergroesse fuer die Verteilung (Pixel); je Feld hoechstens eine Form.
const GRID := Vector2(128, 112)

var theme := BackgroundTheme.Kind.WORKSHOP
var seed_value := 1
var density := 0.45
## Bereich, der gefuellt wird (Weltkoordinaten); leer = nichts.
var area := Rect2()

var _items: Array[Dictionary] = []


func _ready() -> void:
	z_index = -15


## Neu verteilen (nach Aenderung von Thema, Startwert, Dichte oder Bereich).
func rebuild() -> void:
	_items.clear()
	if area.size.x <= 0.0 or area.size.y <= 0.0:
		queue_redraw()
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var tones := BackgroundTheme.tones(theme)
	var row := BackgroundTheme.silhouette_row(theme)
	var cols := int(ceilf(area.size.x / GRID.x))
	var rows := int(ceilf(area.size.y / GRID.y))
	for gy in rows:
		for gx in cols:
			if rng.randf() > density:
				continue
			var big := rng.randf() < 0.12
			var scale := 2.0 if big else 1.0
			var size := Vector2(BackgroundTheme.CELL, BackgroundTheme.CELL) * scale
			var cell_pos := area.position + Vector2(gx, gy) * GRID
			var pos := (cell_pos + Vector2(rng.randf_range(0.0, GRID.x), rng.randf_range(0.0, GRID.y)) - size * 0.5).round()
			_items.append({
				"rect": Rect2(pos, size),
				"src": Rect2(rng.randi_range(0, BackgroundTheme.SHAPES_PER_THEME - 1) * BackgroundTheme.CELL, row * BackgroundTheme.CELL, BackgroundTheme.CELL, BackgroundTheme.CELL),
				"flip": rng.randf() < 0.5,
				"tone": tones[rng.randi_range(0, tones.size() - 1)],
				"big": big,
			})
	# Grosse Formen zuerst, damit kleine darueber liegen
	_items.sort_custom(func(a, b): return a.big and not b.big)
	queue_redraw()


## Anzahl der verteilten Formen (fuer Tests).
func get_count() -> int:
	return _items.size()


func _draw() -> void:
	for item in _items:
		var rect: Rect2 = item.rect
		if item.flip:
			rect = Rect2(rect.position.x + rect.size.x, rect.position.y, -rect.size.x, rect.size.y)
		draw_texture_rect_region(TEXTURE, rect, item.src, item.tone)
