class_name BackWall
extends RefCounted
## Fuellt die Ebene "BackWall" eines Levels mit der Paneelwand (Doku 2.9):
## grosse Platten aus 4 x 4 Tiles (Ecken mit Nieten, Kanten, Mitte),
## vereinzelt Lueftungsgitter, ein Kabelkanal 9 Tiles ueber dem Boden und
## Warnstreifen direkt ueber dem Boden. Genutzt vom Baukasten ("Rueckwand
## fuellen") und von den Level-Generatoren.

## Groesse einer Platte in Tiles.
const PANEL := 4
## So viele Tiles wird ueber die bemalte Flaeche hinaus gefuellt, damit beim
## Parallax-Verschieben keine Luecken entstehen (auch hinter dem Boden).
const MARGIN := 16
## Anteil fehlender Paneele (Oeffnungen, Prozent).
const HOLE_PERCENT := 14


## Varianten der Wand (je 4 Spalten in tileset_wall.png): Labor (violett),
## Elektro (blau, Spulen), Fabrik (olivbraun), Chemie (gruen), Magnet (rot),
## Quanten (lila). Gewaehlt ueber das Hintergrund-Thema des Levels.
enum Variant { LAB, ELECTRO, FACTORY, CHEMICAL, MAGNET, QUANTUM }


## Fuellt "wall" ueberall dort, wo "ground" innerhalb seiner bemalten Flaeche
## frei ist (also im Inneren des Raums). Vorhandene Wand-Tiles werden ersetzt.
static func fill(wall: TileMapLayer, ground: TileMapLayer, variant := Variant.LAB) -> int:
	wall.clear()
	var used := ground.get_used_rect().grow(MARGIN)
	var count := 0
	for y in range(used.position.y, used.end.y):
		for x in range(used.position.x, used.end.x):
			var cell := Vector2i(x, y)
			var tile := _tile_for(cell, ground)
			# Fehlende Paneele = Oeffnungen (dahinter die tiefe Ebene)
			if tile.x < 3 and is_hole(cell):
				continue
			wall.set_cell(cell, 0, tile + Vector2i(4 * variant, 0))
			count += 1
	return count


## Fehlt das Paneel an dieser Zelle (Oeffnung in der Wand)? Ganze Paneele
## (4 x 4) fallen weg, ausgewaehlt nach ihrer Lage (immer gleich).
static func is_hole(cell: Vector2i) -> bool:
	var panel := Vector2i(floori((cell.x - 1) / float(PANEL)), floori((cell.y - 1) / float(PANEL)))
	return posmod(panel.x * 92821 + panel.y * 68917, 100) < HOLE_PERCENT


## Faerbt eine vorhandene Rueckwand um, ohne ihr Muster zu aendern.
static func recolor(wall: TileMapLayer, variant: int) -> void:
	for cell in wall.get_used_cells():
		var coords := wall.get_cell_atlas_coords(cell)
		var want := Vector2i(coords.x % 4 + 4 * variant, coords.y)
		if want != coords:
			wall.set_cell(cell, 0, want)


static func _tile_for(cell: Vector2i, ground: TileMapLayer) -> Vector2i:
	# Direkt ueber festem Boden: Warnstreifen
	if ground.get_cell_source_id(cell + Vector2i.DOWN) != -1:
		return Vector2i(3, 1)
	# Kabelkanal 9 Tiles ueber dem naechsten Boden darunter
	var depth := 0
	while depth < 12 and ground.get_cell_source_id(cell + Vector2i(0, depth + 1)) == -1:
		depth += 1
	if depth == 8:
		return Vector2i(3, 2)
	var cx := 0 if posmod(cell.x - 1, PANEL) == 0 else (2 if posmod(cell.x - 1, PANEL) == PANEL - 1 else 1)
	var cy := 0 if posmod(cell.y - 1, PANEL) == 0 else (2 if posmod(cell.y - 1, PANEL) == PANEL - 1 else 1)
	if cx == 1 and cy == 1 and posmod(cell.x * 7 + cell.y * 13, 29) == 0:
		return Vector2i(3, 0)
	return Vector2i(cx, cy)
