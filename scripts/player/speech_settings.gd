class_name SpeechSettings
extends Resource
## Einstellungen fuer die Sprueche des Professors (Doku 2.8, 3.6). Die Werte
## stehen in data/speech_settings.tres und lassen sich im Inspector aendern.
## Texte in dialogues/speech.json (Listen "quips_random", "quips_respawn").

@export_group("Zufaellige Sprueche")
## Kleinster und groesster Abstand zwischen zwei Spruechen (Sekunden Spielzeit).
@export_range(1.0, 600.0, 1.0, "or_greater") var random_interval_min := 35.0
@export_range(1.0, 600.0, 1.0, "or_greater") var random_interval_max := 70.0
## Wartezeit bis zum ersten Spruch nach dem Levelstart (Sekunden).
@export_range(0.0, 600.0, 1.0, "or_greater") var first_delay := 20.0
## Zufaellige Sprueche ganz abschalten.
@export var random_enabled := true

@export_group("Respawn")
## Wahrscheinlichkeit fuer einen Respawn-Spruch nach dem Tod (0 bis 1).
@export_range(0.0, 1.0, 0.05) var respawn_chance := 1.0
## Wartezeit nach dem Erscheinen in der Klonstation (Sekunden).
@export_range(0.0, 5.0, 0.05) var respawn_delay := 0.8

@export_group("Sprechblase")
## Grundzeit und Zusatzzeit pro Zeichen, die eine Blase stehen bleibt.
@export_range(0.5, 10.0, 0.1) var bubble_base_time := 2.0
@export_range(0.0, 0.3, 0.005) var bubble_time_per_char := 0.05
