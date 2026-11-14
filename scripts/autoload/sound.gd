class_name Sound
extends RefCounted
## Kurzer Zugang zum Autoload "Sfx" (scripts/autoload/sfx.gd) fuer alle
## Skripte: Sound.play("jump"). Statisch, damit es auch in Klassen mit
## class_name funktioniert (die kennen Autoload-Namen nicht immer beim
## Kompilieren). Fehlt das Autoload, passiert nichts.


static func play(id: String, volume_db := 0.0, pitch := 1.0) -> void:
	var sfx := _sfx()
	if sfx:
		sfx.play(id, volume_db, pitch)


static func play_at(id: String, position: Vector2, volume_db := 0.0, pitch := 1.0) -> void:
	var sfx := _sfx()
	if sfx:
		sfx.play_at(id, position, volume_db, pitch)


static func loop(id: String, parent: Node, time_source: TimeAffected = null, volume_db := 0.0) -> AudioStreamPlayer2D:
	var sfx := _sfx()
	if sfx:
		return sfx.loop(id, parent, time_source, volume_db)
	var silent := AudioStreamPlayer2D.new()
	parent.add_child(silent)
	return silent


static func play_ambient(id: String) -> void:
	var sfx := _sfx()
	if sfx:
		sfx.play_ambient(id)


static func stop_ambient() -> void:
	var sfx := _sfx()
	if sfx:
		sfx.stop_ambient()


static func _sfx() -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	return tree.root.get_node_or_null("Sfx") if tree else null
