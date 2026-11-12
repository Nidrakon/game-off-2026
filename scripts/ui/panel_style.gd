class_name PanelStyle
extends RefCounted
## Gemeinsamer Look der Bedienelemente des Time Shifters (Gehaeuse,
## Anzeigefenster). Nur Farben der Palette (Doku 1.7).

const COLOR_OUTLINE := Color("2e222f")
const COLOR_BODY := Color("9babb2")
const COLOR_LIGHT := Color("c7dcd0")
const COLOR_SHADOW := Color("7f708a")
const COLOR_FACE := Color("3e3546")
const COLOR_ACCENT := Color("e83b3b")


## Gehaeuse: Umriss, Lichtkante oben/links, Schatten unten/rechts.
static func draw_housing(item: CanvasItem, rect: Rect2) -> void:
	item.draw_rect(rect, COLOR_OUTLINE)
	item.draw_rect(rect.grow(-2), COLOR_SHADOW)
	item.draw_rect(Rect2(rect.position + Vector2(2, 2), rect.size - Vector2(6, 6)), COLOR_LIGHT)
	item.draw_rect(Rect2(rect.position + Vector2(4, 4), rect.size - Vector2(8, 8)), COLOR_BODY)


## Dunkles Anzeigefenster mit Umriss.
static func draw_face(item: CanvasItem, rect: Rect2, fill := COLOR_FACE) -> void:
	item.draw_rect(rect, COLOR_OUTLINE)
	item.draw_rect(rect.grow(-1), fill)


## Abdeckplatte fuer einen noch nicht eingebauten Regler (Upgrade fehlt):
## glatte Platte mit vier Schrauben und einem leeren Einbauschlitz.
static func draw_cover(item: CanvasItem, rect: Rect2) -> void:
	var plate := rect.grow(-6)
	item.draw_rect(plate, COLOR_OUTLINE)
	item.draw_rect(plate.grow(-1), COLOR_SHADOW)
	item.draw_rect(Rect2(plate.position + Vector2(1, 1), Vector2(plate.size.x - 2, 1)), COLOR_BODY)
	for corner in [plate.position + Vector2(3, 3), Vector2(plate.end.x - 5, plate.position.y + 3), Vector2(plate.position.x + 3, plate.end.y - 5), plate.end - Vector2(5, 5)]:
		item.draw_rect(Rect2(corner, Vector2(2, 2)), COLOR_OUTLINE)
	var slot := Rect2((plate.get_center() - Vector2(plate.size.x * 0.25, 2)).floor(), Vector2(floorf(plate.size.x * 0.5), 4))
	item.draw_rect(slot, COLOR_OUTLINE)
	item.draw_rect(slot.grow(-1), COLOR_FACE)
