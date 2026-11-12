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

