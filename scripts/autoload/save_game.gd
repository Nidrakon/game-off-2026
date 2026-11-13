extends Node
## Spielstand (Doku 2.7), globales System (Autoload "SaveGame"). Die einzige
## Stelle im Code, die speichert und laedt.
##
## - Ein Spielstand als JSON-Datei in user:// (im Browser speichert Godot
##   user:// dauerhaft im Browser-Speicher).
## - Gespeichert wird automatisch zu Beginn jedes Levels aus der
##   Levelreihenfolge (Level-Vorlage meldet sich hier).
## - Inhalt: Versionsnummer, erreichtes Level (Kennung), freigeschaltete
##   Upgrades, Fortschrittsmarken (Story Flags).
## - Fehlt die Datei oder ist sie beschaedigt, gibt es keinen Spielstand
##   (Continue ausgegraut); eine beschaedigte Datei wird als .bak beiseite
##   gelegt.
## - Testmodus (Entwickler-Menue, Doku 1.9): Nach dem Laden eines
##   Test-Szenarios wird in eine eigene Testdatei gespeichert, der echte
##   Spielstand bleibt unberuehrt.

## Wird gesendet, nachdem gespeichert wurde.
signal saved

## Aktuelle Version des Spielstand-Formats. Bei Aenderungen erhoehen und in
## _upgrade_data() alte Staende umwandeln.
const VERSION := 1
const SAVE_PATH := "user://savegame.json"
const TEST_SAVE_PATH := "user://savegame_test.json"

## Testmodus: speichert in die Testdatei.
var test_mode := false

## Kennung des zuletzt erreichten Levels (leer = noch keins).
var current_level := ""
## Nummer des aktuellen Klons (Doku 2.6): beginnt bei 1, jeder Tod zaehlt hoch.
var clone_number := 1
# Ist der Professor seit dem letzten Erscheinen gestorben? (Respawn-Spruch)
var _respawn_pending := false
var _flags := {}


## Datei, in die gerade gespeichert wird.
func get_save_path() -> String:
	return TEST_SAVE_PATH if test_mode else SAVE_PATH


## Gibt es einen gueltigen (echten) Spielstand? Fuer den Titelbildschirm.
func has_save() -> bool:
	return not _read(SAVE_PATH).is_empty()


## Fortschrittsmarke setzen (z. B. "story_keycard_seen").
func set_flag(id: String) -> void:
	_flags[id] = true


## Ist die Fortschrittsmarke gesetzt?
func has_flag(id: String) -> bool:
	return _flags.has(id)


## Aktueller Stand als Daten (so, wie er gespeichert wird).
func get_data() -> Dictionary:
	return {
		"version": VERSION,
		"level": current_level,
		"upgrades": Array(Upgrades.get_ids()),
		"flags": _flags.keys(),
		"clone": clone_number,
	}


## Stand aus Daten uebernehmen (Spielstand oder Test-Szenario).
func apply_data(data: Dictionary) -> void:
	current_level = str(data.get("level", ""))
	clone_number = maxi(1, int(data.get("clone", 1)))
	_respawn_pending = false
	Upgrades.set_ids(PackedStringArray(data.get("upgrades", [])))
	_flags.clear()
	for flag in data.get("flags", []):
		_flags[str(flag)] = true


## Speichert den aktuellen Stand.
func save_game() -> void:
	var path := get_save_path()
	# Erst in eine Zwischendatei schreiben, dann umbenennen: Bricht das
	# Schreiben ab, bleibt der alte Spielstand heil.
	var temp := path + ".tmp"
	var file := FileAccess.open(temp, FileAccess.WRITE)
	if file == null:
		push_warning("Spielstand: kann nicht schreiben (%s)" % error_string(FileAccess.get_open_error()))
		return
	file.store_string(JSON.stringify(get_data(), "\t"))
	file.close()
	DirAccess.rename_absolute(temp, path)
	saved.emit()


## Neues Spiel: alles zuruecksetzen (der alte Spielstand wird beim ersten
## Level ueberschrieben) und das erste Level starten.
func new_game() -> void:
	test_mode = false
	apply_data({})
	LevelFlow.start_game()


## Weiterspielen: Spielstand laden und am Anfang des erreichten Levels
## starten. Gibt false zurueck, wenn es keinen gueltigen Spielstand gibt.
func continue_game() -> bool:
	test_mode = false
	var data := _read(SAVE_PATH)
	if data.is_empty():
		return false
	apply_data(data)
	LevelFlow.go_to(_level_path(current_level))
	return true


## Der Professor ist gestorben: naechster Klon (Respawn-Spruch folgt).
func register_death() -> void:
	clone_number += 1
	_respawn_pending = true


## Fuer den Respawn-Spruch: Ist er seit dem letzten Erscheinen gestorben?
## Setzt die Marke zurueck.
func take_respawn_pending() -> bool:
	var pending := _respawn_pending
	_respawn_pending = false
	return pending


## Vom Level aufgerufen (Level-Vorlage), sobald es startet. Nur Level aus der
## Reihenfolge zaehlen als Fortschritt.
func on_level_started(scene_path: String) -> void:
	if LevelFlow.index_of(scene_path) < 0:
		return
	current_level = LevelFlow.get_level_id(scene_path)
	save_game()


## Szene zur Level-Kennung; unbekannt = erstes Level.
func _level_path(level_id: String) -> String:
	for path in LevelFlow.get_levels():
		if LevelFlow.get_level_id(path) == level_id:
			return path
	var levels := LevelFlow.get_levels()
	return levels[0] if not levels.is_empty() else LevelFlow.END_SCENE


## Liest einen Spielstand; leer bei fehlender oder beschaedigter Datei.
func _read(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (data is Dictionary) or not data.has("version") or int(data.version) > VERSION:
		push_warning("Spielstand beschaedigt oder zu neu, wird beiseite gelegt: " + path)
		DirAccess.rename_absolute(path, path + ".bak")
		return {}
	return _upgrade_data(data)


## Wandelt aeltere Spielstaende ins aktuelle Format um (bisher nur Version 1).
func _upgrade_data(data: Dictionary) -> Dictionary:
	return data
