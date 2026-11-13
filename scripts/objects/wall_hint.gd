@tool
extends Node2D
## Wandhinweis (Doku 2.9, Tutorial): auf die Hintergrundwand gemalte Tasten
## mit einem Wort darunter, z. B. die Tasten A und D mit "Move". Reine
## Dekoration, keine Kollision; liegt hinter dem Professor und den Objekten.
## Tasten und Text-ID im Inspector; das Wort kommt aus dialogues/hints.json.
## Im Editor sofort sichtbar (@tool). Der Node liegt in der Mitte oben.

## Farben der Wandfarbe (nur Palette).
enum Paint { DARK, LIGHT, YELLOW, RED, BLUE }

## Beschriftungen der Tasten, nebeneinander (z. B. "A", "D" oder "SPACE").
@export var keys: PackedStringArray = PackedStringArray(["A", "D"]):
	set(value):
		keys = value
		queue_redraw()
## Kennung des Worts in dialogues/hints.json (leer = kein Wort).
@export var text_id := "hint_move":
	set(value):
		text_id = value
		queue_redraw()
## Farbe der aufgemalten Schrift und Umrisse.
@export var paint := Paint.DARK:
	set(value):
		paint = value
		queue_redraw()
## Helles Schild hinter dem Hinweis, damit er auf vollem Hintergrund lesbar
## bleibt (z. B. vor der Paneelwand der Werkstatt).
@export var plate := true:
	set(value):
		plate = value
		queue_redraw()

const PAINT_COLORS := {
	Paint.DARK: Color("3e3546"),
	Paint.LIGHT: Color("c7dcd0"),
	Paint.YELLOW: Color("f9c22b"),
	Paint.RED: Color("ae2334"),
	Paint.BLUE: Color("4d65b4"),
}
## Abstand zwischen den Tasten und zwischen Tasten und Wort (Pixel).
const KEY_GAP := 4.0
const WORD_GAP := 6.0
const WORD_SIZE := 12
## Rand des Schilds um Tasten und Wort (Pixel) und seine Farben (Palette).
const PLATE_MARGIN := 5.0
const COLOR_PLATE := Color("c7dcd0")
const COLOR_PLATE_EDGE := Color("2e222f")
const COLOR_PLATE_SHADE := Color("9babb2")


func _ready() -> void:
	# Hinter allem im Level, aber vor dem Hintergrund (Wand).
	z_index = -7


## Das angezeigte Wort.
func get_word() -> String:
	return "" if text_id == "" else GameTexts.get_text("hints", text_id)


func _draw() -> void:
	var color: Color = PAINT_COLORS[paint]
	# Aufgemalte Tasten: nur Umriss und Schrift in Wandfarbe, innen die Wand.
	var widths: Array[float] = []
	var total := 0.0
	for key in keys:
		var w := KeyCap.get_width(key)
		widths.append(w)
		total += w
	total += KEY_GAP * maxf(keys.size() - 1, 0)
	var x := -floorf(total * 0.5)
	var font := ThemeDB.fallback_font
	if plate:
		var word_w := 0.0
		if get_word() != "":
			word_w = font.get_string_size(get_word(), HORIZONTAL_ALIGNMENT_LEFT, -1, WORD_SIZE).x
		var width := ceilf(maxf(total, word_w)) + PLATE_MARGIN * 2.0
		var height := KeyCap.HEIGHT + 1.0 + (WORD_GAP + 12.0 if get_word() != "" else 0.0) + PLATE_MARGIN * 2.0
		var r := Rect2(-floorf(width * 0.5), -PLATE_MARGIN, width, height)
		draw_rect(r, COLOR_PLATE_EDGE)
		draw_rect(r.grow(-1), COLOR_PLATE)
		draw_rect(Rect2(r.position.x + 1, r.end.y - 2, r.size.x - 2, 1), COLOR_PLATE_SHADE)
		draw_rect(Rect2(r.position.x + 2, r.position.y + 2, 1, 1), COLOR_PLATE_SHADE)
		draw_rect(Rect2(r.end.x - 3, r.position.y + 2, 1, 1), COLOR_PLATE_SHADE)
	for i in keys.size():
		var rect := Rect2(x, 0, widths[i], KeyCap.HEIGHT)
		draw_rect(Rect2(rect.position, Vector2(rect.size.x, 1)), color)
		draw_rect(Rect2(rect.position.x, rect.end.y - 1, rect.size.x, 1), color)
		draw_rect(Rect2(rect.position, Vector2(1, rect.size.y)), color)
		draw_rect(Rect2(rect.end.x - 1, rect.position.y, 1, rect.size.y), color)
		draw_rect(Rect2(rect.position.x + 1, rect.end.y, rect.size.x - 1, 1), color)
		draw_rect(Rect2(rect.end.x, rect.position.y + 1, 1, rect.size.y), color)
		var text_width := font.get_string_size(keys[i], HORIZONTAL_ALIGNMENT_LEFT, -1, KeyCap.FONT_SIZE).x
		draw_string(font, Vector2(x + floorf((widths[i] - text_width) * 0.5), 11), keys[i], HORIZONTAL_ALIGNMENT_LEFT, -1, KeyCap.FONT_SIZE, color)
		x += widths[i] + KEY_GAP
	var word := get_word()
	if word != "":
		var word_width := font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, WORD_SIZE).x
		draw_string(font, Vector2(-floorf(word_width * 0.5), KeyCap.HEIGHT + WORD_GAP + 10), word, HORIZONTAL_ALIGNMENT_LEFT, -1, WORD_SIZE, color)
