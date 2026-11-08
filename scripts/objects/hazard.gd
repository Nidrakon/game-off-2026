@tool
class_name Hazard
extends Area2D
## Baustein "toedlich bei Beruehrung": Beruehrt der Professor diese Flaeche,
## stirbt er. Grundlage fuer alle Gefahren (Starkstrom, Projektile, spaeter
## Pendel usw.). Die Form kommt von einer CollisionShape2D als Kind oder wird
## von abgeleiteten Skripten im Code erzeugt.
## Erkennt Ebene 2 "player" (collision_mask), liegt selbst auf keiner Ebene.
## Prueft jeden Physik-Schritt (nicht nur beim Eintreten), damit eine Ausnahme
## (_is_safe_for) ablaufen kann, waehrend jemand noch in der Flaeche ist.


func _ready() -> void:
	if Engine.is_editor_hint():
		set_physics_process(false)


func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.has_method("die") and not _is_safe_for(body):
			body.die()


## Abgeleitete Skripte koennen hier Ausnahmen festlegen.
func _is_safe_for(_body: Node2D) -> bool:
	return false
