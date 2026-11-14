class_name MenuStyle
extends RefCounted
## Gemeinsamer Look fuer Titelbildschirm und Spielmenue (Doku 2.5): Knoepfe,
## Texte, Schieberegler, Kaesten. Nur Palettenfarben (Resurrect 64).

const COLOR_BG := Color("2e222f")
const COLOR_TITLE := Color("f9c22b")
const COLOR_BUTTON := Color("3e3546")
const COLOR_HOVER := Color("484a77")
const COLOR_PRESSED := Color("4d65b4")
const COLOR_FOCUS := Color("f9c22b")
const COLOR_TEXT := Color("c7dcd0")
const COLOR_DISABLED := Color("313638")
const COLOR_DISABLED_TEXT := Color("625565")
const COLOR_PANEL := Color("2e222f")
const COLOR_PANEL_BORDER := Color("7f708a")
const COLOR_TRACK_FILL := Color("4d65b4")


## Theme fuer Knoepfe, Labels und Schieberegler.
static func make_theme() -> Theme:
	var t := Theme.new()
	t.set_stylebox("normal", "Button", box(COLOR_BUTTON, COLOR_BUTTON, 1, 8))
	t.set_stylebox("hover", "Button", box(COLOR_HOVER, COLOR_HOVER, 1, 8))
	t.set_stylebox("pressed", "Button", box(COLOR_PRESSED, COLOR_PRESSED, 1, 8))
	t.set_stylebox("hover_pressed", "Button", box(COLOR_PRESSED, COLOR_PRESSED, 1, 8))
	t.set_stylebox("disabled", "Button", box(COLOR_DISABLED, COLOR_DISABLED, 1, 8))
	t.set_stylebox("focus", "Button", box(Color(0, 0, 0, 0), COLOR_FOCUS, 2, 8))
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
		t.set_color(state, "Button", COLOR_TEXT)
	t.set_color("font_disabled_color", "Button", COLOR_DISABLED_TEXT)
	t.set_font_size("font_size", "Button", 20)
	t.set_color("font_color", "Label", COLOR_TEXT)
	t.set_font_size("font_size", "Label", 18)
	# Schieberegler: Spur, gefuellter Teil, Griff (eigene Bilder in Palettenfarben)
	var track := box(COLOR_BUTTON, COLOR_BUTTON, 1, 0)
	track.content_margin_top = 4
	track.content_margin_bottom = 4
	t.set_stylebox("slider", "HSlider", track)
	t.set_stylebox("grabber_area", "HSlider", box(COLOR_TRACK_FILL, COLOR_TRACK_FILL, 1, 0))
	t.set_stylebox("grabber_area_highlight", "HSlider", box(COLOR_TRACK_FILL, COLOR_TRACK_FILL, 1, 0))
	t.set_stylebox("focus", "HSlider", box(Color(0, 0, 0, 0), COLOR_FOCUS, 2, 4))
	t.set_icon("grabber", "HSlider", square(14, COLOR_TEXT))
	t.set_icon("grabber_highlight", "HSlider", square(14, COLOR_TITLE))
	t.set_icon("grabber_disabled", "HSlider", square(14, COLOR_DISABLED_TEXT))
	return t


## Kasten mit Fuellung, Rand und Innenabstand (ohne Kantenglaettung).
static func box(fill: Color, border: Color, border_width: int, padding: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.draw_center = fill.a > 0.0
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_content_margin_all(padding)
	style.anti_aliasing = false
	return style


## Einfarbiges Quadrat als Textur (z. B. Griff des Schiebereglers).
static func square(size: int, color: Color) -> ImageTexture:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return ImageTexture.create_from_image(image)
