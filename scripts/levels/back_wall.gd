class_name BackWall
extends RefCounted
## Fuellt die Ebene "BackWall" eines Levels mit der Paneelwand (Doku 2.9):
## grosse Platten aus 4 x 4 Tiles (Ecken mit Nieten, Kanten, Mitte),
## vereinzelt Lueftungsgitter, ein Kabelkanal 9 Tiles ueber dem Boden und
## Warnstreifen direkt ueber dem Boden. Genutzt vom Baukasten ("Rueckwand
## fuellen") und von den Level-Generatoren.

## Groesse einer Platte in Tiles.
const PANEL := 4


## Varianten der Wand: Labor (dunkelviolett) und Teslakammer (blau, Spulen).
enum Variant { LAB, TESLA }


## Fuellt "wall" ueberall dort, wo "ground" innerhalb seiner bemalten Flaeche
## frei ist (also im Inneren des Raums). Vorhandene Wand-Tiles werden ersetzt.
static func fill(wall: TileMapLayer, ground: TileMapLayer, variant := Variant.LAB) -> int:
	wall.clear()
	var used := ground.get_used_rect()
	var count := 0
	for y in range(used.position.y, used.end.y):
		for x in range(used.position.x, used.end.x):
			var cell := Vector2i(x, y)
			if ground.get_cell_source_id(cell) != -1:
				continue
			wall.set_cell(cell, 0, _tile_for(cell, ground) + Vector2i(4 * variant, 0))
			count += 1
	return count


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
