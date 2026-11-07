class_name TimeBubble
extends Node2D
## Die Zeitblase des Time Shifters. Sie haengt am Professor und zeichnet sich
## selbst. Objekte mit einem TimeAffected-Baustein fragen sie jeden Physik-
## Schritt, ob sie die Blase beruehren und wie schnell ihre Zeit laeuft.
## Der Professor selbst wird nicht beeinflusst.

## Die drei festen Zeitstufen (Doku 2.3).
enum Stage { SLOW, NORMAL, FAST }

## Wird gesendet, wenn die Zeitstufe wechselt.
signal stage_changed(new_stage: Stage)

## Gruppe, ueber die die Objekte die Blase finden.
const GROUP := "time_bubble"

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


func _ready() -> void:
	add_to_group(GROUP)


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


## Halbachsen der Blase. Jetzt ein Kreis; die Formregler (Schritt 13)
## machen daraus spaeter eine Ellipse.
func get_radii() -> Vector2:
	return Vector2(settings.radius, settings.radius)


## Beruehrt das Rechteck (in Weltkoordinaten) die Blase?
## "Beruehren genuegt" (Doku 2.3): Das Objekt muss nicht ganz drin sein.
func overlaps_rect(global_rect: Rect2) -> bool:
	var radii := get_radii()
	# Trick: Wir stauchen alles so, dass die Blase ein Kreis mit Radius 1
	# wird. Dann ist die Frage nur noch: Liegt der Punkt des Rechtecks, der
	# dem Mittelpunkt am naechsten ist, hoechstens 1 entfernt?
	var center := global_position
	var closest := center.clamp(global_rect.position, global_rect.end)
	var scaled := (closest - center) / radii
	return scaled.length_squared() <= 1.0


func _draw() -> void:
	var radii := get_radii()
	var color := get_stage_color()
	var outline_alpha := settings.outline_alpha
	if stage == Stage.NORMAL:
		outline_alpha = settings.outline_alpha_normal
	else:
		# Flaeche nur, wenn die Blase wirklich wirkt.
		draw_circle(Vector2.ZERO, radii.x, Color(color, settings.fill_alpha))
	draw_circle(Vector2.ZERO, radii.x, Color(color, outline_alpha), false, 1.0)
