class_name TimeAffected
extends Node2D
## Baustein fuer alles, was auf die Zeitblase reagiert. Als Kind-Node an ein
## Objekt haengen und die Groesse (bounds) passend einstellen.
## Das Objekt rechnet dann mit "delta * time_scale" statt nur mit "delta".
## Solange das Objekt die Blase beruehrt, wird es farbig umrandet, aber nur,
## wenn das im F1-Menue eingeschaltet ist (zum Testen; im Spiel nie).

## Wird gesendet, wenn sich das Tempo dieses Objekts aendert.
signal time_scale_changed(new_scale: float)

## Flaeche des Objekts relativ zu diesem Node (fuer die Beruehrung mit der
## Blase und fuer die Markierung).
@export var bounds := Rect2(-8, -8, 16, 16):
	set(value):
		bounds = value
		queue_redraw()

## Aktuelles Tempo dieses Objekts (1 = normal). Nur lesen.
var time_scale := 1.0

var _bubble: TimeBubble
# Farbe der Markierung; transparent = keine Markierung.
var _marker_color := Color.TRANSPARENT
# Wird die Markierung gerade gezeichnet (Schalter im F1-Menue)?
var _markers_shown := false


func _ready() -> void:
	# Vor dem Objekt selbst rechnen, damit es im selben Physik-Schritt schon
	# das aktuelle Tempo verwendet.
	process_physics_priority = -1


func _physics_process(_delta: float) -> void:
	var bubble := _find_bubble()
	var new_scale := 1.0
	var new_color := Color.TRANSPARENT
	if bubble and bubble.overlaps_rect(get_global_bounds()):
		new_scale = bubble.get_time_scale()
		if bubble.stage != TimeBubble.Stage.NORMAL:
			new_color = bubble.get_stage_color()

	var shown := _markers_enabled()
	if new_color != _marker_color or shown != _markers_shown:
		_marker_color = new_color
		_markers_shown = shown
		queue_redraw()
	if new_scale != time_scale:
		time_scale = new_scale
		time_scale_changed.emit(time_scale)


## Flaeche des Objekts in Weltkoordinaten.
func get_global_bounds() -> Rect2:
	return Rect2(global_position + bounds.position, bounds.size)


## Schalter "Time markers" im F1-Menue. Im exportierten Spiel ist das Menue
## aus, dann bleibt die Markierung immer unsichtbar.
func _markers_enabled() -> bool:
	var dev_menu := get_node_or_null("/root/DevMenu")
	return dev_menu != null and dev_menu.show_time_markers


func _find_bubble() -> TimeBubble:
	if not is_instance_valid(_bubble):
		_bubble = get_tree().get_first_node_in_group(TimeBubble.GROUP) as TimeBubble
	return _bubble


func _draw() -> void:
	# Markierung: Rahmen in der Farbe der Zeitstufe, 1 px ausserhalb des Objekts.
	if _markers_shown and _marker_color.a > 0.0:
		draw_rect(bounds.grow(1.0), _marker_color, false, 1.0)
