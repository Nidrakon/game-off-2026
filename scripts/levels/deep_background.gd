@tool
class_name DeepBackground
extends Node2D
## Tiefste Hintergrund-Ebene (Doku 2.9, Parallax): Kabelstraenge, Gitter,
## Leitungen und Verteilerkaesten hinter der Rueckwand. Man sieht sie durch
## die Oeffnungen der Rueckwand (fehlende Paneele). Wird aus Kacheln von
## graphics/tilesets/deep_background.png gezeichnet, das Muster ergibt sich
## aus der Position (kein Malen noetig). Die LEDs der Verteilerkaesten
## blinken. Bewegt sich per Parallax langsamer als der Vordergrund.

const TEXTURE := preload("res://graphics/tilesets/deep_background.png")
const TILE := 16
## Blinktakt der LEDs (Sekunden).
const BLINK_TIME := 0.7
const COLOR_LED_OFF := Color("2e222f")

## Bereich (Weltkoordinaten), wird von der Level-Wurzel gesetzt.
var area := Rect2():
	set(value):
		area = value
		queue_redraw()

var _blink := 0.0
var _led_on := true


func _ready() -> void:
	z_index = -30


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_blink += delta
	if _blink >= BLINK_TIME:
		_blink = 0.0
		_led_on = not _led_on
		queue_redraw()


## Kachel an der Zellposition (deterministisch aus der Position).
static func tile_at(cell: Vector2i) -> int:
	var h := posmod(cell.x * 73856093 ^ cell.y * 19349663, 1000)
	var hcable := posmod(cell.y, 7) == 2 or posmod(cell.y, 11) == 6
	var vcable := posmod(cell.x, 9) == 4 or posmod(cell.x, 23) == 15
	if hcable and vcable:
		return 3
	if hcable:
		if h < 60:
			return 6
		if h < 100:
			return 7
		return 1
	if vcable:
		return 2
	if posmod(cell.y, 13) == 9 and h < 400:
		return 5
	if posmod(cell.x / 3 + cell.y / 3, 7) == 0:
		return 4
	return 0


func _draw() -> void:
	if area.size.x <= 0.0:
		return
	var start := Vector2i(floori(area.position.x / TILE), floori(area.position.y / TILE))
	var end := Vector2i(ceili(area.end.x / TILE), ceili(area.end.y / TILE))
	for y in range(start.y, end.y):
		for x in range(start.x, end.x):
			var t := tile_at(Vector2i(x, y))
			var pos := Vector2(x * TILE, y * TILE)
			draw_texture_rect_region(TEXTURE, Rect2(pos, Vector2(TILE, TILE)), Rect2(t * TILE, 0, TILE, TILE))
			if (t == 6 or t == 7) and not _led_on and not Engine.is_editor_hint():
				draw_rect(Rect2(pos + Vector2(5, 5), Vector2(2, 2)), COLOR_LED_OFF)
