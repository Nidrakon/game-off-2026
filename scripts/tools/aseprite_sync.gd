@tool
class_name AsepriteSync
extends RefCounted
## Gemeinsamer Baustein fuer den Aseprite-Sync (Doku 1.8):
## - exportiert eine Aseprite-Datei als Sprite-Sheet (PNG) plus Daten (JSON),
## - baut daraus SpriteFrames (jeder Tag = eine Animation, Bilddauern wie in
##   Aseprite).
## Genutzt vom Editor-Plugin (addons/aseprite_sync) und vom Live-Nachladen im
## laufenden Spiel (scripts/dev/sprite_hot_reload.gd).

## Liste der Dateien, die synchronisiert werden.
const CONFIG_PATH := "res://data/aseprite_sync.cfg"
## Optionale lokale Datei (nicht im Repo): ueberschreibt "source" je Eintrag,
## z. B. mit dem Pfad der eigenen Arbeitsdatei ausserhalb des Projekts.
const LOCAL_CONFIG_PATH := "res://data/aseprite_sync.local.cfg"
## Grundtempo der Animationen. Eine Bilddauer von 100 ms entspricht 1,0.
const BASE_FPS := 10.0


## Liest die Eintraege aus data/aseprite_sync.cfg (plus lokale Ueberschreibung).
## Jeder Eintrag: { name, source, project_source, sheet, data, frames, play_once }.
## "source" ist die Datei, in der gezeichnet wird; "project_source" die Kopie
## im Projekt (gleich, wenn es keine lokale Ueberschreibung gibt).
static func load_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	var config := ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		return entries
	var local := ConfigFile.new()
	var has_local := local.load(LOCAL_CONFIG_PATH) == OK
	for section in config.get_sections():
		var sheet: String = config.get_value(section, "sheet", "")
		var project_source: String = config.get_value(section, "source", "")
		var source := project_source
		if has_local and local.has_section_key(section, "source"):
			source = local.get_value(section, "source")
		entries.append({
			"name": section,
			"source": source,
			"project_source": project_source,
			"sheet": sheet,
			"data": sheet.get_basename() + ".json",
			"frames": config.get_value(section, "frames", ""),
			"play_once": config.get_value(section, "play_once", PackedStringArray()),
		})
	return entries


## Zeitpunkt der letzten Aenderung einer Datei (0, wenn es sie nicht gibt).
static func modified_time(path: String) -> int:
	var file := ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(file):
		return 0
	return FileAccess.get_modified_time(file)


## Exportiert Sheet und Daten mit dem Aseprite-Kommandozeilenmodus.
## Ausgeblendete Ebenen (Hilfsebenen) kommen dabei nicht mit ins Bild.
static func export_sheet(aseprite_exe: String, entry: Dictionary) -> Error:
	var args := PackedStringArray([
		"-b", ProjectSettings.globalize_path(entry.source),
		"--sheet", ProjectSettings.globalize_path(entry.sheet),
		"--sheet-type", "horizontal",
		"--data", ProjectSettings.globalize_path(entry.data),
		"--format", "json-array",
		"--list-tags",
	])
	var output := []
	var code := OS.execute(aseprite_exe, args, output, true)
	if code != 0:
		push_error("Aseprite-Sync: Export von %s fehlgeschlagen (%d): %s" % [entry.source, code, "".join(output)])
		return FAILED
	return OK


## Liest die exportierte JSON-Datei.
static func read_data(entry: Dictionary) -> Dictionary:
	var text := FileAccess.get_file_as_string(ProjectSettings.globalize_path(entry.data))
	var data = JSON.parse_string(text)
	return data if data is Dictionary else {}


## Kopiert die Arbeitsdatei ins Projekt, falls sie ausserhalb liegt (lokale
## Ueberschreibung). So hat das Repo immer den aktuellen Stand.
static func copy_source_to_project(entry: Dictionary) -> void:
	if entry.source == entry.project_source:
		return
	DirAccess.copy_absolute(ProjectSettings.globalize_path(entry.source), ProjectSettings.globalize_path(entry.project_source))


## Fuellt "frames" neu aus Sheet-Textur und JSON-Daten. Vorhandene
## Animationen werden ersetzt. Ohne Tags entsteht eine Animation "default".
## Animationen in "play_once" (oder Tags mit "Repeat" in Aseprite) laufen
## einmal und bleiben dann auf dem letzten Bild stehen; alle anderen laufen
## in Schleife.
static func fill_frames(frames: SpriteFrames, texture: Texture2D, data: Dictionary, play_once := PackedStringArray()) -> void:
	var images: Array = data.get("frames", [])
	var tags: Array = data.get("meta", {}).get("frameTags", [])
	if tags.is_empty():
		tags = [{"name": "default", "from": 0, "to": images.size() - 1, "direction": "forward"}]
	var names: Array[StringName] = []
	for tag in tags:
		names.append(StringName(String(tag.name).to_lower()))
	for i in tags.size():
		var anim := names[i]
		if frames.has_animation(anim):
			frames.clear(anim)
		else:
			frames.add_animation(anim)
		var once: bool = play_once.has(String(anim)) or tags[i].has("repeat")
		frames.set_animation_loop(anim, not once)
		frames.set_animation_speed(anim, BASE_FPS)
		for index in _frame_order(tags[i]):
			var image: Dictionary = images[index]
			var region: Dictionary = image.frame
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(region.x, region.y, region.w, region.h)
			# Aseprite: Millisekunden; SpriteFrames: Vielfaches von 1 / BASE_FPS.
			frames.add_frame(anim, atlas, float(image.duration) * BASE_FPS / 1000.0)
	# Animationen entfernen, zu denen es keinen Tag mehr gibt (auch "default").
	for old in frames.get_animation_names():
		if not names.has(StringName(old)):
			frames.remove_animation(old)


## Bildreihenfolge eines Tags (vorwaerts, rueckwaerts oder hin und zurueck).
static func _frame_order(tag: Dictionary) -> Array[int]:
	var order: Array[int] = []
	for i in range(int(tag.from), int(tag.to) + 1):
		order.append(i)
	match String(tag.get("direction", "forward")):
		"reverse":
			order.reverse()
		"pingpong":
			for i in range(int(tag.to) - 1, int(tag.from), -1):
				order.append(i)
	return order
