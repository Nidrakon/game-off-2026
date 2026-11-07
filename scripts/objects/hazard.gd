class_name Hazard
extends Area2D
## Baustein "toedlich bei Beruehrung": Beruehrt der Professor diese Flaeche,
## stirbt er. Grundlage fuer alle Gefahren (Starkstrom, spaeter Projektile,
## Pendel usw.). Die Form kommt von einer CollisionShape2D als Kind oder wird
## von abgeleiteten Skripten im Code erzeugt.
## Erkennt Ebene 2 "player" (collision_mask), liegt selbst auf keiner Ebene.


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die()
