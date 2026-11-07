extends Control
## Kleines Symbol oben links im Spiel: zeigt die aktuelle Zeitstufe
## (1 Pfeil = langsam, 2 = normal, 3 = schnell) in der Farbe der Stufe.

const ICONS := preload("res://graphics/ui/ui_time_stage_icons.png")
const COLOR_OUTLINE := Color("2e222f")
const COLOR_FACE := Color("3e3546")

var _bubble: TimeBubble
var _shown_stage := -1


func _process(_delta: float) -> void:
	if not is_instance_valid(_bubble):
		_bubble = get_tree().get_first_node_in_group(TimeBubble.GROUP) as TimeBubble
	if _bubble and _bubble.stage != _shown_stage:
		_shown_stage = _bubble.stage
		queue_redraw()


func _draw() -> void:
	if _bubble == null:
		return
	var color := _bubble.get_stage_color()
	draw_rect(Rect2(Vector2.ZERO, size), COLOR_OUTLINE)
	draw_rect(Rect2(1, 1, size.x - 2, size.y - 2), color)
	draw_rect(Rect2(2, 2, size.x - 4, size.y - 4), COLOR_FACE)
	var icon_pos := ((size - Vector2(16, 16)) * 0.5).round()
	draw_texture_rect_region(ICONS, Rect2(icon_pos, Vector2(16, 16)),
			Rect2(_shown_stage * 16, 0, 16, 16), color)
