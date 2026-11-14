extends StaticBody2D
## Trefferflaeche: Trifft ein Projektil sie, loest sie einen elektrischen Impuls
## aus und sendet ein Signal an alle Ziele in "targets" (z. B. eine Tuer).
## Sie ist ein festes Hindernis (Ebene 1): Der Professor kann sie nicht
## ausloesen, aber darauf stehen. Das Projektil verschwindet beim Treffer und
## ruft dabei on_projectile_hit() auf.
## Der Node liegt in der Mitte der Trefferflaeche.

## Dauer des sichtbaren Impulses (Sekunden).
const SPARK_TIME := 0.3
## Wechsel zwischen den zwei Funken-Bildern (Sekunden).
const SPARK_FRAME_TIME := 0.05

## Ziele, die das Signal bekommen (Doku 2.4, Signal-Empfaenger).
@export var targets: Array[Node] = []
## Was bei den Zielen passiert: umschalten, einschalten oder ausschalten.
@export var action := SignalSender.Action.TOGGLE

var _spark_left := 0.0

@onready var _sprite: Sprite2D = $Sprite


## Wird vom Projektil beim Aufprall aufgerufen.
func on_projectile_hit() -> void:
	Sound.play_at("impact_switch", global_position)
	_spark_left = SPARK_TIME
	SignalSender.send(targets, action, self)


func _process(delta: float) -> void:
	if _spark_left <= 0.0:
		return
	_spark_left -= delta
	# Bild 0 = ruhig, Bilder 1 und 2 = Funken im Wechsel.
	_sprite.frame = 0 if _spark_left <= 0.0 else 1 + int(_spark_left / SPARK_FRAME_TIME) % 2
