class_name ProfessorAnimationSettings
extends Resource
## Einstellungen, wann welche Animation des Professors gezeigt wird.
## Die Werte stehen in data/professor_animation.tres und lassen sich im
## Inspector aendern, ohne Code anzufassen.
##
## Sprung: Die Bilder werden nicht nach Zeit abgespielt, sondern nach der
## senkrechten Geschwindigkeit gewaehlt (Steigen, Hoehepunkt, Fallen). Nur
## Absprung und Landung sind kurze, zeitgesteuerte Bilder.
## Geschwindigkeiten in Pixeln pro Sekunde (ein voller Sprung startet mit
## ca. 550 px/s nach oben), Zeiten in Sekunden.

@export_group("Laufen")
## Ab dieser Geschwindigkeit am Boden laeuft die Laufanimation.
@export var run_min_speed: float = 10.0

@export_group("Sprung: Zeiten")
## So lange steht nach dem Absprung das Absprung-Bild.
@export_range(0.0, 0.5, 0.01) var takeoff_time: float = 0.1
## So lange steht nach dem Aufsetzen das Landungs-Bild (0 = kein Landungsbild).
@export_range(0.0, 0.5, 0.01) var landing_time: float = 0.1

@export_group("Sprung: Geschwindigkeiten")
## Hoehepunkt-Bild, solange er langsamer als dieser Wert steigt oder faellt.
## Groesser = das Hoehepunkt-Bild steht laenger (kurz davor und danach).
@export var apex_speed: float = 120.0

@export_group("Sprung: Bilder (Nummer im Tag Jump, ab 0)")
@export var takeoff_frame: int = 0
@export var rise_frame: int = 1
@export var apex_frame: int = 2
@export var fall_frame: int = 3
@export var landing_frame: int = 4
