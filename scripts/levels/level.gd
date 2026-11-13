class_name Level
extends Node2D
## Grundlage jedes Levels (Doku 2.9, Level-Vorlage): Wurzel der Szene
## scenes/levels/level_base.tscn, von der alle Level erben. Stellt beim Start
## die Kameragrenzen automatisch auf die bemalte Flaeche des Bodens (Node
## "Ground"), damit man sie nicht von Hand pflegen muss. Meldet den Start dem
## Spielstand (automatisches Speichern am Levelanfang, Doku 2.7).

## Kameragrenzen automatisch aus den Tiles von "Ground" setzen.
@export var auto_camera_limits := true


func _ready() -> void:
	if auto_camera_limits:
		_fit_camera_to_ground()
	SaveGame.on_level_started(scene_file_path)


func _fit_camera_to_ground() -> void:
	var ground := get_node_or_null("Ground") as TileMapLayer
	var camera := get_node_or_null("Camera") as Camera2D
	if ground == null or camera == null or ground.tile_set == null:
		return
	var used := ground.get_used_rect()
	if used.size == Vector2i.ZERO:
		return
	var tile := Vector2(ground.tile_set.tile_size)
	var top_left := ground.to_global(Vector2(used.position) * tile)
	var bottom_right := ground.to_global(Vector2(used.end) * tile)
	camera.limit_left = roundi(top_left.x)
	camera.limit_top = roundi(top_left.y)
	camera.limit_right = roundi(bottom_right.x)
	camera.limit_bottom = roundi(bottom_right.y)
