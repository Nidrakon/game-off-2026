class_name TimeBubbleSettings
extends Resource
## Alle einstellbaren Werte der Zeitblase.
## Die Werte stehen in data/time_bubble_settings.tres und lassen sich im
## Inspector aendern, ohne Code anzufassen.
## Farben nur aus der Palette Resurrect 64 (siehe Doku 1.7).

@export_group("Zeitstufen")
## Tempo der Objekte in der Blase auf Stufe "langsam" (1 = normal).
@export_range(0.05, 1.0, 0.05) var slow_factor: float = 0.3
## Tempo der Objekte in der Blase auf Stufe "schnell" (1 = normal).
@export_range(1.0, 5.0, 0.1) var fast_factor: float = 2.0

@export_group("Form")
## Radius der Blase beim Start in Pixeln (1 Tile = 16 px).
@export var radius: float = 80.0
## Kleinster und groesster Radius, der sich mit dem Drehregler einstellen laesst.
@export var radius_min: float = 32.0
@export var radius_max: float = 80.0
## Groesste Streckung durch den Cursor: Das Ei wird hoechstens so oft so lang
## wie der Durchmesser des Kreises (2 = doppelt so lang).
@export_range(1.0, 5.0, 0.1) var stretch_max: float = 2.0
## Nahe den Mittellinien des Cursors rastet die Achse auf 0 ein (Anteil des Wegs).
@export_range(0.0, 0.3, 0.01) var stretch_snap: float = 0.08

@export_group("Aussehen")
## Farbe der Blase und der Markierung je Stufe (aus der Palette).
@export var color_slow: Color = Color("4d9be6")
@export var color_normal: Color = Color("c7dcd0")
@export var color_fast: Color = Color("fb6b1d")
## Deckkraft der Flaeche (0 = unsichtbar, 1 = voll deckend).
@export_range(0.0, 1.0, 0.01) var fill_alpha: float = 0.12
## Deckkraft des Randes.
@export_range(0.0, 1.0, 0.01) var outline_alpha: float = 0.7
## Deckkraft des Randes auf Stufe "normal" (Blase faktisch aus, nur angedeutet).
@export_range(0.0, 1.0, 0.01) var outline_alpha_normal: float = 0.25
