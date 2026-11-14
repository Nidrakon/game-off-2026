class_name TimeBubble
extends Node2D
## Die Zeitblase des Time Shifters. Sie haengt am Professor und zeichnet sich
## selbst. Objekte mit einem TimeAffected-Baustein fragen sie jeden Physik-
## Schritt, ob sie die Blase beruehren und wie schnell ihre Zeit laeuft.
## Der Professor selbst wird nicht beeinflusst.
##
## Form (Doku 2.3, Formregler): Radius per Drehregler, dazu eine einseitige
## Streckung per Cursor auf dem Oszilloskop, in jede Richtung (auch schraeg).
## Gestreckt wird die Blase zum Ei: Hinten ein Halbkreis mit dem Radius um den
## Professor (der breite Teil), nach vorn in Cursorrichtung eine halbe Ellipse,
## die schmaler zulaeuft.

## Die drei festen Zeitstufen (Doku 2.3).
enum Stage { SLOW, NORMAL, FAST }

## Wird gesendet, wenn die Zeitstufe wechselt.
signal stage_changed(new_stage: Stage)
## Wird gesendet, wenn sich Radius oder Streckung aendern.
signal shape_changed

## Gruppe, ueber die die Objekte die Blase finden.
const GROUP := "time_bubble"
## Punkte des Umrisses (Zeichnen und Beruehrungstest).
const OUTLINE_POINTS := 64

## Werte der Blase (data/time_bubble_settings.tres).
@export var settings: TimeBubbleSettings

## Aktuelle Zeitstufe. Zu Beginn "normal" (Blase faktisch aus).
var stage: Stage = Stage.NORMAL:
	set(value):
		if value == stage:
			return
		stage = value
		queue_redraw()
		stage_changed.emit(stage)

## Aktueller Radius (Pixel), begrenzt auf radius_min bis radius_max.
var radius := 80.0:
	set(value):
		if settings:
			value = clampf(value, settings.radius_min, settings.radius_max)
		if is_equal_approx(value, radius):
			return
		radius = value
		_polygon_dirty = true
		queue_redraw()
		shape_changed.emit()

## Streckung = Cursorposition, je Achse -1 bis 1 (0, 0 = Kreis). Die Richtung
## des Vektors ist die Streckrichtung (x > 0 = rechts, y < 0 = oben), seine
## Laenge (hoechstens 1) die Staerke. In der Ecke (1, 1) also volle Streckung
## schraeg nach rechts unten.
var stretch := Vector2.ZERO:
	set(value):
		value = value.clamp(Vector2(-1, -1), Vector2(1, 1))
		if value.is_equal_approx(stretch):
			return
		stretch = value
		_polygon_dirty = true
		queue_redraw()
		shape_changed.emit()

## Shader fuer die Linse (Doku 2.3, Schritt 19b).
const LENS_SHADER := preload("res://scripts/time_bubble/time_bubble_lens.gdshader")

var _lens: Polygon2D
var _lens_phase := 0.0

# Umriss relativ zum Professor, wird nur bei Formaenderung neu berechnet.
var _polygon := PackedVector2Array()
var _polygon_dirty := true


func _ready() -> void:
	add_to_group(GROUP)
	radius = settings.radius
	if settings.lens_enabled:
		_lens = Polygon2D.new()
		_lens.name = "Lens"
		var material := ShaderMaterial.new()
		material.shader = LENS_SHADER
		_lens.material = material
		# Der Rand (_draw) liegt ueber der Linse.
		_lens.show_behind_parent = true
		add_child(_lens)
		shape_changed.connect(_update_lens_shape)
		_update_lens_shape()


func _process(delta: float) -> void:
	if _lens == null:
		return
	var speed := settings.normal_speed
	var strength := 0.0
	var rim := settings.rim_strength_normal
	match stage:
		Stage.SLOW:
			speed = settings.slow_speed
			strength = 1.0
			rim = settings.rim_strength_active
		Stage.FAST:
			speed = settings.fast_speed
			strength = 1.0
			rim = settings.rim_strength_active
	_lens_phase = fmod(_lens_phase + delta * speed, TAU * 100.0)
	var material := _lens.material as ShaderMaterial
	material.set_shader_parameter("stage", int(stage == Stage.SLOW) + 2 * int(stage == Stage.FAST))
	material.set_shader_parameter("phase", _lens_phase)
	material.set_shader_parameter("strength", strength)
	material.set_shader_parameter("radius", radius)
	material.set_shader_parameter("front_length", get_front_length())
	material.set_shader_parameter("direction", get_stretch_direction())
	material.set_shader_parameter("slow_wobble", settings.slow_wobble)
	material.set_shader_parameter("slow_bulge", settings.slow_bulge)
	material.set_shader_parameter("slow_aberration", settings.slow_aberration)
	material.set_shader_parameter("fast_jitter", settings.fast_jitter)
	material.set_shader_parameter("fast_blur", settings.fast_blur)
	material.set_shader_parameter("fast_aberration", settings.fast_aberration)
	material.set_shader_parameter("rim_pull", settings.rim_pull)
	material.set_shader_parameter("rim_width", settings.rim_width)
	material.set_shader_parameter("rim_film", settings.rim_film)
	material.set_shader_parameter("rim_strength", rim)


## Die Linse (Shader-Flaeche) der Blase, falls eingeschaltet.
func get_lens() -> Polygon2D:
	return _lens


func _update_lens_shape() -> void:
	if _lens:
		_lens.polygon = get_local_polygon()


## Tempo-Faktor fuer Objekte in der Blase (1 = normal).
func get_time_scale() -> float:
	match stage:
		Stage.SLOW:
			return settings.slow_factor
		Stage.FAST:
			return settings.fast_factor
	return 1.0


## Farbe der aktuellen Stufe (fuer Blase und Markierung).
func get_stage_color() -> Color:
	match stage:
		Stage.SLOW:
			return settings.color_slow
		Stage.FAST:
			return settings.color_fast
	return settings.color_normal


## Staerke der Streckung, 0 bis 1.
func get_stretch_amount() -> float:
	return minf(stretch.length(), 1.0)


## Streckrichtung (Einheitsvektor). Ohne Streckung nach rechts (egal, Kreis).
func get_stretch_direction() -> Vector2:
	return stretch.normalized() if stretch != Vector2.ZERO else Vector2.RIGHT


## Abstand der Spitze vom Professor. Ohne Streckung der Radius; voll
## gestreckt ist das Ei insgesamt stretch_max-mal so lang wie der Kreis.
func get_front_length() -> float:
	return radius * (1.0 + 2.0 * get_stretch_amount() * (settings.stretch_max - 1.0))


## Punkt des Umrisses relativ zum Professor; t von 0 bis 1 einmal herum,
## beginnend an der Spitze.
func get_outline_point(t: float) -> Vector2:
	var angle := TAU * t
	var along := cos(angle)
	# Vorn halbe Ellipse bis zur Spitze, hinten Halbkreis mit dem Radius.
	along *= get_front_length() if along > 0.0 else radius
	var across := sin(angle) * radius
	var d := get_stretch_direction()
	return d * along + d.orthogonal() * across


## Umriss als Polygon relativ zum Professor.
func get_local_polygon() -> PackedVector2Array:
	if _polygon_dirty:
		_polygon = PackedVector2Array()
		for i in OUTLINE_POINTS:
			_polygon.append(get_outline_point(float(i) / OUTLINE_POINTS))
		_polygon_dirty = false
	return _polygon


## Beruehrt das Rechteck (in Weltkoordinaten) die Blase?
## "Beruehren genuegt" (Doku 2.3): Das Objekt muss nicht ganz drin sein.
func overlaps_rect(global_rect: Rect2) -> bool:
	# Schneller Vortest: ausserhalb des Kreises um die Spitze sicher nicht.
	var center := global_position
	var closest := center.clamp(global_rect.position, global_rect.end)
	if closest.distance_to(center) > get_front_length():
		return false
	# Rechteck in Koordinaten relativ zum Professor, dann Polygon gegen Polygon
	# (Schnittmenge nicht leer = Beruehrung, auch wenn es ganz drin liegt).
	var r := Rect2(global_rect.position - center, global_rect.size)
	var rect_poly := PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)])
	return not Geometry2D.intersect_polygons(get_local_polygon(), rect_poly).is_empty()


func _draw() -> void:
	# Seit 14.11.2026 zeigt der Shader die Form; Rand und Flaeche nur, wenn
	# in den Einstellungen eingeschaltet (oder ohne Shader).
	if _lens != null and not settings.draw_outline and not settings.draw_fill:
		return
	var points := get_local_polygon().duplicate()
	var color := get_stage_color()
	var outline_alpha := settings.outline_alpha
	if stage == Stage.NORMAL:
		outline_alpha = settings.outline_alpha_normal
	elif settings.draw_fill:
		# Flaeche nur, wenn die Blase wirklich wirkt (seit dem Shader aus).
		draw_colored_polygon(points, Color(color, settings.fill_alpha))
	points.append(points[0])
	draw_polyline(points, Color(color, outline_alpha), 1.0)
