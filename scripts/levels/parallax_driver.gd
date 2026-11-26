@tool
class_name ParallaxDriver
extends Node
## Parallax fuer die Hintergrund-Ebenen eines Levels (Doku 2.9). Verschiebt
## jedes Bild die Ebenen gegen die Kamera, sodass sie langsamer laufen als der
## Vordergrund (Faktor 1 = wie der Vordergrund, 0 = steht still am Himmel).
## Ausgerichtet auf die Mitte der bemalten Flaeche: Steht die Kamera dort,
## liegen alle Ebenen genau an ihrem Platz (wie im Editor gemalt). Im Editor
## passiert nichts. Die Ebenen werden ueber ihre Namen in der Level-Wurzel
## gefunden; fehlt eine, wird sie uebersprungen.
## Folgt die Kamera kaum (Level so gross wie der Bildschirm), sorgt
## "player_influence" trotzdem fuer Tiefe: Fuer die tiefe Ebene (Kabel und
## Maschinen hinter den Durchbruechen der Wand) wandert der Bezugspunkt ein
## Stueck mit dem Professor, sie verschiebt sich also, wenn er laeuft oder
## springt. Rueckwand, Silhouetten und Rohre bleiben dabei an der Wand
## (sonst kaemen ihre Raender hinter den Aussenwaenden hervor).

@export_group("Faktoren")
## Kabel und Maschinen hinter der Wand (DeepBackground).
@export_range(0.0, 1.0, 0.01) var deep_factor := 0.55
## Rueckwand und Silhouetten (BackWall, BackgroundScatter).
@export_range(0.0, 1.0, 0.01) var wall_factor := 0.8
## Hintere Rohre (PipesBack).
@export_range(0.0, 1.0, 0.01) var pipes_factor := 0.9

@export_group("Figur")
## Wie stark die Position des Professors den Bezugspunkt verschiebt
## (0 = nur Kamera, 1 = als stuende die Kamera auf ihm).
@export_range(0.0, 1.0, 0.01) var player_influence := 0.4
## Wie schnell der Bezugspunkt der Figur folgt (je Sekunde, glaettet Spruenge).
@export_range(0.1, 30.0, 0.1) var follow_speed := 4.0

## Mitte der bemalten Flaeche (Weltkoordinaten), gesetzt von der Level-Wurzel.
var anchor := Vector2.ZERO
# Geglaettete Abweichung der Figur von der Bildmitte.
var _player_offset := Vector2.ZERO
var _has_offset := false


## Verschiebung einer Ebene mit Faktor "factor" bei Kameramitte "center".
func offset_for(factor: float, center: Vector2) -> Vector2:
	return ((center - anchor) * (1.0 - factor)).round()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return
	var center := camera.get_screen_center_position()
	var deep_center := center
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player and player_influence > 0.0:
		var want := (player.global_position - center) * player_influence
		if not _has_offset:
			_player_offset = want
			_has_offset = true
		_player_offset = _player_offset.lerp(want, clampf(follow_speed * delta, 0.0, 1.0))
		deep_center += _player_offset
	var root := get_parent()
	for entry in [["DeepBackground", deep_factor, deep_center], ["BackWall", wall_factor, center], ["BackgroundScatter", wall_factor, center], ["PipesBack", pipes_factor, center]]:
		var layer := root.get_node_or_null(entry[0]) as Node2D
		if layer:
			layer.position = offset_for(entry[1], entry[2])
