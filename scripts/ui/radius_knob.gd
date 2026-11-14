extends Control
## Drehregler im Bedienfeld (Formregler, Doku 2.3): stellt den Radius der
## Zeitblase ein. Bedienung: Klicken bzw. Maustaste halten, der Zeiger dreht
## sich zur Maus, als wuerde er magnetisch angezogen (links unten = kleinster,
## rechts unten = groesster Radius). Zeigt die Maus in die Luecke unten, bleibt
## der Zeiger am naeheren Anschlag. Rechtsklick setzt auf den Startradius
## zurueck.
##
## Upgrade (Doku 2.3): Solange der Professor das Upgrade "Radius" noch nicht
## an einem Schrotthaufen gefunden hat, sitzt hier nur eine Abdeckplatte.

## So nah an der Mitte wird die Maus ignoriert (Richtung waere unklar).
const DEAD_ZONE := 2.0
## Drehbereich des Zeigers in Grad (links unten bis rechts unten).
const ANGLE_MIN := 135.0
const ANGLE_MAX := 405.0
const KNOB_RADIUS := 14.0

var _bubble: TimeBubble
var _dragging := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP


func _process(_delta: float) -> void:
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	var bubble := _find_bubble()
	if bubble == null or not is_unlocked():
		return
	var button := event as InputEventMouseButton
	if button and button.button_index == MOUSE_BUTTON_LEFT:
		_dragging = button.pressed
		if button.pressed:
			_point_to(button.position)
		accept_event()
	elif button and button.button_index == MOUSE_BUTTON_RIGHT and button.pressed:
		bubble.radius = bubble.settings.radius
		accept_event()
	elif event is InputEventMouseMotion and _dragging:
		_point_to((event as InputEventMouseMotion).position)
		accept_event()


## Dreht den Zeiger zur Mausposition (lokale Koordinaten).
func _point_to(local_position: Vector2) -> void:
	var bubble := _find_bubble()
	var offset := local_position - (size * 0.5).floor()
	if bubble == null or offset.length() < DEAD_ZONE:
		return
	# Winkel in den Drehbereich ANGLE_MIN bis ANGLE_MIN + 360 legen.
	var angle := fposmod(rad_to_deg(offset.angle()) - ANGLE_MIN, 360.0) + ANGLE_MIN
	if angle > ANGLE_MAX:
		# Luecke unten: zum naeheren Anschlag.
		angle = ANGLE_MAX if angle - ANGLE_MAX < ANGLE_MIN + 360.0 - angle else ANGLE_MIN
	var fraction := inverse_lerp(ANGLE_MIN, ANGLE_MAX, angle)
	var before := bubble.radius
	bubble.radius = lerpf(bubble.settings.radius_min, bubble.settings.radius_max, fraction)
	# Tick je 4 px Radius (wie eine Rastung)
	if floori(before / 4.0) != floori(bubble.radius / 4.0):
		Sound.play("knob_tick")


## Ist der Regler schon eingebaut (Upgrade "Radius")?
func is_unlocked() -> bool:
	return Upgrades.has(TimeShifterUpgrades.Upgrade.RADIUS)


## Stellung des Reglers: 0 = kleinster, 1 = groesster Radius.
func get_fraction() -> float:
	var bubble := _find_bubble()
	if bubble == null:
		return 0.5
	return inverse_lerp(bubble.settings.radius_min, bubble.settings.radius_max, bubble.radius)


func _find_bubble() -> TimeBubble:
	if not is_instance_valid(_bubble):
		_bubble = get_tree().get_first_node_in_group(TimeBubble.GROUP) as TimeBubble
	return _bubble


func _draw() -> void:
	PanelStyle.draw_housing(self, Rect2(Vector2.ZERO, size))
	if not is_unlocked():
		PanelStyle.draw_cover(self, Rect2(Vector2.ZERO, size))
		return
	var center := (size * 0.5).floor()
	# Skala: Striche fuer klein, Mitte, gross
	for i in 5:
		var a := deg_to_rad(lerpf(ANGLE_MIN, ANGLE_MAX, i / 4.0))
		var dir := Vector2.from_angle(a)
		draw_line(center + dir * (KNOB_RADIUS + 2), center + dir * (KNOB_RADIUS + 5), PanelStyle.COLOR_OUTLINE, 1.0)
	# Knopf mit Zeiger
	draw_circle(center, KNOB_RADIUS, PanelStyle.COLOR_OUTLINE, true, -1.0, false)
	draw_circle(center, KNOB_RADIUS - 1, PanelStyle.COLOR_SHADOW, true, -1.0, false)
	draw_circle(center - Vector2(1, 1), KNOB_RADIUS - 3, PanelStyle.COLOR_BODY, true, -1.0, false)
	var angle := deg_to_rad(lerpf(ANGLE_MIN, ANGLE_MAX, get_fraction()))
	draw_line(center, center + Vector2.from_angle(angle) * (KNOB_RADIUS - 3), PanelStyle.COLOR_ACCENT, 2.0)
	draw_circle(center, 2.0, PanelStyle.COLOR_OUTLINE, true, -1.0, false)
