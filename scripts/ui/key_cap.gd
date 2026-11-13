class_name KeyCap
extends RefCounted
## Zeichnet eine Tastenkappe (Taste mit Beschriftung) in Pixel-Optik, z. B.
## fuer Wandhinweise und die Interaktions-Anzeige (Doku 2.9). Breite passt
## sich der Beschriftung an ("E", "SPACE", "SHIFT"). Nur Palettenfarben.

## Hoehe der Kappe (Pixel) und Innenabstand links/rechts.
const HEIGHT := 16.0
const PADDING := 4.0
const FONT_SIZE := 10


## Breite einer Kappe mit dieser Beschriftung.
static func get_width(label: String) -> float:
	var font := ThemeDB.fallback_font
	return maxf(HEIGHT, ceilf(font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x) + PADDING * 2.0)


## Zeichnet die Kappe; "top_left" ist die linke obere Ecke. Gibt die Breite
## zurueck. "face" ist die Tastenflaeche, "edge" Umriss und Schrift.
static func draw(item: CanvasItem, top_left: Vector2, label: String, face: Color, edge: Color, shadow: Color) -> float:
	var width := get_width(label)
	var rect := Rect2(top_left.floor(), Vector2(width, HEIGHT))
	# Umriss, darunter eine dunkle Kante (Tiefe der Taste)
	item.draw_rect(Rect2(rect.position + Vector2(0, 2), rect.size), edge)
	item.draw_rect(rect, edge)
	item.draw_rect(rect.grow(-1), face)
	item.draw_rect(Rect2(rect.position.x + 1, rect.end.y - 2, rect.size.x - 2, 1), shadow)
	var font := ThemeDB.fallback_font
	var text_width := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x
	var baseline := Vector2(rect.position.x + floorf((width - text_width) * 0.5), rect.position.y + 11.0)
	item.draw_string(font, baseline, label, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, edge)
	return width
