class_name GameFeelSettings
extends Resource
## Einstellungen fuer das Spielgefuehl (Doku 2.2, Schritt 25): Squash und
## Stretch, Staub, Kamerawackeln, Hitstop, Blick in Laufrichtung. Werte in
## data/game_feel.tres, im Inspector aenderbar.

@export_group("Squash und Stretch")
## Streckung beim Absprung (x schmaler, y hoeher).
@export var jump_stretch := Vector2(0.82, 1.18)
## Groesste Stauchung beim Landen (bei voller Fallgeschwindigkeit).
@export var land_squash := Vector2(1.28, 0.72)
## So lange federt die Figur in die Grundform zurueck (Sekunden).
@export_range(0.02, 1.0, 0.01) var return_time := 0.2
## Ab dieser Fallgeschwindigkeit gibt es ueberhaupt eine Stauchung (px/s).
@export var land_squash_min_speed := 150.0

@export_group("Gewicht")
## Harte Landung ab dieser Fallgeschwindigkeit (px/s): bremst kurz und
## erschuettert den Boden.
@export var hard_landing_speed := 700.0
## Laufgeschwindigkeit direkt nach einer harten Landung (Anteil) und wie
## lange es dauert, bis sie wieder voll ist (Sekunden).
@export_range(0.0, 1.0, 0.05) var hard_landing_speed_factor := 0.45
@export_range(0.0, 1.0, 0.01) var hard_landing_recover_time := 0.18

@export_group("Kamera")
## Staerkstes Wackeln beim Landen (Pixel, bei maximaler Fallgeschwindigkeit).
@export var land_shake := 5.0
## Dauer eines Wackelns (Sekunden).
@export_range(0.02, 1.0, 0.01) var shake_time := 0.22
## Wackeln beim Tod und beim Einsammeln (Pixel).
@export var death_shake := 7.0
@export var pickup_shake := 2.5
## Blick in Laufrichtung (Pixel) und wie schnell die Kamera folgt.
@export var look_ahead := 40.0
@export var look_ahead_speed := 2.5
## Zoom-Impuls beim Umschalten der Zeitstufe (Anteil, 0 = aus).
@export_range(0.0, 0.2, 0.005) var stage_zoom_punch := 0.04

@export_group("Hitstop")
## Kurzes Einfrieren (echte Sekunden) beim Tod und beim Einsammeln.
@export_range(0.0, 0.5, 0.01) var death_hitstop := 0.09
@export_range(0.0, 0.5, 0.01) var pickup_hitstop := 0.05

@export_group("Staub")
## Woelkchen beim Absprung, beim Landen (bis zu, je nach Fallhoehe) und beim
## Richtungswechsel.
@export var jump_dust := 4
@export var land_dust := 10
@export var turn_dust := 3
