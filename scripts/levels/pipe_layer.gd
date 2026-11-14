@tool
extends TileMapLayer
## Rohr-Ebene mit automatischem Verbinden (Doku 2.9, Rohre): Egal welches
## Rohr-Tile gemalt wird (auch im normalen Tile-Modus), jede Zelle bekommt
## sofort die passende Form aus ihren Nachbarn: Ende, Gerade, Ecke,
## T-Stueck oder Kreuzung. Die Variante (vorn mit Kollision, hinten Deko)
## legt die Ebene fest. Laeuft im Editor und im Spiel.
## Atlas-Aufbau (tileset_pipes.png): Kachel = Anschluesse N=1, O=2, S=4,
## W=8 bei (Maske % 4, Maske / 4); Spalten 4-7 = hintere Variante.

enum Variant { FRONT, BACK }

## Welche Rohr-Variante diese Ebene malt.
@export var variant := Variant.FRONT:
	set(value):
		variant = value
		_queue_fix()

const DIRS := [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
const BITS := [1, 2, 4, 8]

var _fixing := false
var _queued := false


func _ready() -> void:
	_queue_fix()


## Wird von der Engine gerufen, wenn sich Zellen aendern (Malen, Loeschen).
func _update_cells(_coords: Array[Vector2i], _forced_cleanup: bool) -> void:
	if not _fixing:
		_queue_fix()


func _queue_fix() -> void:
	if _queued or not is_inside_tree():
		return
	_queued = true
	_fix_all.call_deferred()


## Setzt fuer alle Rohr-Zellen die passende Form.
func _fix_all() -> void:
	_queued = false
	if _fixing:
		return
	_fixing = true
	for cell in get_used_cells():
		var mask := 0
		for i in 4:
			if get_cell_source_id(cell + DIRS[i]) != -1:
				mask |= BITS[i]
		var want := Vector2i(variant * 4 + mask % 4, mask / 4)
		if get_cell_atlas_coords(cell) != want or get_cell_source_id(cell) != 0:
			set_cell(cell, 0, want)
	_fixing = false
