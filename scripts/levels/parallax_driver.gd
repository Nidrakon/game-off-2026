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

@export_group("Faktoren")
## Kabel und Maschinen hinter der Wand (DeepBackground).
@export_range(0.0, 1.0, 0.01) var deep_factor := 0.55
## Rueckwand und Silhouetten (BackWall, BackgroundScatter).
@export_range(0.0, 1.0, 0.01) var wall_factor := 0.8
## Hintere Rohre (PipesBack).
@export_range(0.0, 1.0, 0.01) var pipes_factor := 0.9

## Mitte der bemalten Flaeche (Weltkoordinaten), gesetzt von der Level-Wurzel.
var anchor := Vector2.ZERO


## Verschiebung einer Ebene mit Faktor "factor" bei Kameramitte "center".
func offset_for(factor: float, center: Vector2) -> Vector2:
	return ((center - anchor) * (1.0 - factor)).round()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return
	var center := camera.get_screen_center_position()
	var root := get_parent()
	for entry in [["DeepBackground", deep_factor], ["BackWall", wall_factor], ["BackgroundScatter", wall_factor], ["PipesBack", pipes_factor]]:
		var layer := root.get_node_or_null(entry[0]) as Node2D
		if layer:
			layer.position = offset_for(entry[1], center)
