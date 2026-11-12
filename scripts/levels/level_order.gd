class_name LevelOrder
extends Resource
## Reihenfolge der Level im Spiel (Doku 2.9). Die Datei liegt in
## data/level_order.tres und wird im Inspector bearbeitet: Level hinzufuegen,
## entfernen oder verschieben. Der Ausgang eines Levels fuehrt zum naechsten
## Eintrag, nach dem letzten kommt der (vorlaeufige) Endbildschirm.
## Kennung eines Levels (z. B. fuer den Spielstand) ist sein Dateiname ohne
## Endung; Dateien deshalb nach dem Anlegen nicht mehr umbenennen.

## Szenen der Level, in Spielreihenfolge.
@export_file("*.tscn") var levels: Array[String] = []
