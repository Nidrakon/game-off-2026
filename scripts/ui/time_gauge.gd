extends Control
## Zeitregler im Bedienfeld, gestaltet wie eine Tankanzeige: drei feste
## Stufen (links langsam, Mitte normal, rechts schnell). Mit der Maus auf
## einen Bereich klicken oder die Nadel ziehen, um die Stufe zu waehlen.
## Gezeichnet im Code, nur Farben der Palette (Doku 1.7).

const ICONS := preload("res://graphics/ui/ui_time_stage_icons.png")

# Masse (Pixel, bezogen auf die linke obere Ecke des Reglers).
const PIVOT := Vector2(112, 112)
const ARC_RADIUS := 60.0
const ARC_WIDTH := 10.0
const ICON_RADIUS := 84.0
const NEEDLE_LENGTH := 54.0
## Wie schnell die Nadel zur neuen Stufe schwenkt (Grad pro Sekunde).
const NEEDLE_SPEED := 720.0
## Winkel der Nadel je Stufe in Grad (270 = senkrecht nach oben).
const STAGE_ANGLES := [210.0, 270.0, 330.0]

# Farben aus der Palette.
const COLOR_OUTLINE := Color("2e222f")
const COLOR_BODY := Color("9babb2")
const COLOR_LIGHT := Color("c7dcd0")
const COLOR_SHADOW := Color("7f708a")
const COLOR_FACE := Color("3e3546")
const COLOR_NEEDLE := Color("e83b3b")
## Farbe je Stufe: hell = gewaehlt, dunkel = nicht gewaehlt.
const STAGE_BRIGHT := [Color("4d9be6"), Color("c7dcd0"), Color("fb6b1d")]
const STAGE_DIM := [Color("484a77"), Color("7f708a"), Color("9e4539")]

var _bubble: TimeBubble
var _needle_angle := 270.0
var _dragging := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP


func _process(delta: float) -> void:
	var bubble := _find_bubble()
	if bubble == null:
		return
	var target: float = STAGE_ANGLES[bubble.stage]
	if not is_equal_approx(_needle_angle, target):
		_needle_angle = move_toward(_needle_angle, target, NEEDLE_SPEED * delta)
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	var button := event as InputEventMouseButton
	if button and button.button_index == MOUSE_BUTTON_LEFT:
		_dragging = button.pressed
		if button.pressed:
			_select_at(button.position)
		accept_event()
	elif event is InputEventMouseMotion and _dragging:
		_select_at((event as InputEventMouseMotion).position)
		accept_event()


## Waehlt die Stufe, in deren Richtung die Maus vom Drehpunkt aus zeigt.
func _select_at(local_position: Vector2) -> void:
	var bubble := _find_bubble()
	if bubble == null:
		return
	var offset := local_position - PIVOT
	var degrees := fposmod(rad_to_deg(offset.angle()), 360.0)
	# Unterhalb des Drehpunkts: links = langsam, rechts = schnell.
	if offset.y > 0.0:
		degrees = 180.0 if offset.x < 0.0 else 360.0
	if degrees < 240.0:
		bubble.stage = TimeBubble.Stage.SLOW
	elif degrees < 300.0:
		bubble.stage = TimeBubble.Stage.NORMAL
	else:
		bubble.stage = TimeBubble.Stage.FAST


func _find_bubble() -> TimeBubble:
	if not is_instance_valid(_bubble):
		_bubble = get_tree().get_first_node_in_group(TimeBubble.GROUP) as TimeBubble
	return _bubble


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	# Gehaeuse mit Umriss, Lichtkante oben/links und Schatten unten/rechts.
	draw_rect(rect, COLOR_OUTLINE)
	draw_rect(rect.grow(-2), COLOR_SHADOW)
	draw_rect(Rect2(2, 2, size.x - 6, size.y - 6), COLOR_LIGHT)
	draw_rect(Rect2(4, 4, size.x - 8, size.y - 8), COLOR_BODY)
	# Anzeigefenster
	var face := Rect2(10, 10, size.x - 20, size.y - 20)
	draw_rect(face, COLOR_OUTLINE)
	draw_rect(face.grow(-1), COLOR_FACE)

	var selected := -1
	var bubble := _find_bubble()
	if bubble:
		selected = bubble.stage
	for i in 3:
		var color: Color = STAGE_BRIGHT[i] if i == selected else STAGE_DIM[i]
		# Bogenstueck je Stufe (je 60 Grad, mit kleiner Luecke dazwischen).
		var start := deg_to_rad(180.0 + i * 60.0 + 2.0)
		var end := deg_to_rad(180.0 + (i + 1) * 60.0 - 2.0)
		draw_arc(PIVOT, ARC_RADIUS, start, end, 24, color, ARC_WIDTH, false)
		# Symbol der Stufe aussen am Bogen
		var dir := Vector2.from_angle(deg_to_rad(STAGE_ANGLES[i]))
		var icon_center := (PIVOT + dir * ICON_RADIUS).round()
		draw_texture_rect_region(ICONS, Rect2(icon_center - Vector2(8, 8), Vector2(16, 16)),
				Rect2(i * 16, 0, 16, 16), color)

	# Nadel und Drehpunkt
	var tip := PIVOT + Vector2.from_angle(deg_to_rad(_needle_angle)) * NEEDLE_LENGTH
	draw_line(PIVOT, tip, COLOR_NEEDLE, 2.0, false)
	draw_circle(PIVOT, 6.0, COLOR_OUTLINE, true, -1.0, false)
	draw_circle(PIVOT, 3.0, COLOR_BODY, true, -1.0, false)
