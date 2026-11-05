class_name MovementSettings
extends Resource
## Alle einstellbaren Werte fuer Laufen und Springen des Professors.
## Die Werte stehen in data/professor_movement.tres und lassen sich im
## Inspector aendern, ohne Code anzufassen.
## Einheiten: Pixel (1 Tile = 16 px) und Sekunden.

@export_group("Laufen")
## Hoechstgeschwindigkeit beim Laufen (Pixel pro Sekunde).
@export var run_speed: float = 100.0
## Wie schnell die Hoechstgeschwindigkeit am Boden erreicht wird.
@export var ground_acceleration: float = 900.0
## Wie schnell der Professor am Boden abbremst, wenn keine Taste gedrueckt ist.
@export var ground_deceleration: float = 1200.0
## Beschleunigung in der Luft (kleiner = traegere Luftsteuerung).
@export var air_acceleration: float = 700.0

@export_group("Springen")
## Sprunghoehe bei gehaltener Sprungtaste (Pixel).
@export var jump_height: float = 56.0
## Zeit vom Absprung bis zum hoechsten Punkt (Sekunden).
@export var time_to_apex: float = 0.38
## Schwerkraft beim Fallen im Verhaeltnis zum Steigen (> 1 = schnelleres Fallen).
@export var fall_gravity_multiplier: float = 1.6
## Hoechste Fallgeschwindigkeit (Pixel pro Sekunde).
@export var max_fall_speed: float = 320.0
## Laesst man die Sprungtaste beim Steigen los, wird die Steiggeschwindigkeit
## mit diesem Faktor multipliziert (kurz tippen = kleiner Sprung).
@export_range(0.0, 1.0) var jump_release_multiplier: float = 0.45

@export_group("Sprunghilfen")
## Coyote Time: so lange darf man nach dem Verlassen einer Kante noch springen.
@export var coyote_time: float = 0.1
## Sprungpuffer: so lange vor der Landung darf Springen schon gedrueckt werden.
@export var jump_buffer_time: float = 0.12


## Schwerkraft beim Steigen, berechnet aus Sprunghoehe und Steigzeit.
func get_rise_gravity() -> float:
	return 2.0 * jump_height / (time_to_apex * time_to_apex)


## Absprunggeschwindigkeit (nach oben), damit genau jump_height erreicht wird.
func get_jump_velocity() -> float:
	return 2.0 * jump_height / time_to_apex
