extends Control
## Oszilloskop im Bedienfeld (Doku 2.3): zeigt im XY-Modus die aktuelle Form
## der Zeitblase als Leuchtspur (Kreis bzw. Ei). Der Leuchtpunkt laeuft je
## nach Zeitstufe langsamer oder schneller um. Das kleine Kreuz in der Mitte
## ist der Professor. Laeuft auch bei pausiertem Spiel.
##
## Formregler: Ein in x und y beweglicher Cursor (Fadenkreuz) streckt die
## Blase zum Ei in Richtung des Cursors (auch schraeg). Cursor in der Mitte =
## Kreis, je weiter aussen, desto laenger. Klicken oder Ziehen auf dem
## Bildschirm setzt den Cursor, nahe den Mittellinien rastet er ein,
## Rechtsklick setzt ihn auf die Mitte.

## Abstand der Spur zum Bildschirmrand in Pixeln, wenn das Ei bis an den
## Rand reicht.
const TRACE_MARGIN := 1.0
## Umlaeufe des Leuchtpunkts pro Sekunde je Zeitstufe (langsam, normal, schnell).
const SPEEDS := [0.25, 0.7, 2.0]
## Laenge der Leuchtspur (Anteil eines Umlaufs) und Punkte darin.
const TRAIL_LENGTH := 0.45
const TRAIL_POINTS := 24
## Rand zwischen Gehaeuse und Bildschirm.
const SCREEN_MARGIN := 6.0
## Abstand des Cursor-Bereichs vom Bildschirmrand (Pixel). Am Rand dieses
## Bereichs ist die Streckung voll.
const CURSOR_MARGIN := 6.0

# Farben aus der Palette: Bildschirm, Raster, Nachleuchten, Spur, Leuchtpunkt,
# Cursor (Fadenkreuz) und seine gestrichelten Linien.
const COLOR_SCREEN := Color("313638")
const COLOR_GRID := Color("374e4a")
const COLOR_GLOW := Color("547e64")
const COLOR_TRAIL := Color("1ebc73")
const COLOR_HEAD := Color("cddf6c")
const COLOR_CURSOR := Color("fbb954")
const COLOR_CURSOR_LINE := Color("9e4539")

var _bubble: TimeBubble
var _phase := 0.0
var _dragging := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP


func _process(delta: float) -> void:
	var bubble := _find_bubble()
	var stage := TimeBubble.Stage.NORMAL if bubble == null else bubble.stage
	_phase = fposmod(_phase + delta * SPEEDS[stage], 1.0)
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	var button := event as InputEventMouseButton
	if button and button.button_index == MOUSE_BUTTON_LEFT:
		_dragging = button.pressed
		if button.pressed:
			_set_from_position(button.position)
		accept_event()
	elif button and button.button_index == MOUSE_BUTTON_RIGHT and button.pressed:
		_set_stretch(Vector2.ZERO)
		accept_event()
	elif event is InputEventMouseMotion and _dragging:
		_set_from_position((event as InputEventMouseMotion).position)
		accept_event()


func _find_bubble() -> TimeBubble:
	if not is_instance_valid(_bubble):
		_bubble = get_tree().get_first_node_in_group(TimeBubble.GROUP) as TimeBubble
	return _bubble


func _screen_rect() -> Rect2:
	return Rect2(Vector2(SCREEN_MARGIN, SCREEN_MARGIN), size - Vector2(SCREEN_MARGIN, SCREEN_MARGIN) * 2.0)


## Bereich, in dem sich der Cursor bewegt (Rand = volle Streckung).
func _cursor_rect() -> Rect2:
	return _screen_rect().grow(-CURSOR_MARGIN)


## Cursor-Position in Bildschirm-Pixeln (aus der Streckung der Blase).
## Die Streckung hat dieselbe Richtung wie der Bildschirm (y < 0 = oben).
func get_cursor_position() -> Vector2:
	var area := _cursor_rect()
	var bubble := _find_bubble()
	var stretch := Vector2.ZERO if bubble == null else bubble.stretch
	return (area.get_center() + stretch * area.size * 0.5).round()


func _set_from_position(local_position: Vector2) -> void:
	var area := _cursor_rect()
	var value := (local_position - area.get_center()) / (area.size * 0.5)
	_set_stretch(value.clamp(-Vector2.ONE, Vector2.ONE))


func _set_stretch(value: Vector2) -> void:
	var bubble := _find_bubble()
	if bubble == null:
		return
	# Nahe den Mittellinien einrasten, damit man leicht zu "nur waagrecht",
	# "nur senkrecht" oder zum Kreis zurueckkommt.
	var snap: float = bubble.settings.stretch_snap
	if absf(value.x) < snap:
		value.x = 0.0
	if absf(value.y) < snap:
		value.y = 0.0
	bubble.stretch = value


## Bildschirm-Pixel pro Welt-Pixel, fest: Die Spitze des groesstmoeglichen
## Eis (groesster Radius, volle Streckung) reicht vom Kreuz in der Mitte
## gerade bis an den Rand. Jede Form ist also immer ganz zu sehen.
func _zoom(screen: Rect2) -> float:
	var bubble := _find_bubble()
	var longest_tip := bubble.settings.radius_max * (1.0 + 2.0 * (bubble.settings.stretch_max - 1.0))
	return (screen.size.x * 0.5 - TRACE_MARGIN) / longest_tip


## Position des Professors (Kreuz) auf dem Bildschirm: immer die Mitte.
func _professor_point(screen: Rect2) -> Vector2:
	return screen.get_center()


## Punkt des Umrisses zum Zeitpunkt "phase" (0 bis 1), ungerundet und ohne
## Begrenzung auf den Bildschirm.
func _figure_point(phase: float, screen: Rect2) -> Vector2:
	var bubble := _find_bubble()
	if bubble == null:
		return screen.get_center()
	return _professor_point(screen) + bubble.get_outline_point(fposmod(phase, 1.0)) * _zoom(screen)


## Punkt auf der Spur zum Zeitpunkt "phase" (0 bis 1), in Bildschirm-Pixeln.
func _trace_point(phase: float, screen: Rect2) -> Vector2:
	# Zur Sicherheit am Rand anschlagen statt darueber hinaus zu zeichnen.
	return _figure_point(phase, screen).clamp(screen.position, screen.end - Vector2.ONE).round()


func _draw() -> void:
	PanelStyle.draw_housing(self, Rect2(Vector2.ZERO, size))
	var screen := _screen_rect()
	PanelStyle.draw_face(self, screen.grow(1), COLOR_SCREEN)
	# Raster: 4 x 4 Felder, Mittellinien durchgezogen
	for i in range(1, 4):
		var x := screen.position.x + roundf(screen.size.x * i / 4.0)
		var y := screen.position.y + roundf(screen.size.y * i / 4.0)
		for k in range(int(screen.position.y), int(screen.end.y), 1 if i == 2 else 3):
			draw_rect(Rect2(x, k, 1, 1), COLOR_GRID)
		for k in range(int(screen.position.x), int(screen.end.x), 1 if i == 2 else 3):
			draw_rect(Rect2(k, y, 1, 1), COLOR_GRID)
	# Cursor-Linien (gestrichelt, unter der Spur)
	var cursor := get_cursor_position()
	for k in range(int(screen.position.y), int(screen.end.y), 4):
		draw_rect(Rect2(cursor.x, k, 1, 2), COLOR_CURSOR_LINE)
	for k in range(int(screen.position.x), int(screen.end.x), 4):
		draw_rect(Rect2(k, cursor.y, 2, 1), COLOR_CURSOR_LINE)
	# Nachleuchten: die ganze Figur schwach
	var glow := PackedVector2Array()
	for i in 49:
		glow.append(_trace_point(i / 48.0, screen))
	draw_polyline(glow, COLOR_GLOW, 1.0)
	# Leuchtspur hinter dem Punkt und der Punkt selbst
	var trail := PackedVector2Array()
	for i in TRAIL_POINTS + 1:
		trail.append(_trace_point(_phase - TRAIL_LENGTH * (1.0 - float(i) / TRAIL_POINTS), screen))
	draw_polyline(trail, COLOR_TRAIL, 1.0)
	var head := _trace_point(_phase, screen)
	draw_rect(Rect2(head - Vector2(1, 1), Vector2(2, 2)), COLOR_HEAD)
	# Professor: kleines Kreuz
	var c := _professor_point(screen).round()
	draw_rect(Rect2(c.x - 2, c.y, 5, 1), COLOR_HEAD)
	draw_rect(Rect2(c.x, c.y - 2, 1, 5), COLOR_HEAD)
	# Cursor: offenes Quadrat (7 x 7) mit Mittelpunkt, ueber allem
	draw_rect(Rect2(cursor.x - 3, cursor.y - 3, 7, 1), COLOR_CURSOR)
	draw_rect(Rect2(cursor.x - 3, cursor.y + 3, 7, 1), COLOR_CURSOR)
	draw_rect(Rect2(cursor.x - 3, cursor.y - 2, 1, 5), COLOR_CURSOR)
	draw_rect(Rect2(cursor.x + 3, cursor.y - 2, 1, 5), COLOR_CURSOR)
	draw_rect(Rect2(cursor, Vector2.ONE), COLOR_CURSOR)
