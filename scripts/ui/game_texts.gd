class_name GameTexts
extends RefCounted
## Liest Spieltexte aus den Dateien in dialogues/ (Doku 1.6: Texte englisch,
## Kennungen <bereich>_<was>). Jede Datei wird nur einmal gelesen.
## Fehlt eine Kennung, kommt die Kennung selbst zurueck (faellt beim Testen
## sofort auf).

static var _cache := {}


## Text zur Kennung aus dialogues/<file>.json, z. B. get_text("hints", "hint_move").
static func get_text(file: String, id: String) -> String:
	if not _cache.has(file):
		var data: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://dialogues/%s.json" % file))
		_cache[file] = data if data is Dictionary else {}
	return str(_cache[file].get(id, id))


## Zwischenspeicher leeren (z. B. nachdem eine Textdatei geaendert wurde).
static func clear_cache() -> void:
	_cache.clear()
