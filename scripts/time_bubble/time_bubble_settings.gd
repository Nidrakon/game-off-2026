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
## Farbige Flaeche zeichnen (seit dem Shader in Schritt 19b aus).
@export var draw_fill := false
## Deckkraft der Flaeche (0 = unsichtbar, 1 = voll deckend).
@export_range(0.0, 1.0, 0.01) var fill_alpha: float = 0.12
## Deckkraft des Randes.
@export_range(0.0, 1.0, 0.01) var outline_alpha: float = 0.7
## Deckkraft des Randes auf Stufe "normal" (Blase faktisch aus, nur angedeutet).
@export_range(0.0, 1.0, 0.01) var outline_alpha_normal: float = 0.25

@export_group("Shader (Linse)")
## Verzerrung und Farbverschiebung innerhalb der Blase an/aus.
@export var lens_enabled := true
## Auslenkung des Wobble (Pixel) auf langsam bzw. schnell.
@export_range(0.0, 8.0, 0.1) var wobble_strength: float = 1.5
## Groesse der Wellen (groesser = kleinere, dichtere Wellen).
@export_range(0.01, 0.5, 0.005) var wobble_scale: float = 0.08
## Farbverschiebung (Pixel) auf langsam bzw. schnell.
@export_range(0.0, 6.0, 0.1) var aberration: float = 1.0
## Anteil der Staerke auf Stufe "normal" (0 = unsichtbar, kaum sichtbar = 0.2).
@export_range(0.0, 1.0, 0.05) var lens_strength_normal: float = 0.2
## Tempo der Welle je Stufe (Bogenmass pro Sekunde): traege, ruhig, hektisch.
@export var wobble_speed_slow: float = 1.2
@export var wobble_speed_normal: float = 2.0
@export var wobble_speed_fast: float = 9.0
