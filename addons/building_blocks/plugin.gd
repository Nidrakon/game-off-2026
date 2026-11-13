@tool
extends EditorPlugin
## Baukasten (Doku 2.9, Level-Builder): fuegt dem Editor eine Leiste
## "Baukasten" hinzu (rechts, als Reiter neben dem Inspector). Details siehe
## dock.gd.

var _dock: Control


func _enter_tree() -> void:
	_dock = preload("res://addons/building_blocks/dock.gd").new()
	_dock.name = "Baukasten"
	_dock.undo_redo = get_undo_redo()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, _dock)


func _exit_tree() -> void:
	if _dock != null:
		remove_control_from_docks(_dock)
		_dock.queue_free()
		_dock = null
