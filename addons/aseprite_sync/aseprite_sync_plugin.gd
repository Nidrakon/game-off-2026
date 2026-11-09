@tool
extends EditorPlugin
## Aseprite-Sync (Doku 1.8): Beobachtet die Aseprite-Dateien aus
## data/aseprite_sync.cfg. Wird eine davon gespeichert, exportiert das Plugin
## Sprite-Sheet und Daten und baut die SpriteFrames neu. Ein laufendes Spiel
## (Debug-Start aus dem Editor) laedt das Ergebnis sofort nach.
##
## Der Pfad zu Aseprite steht in den Editor-Einstellungen unter
## "aseprite_sync/aseprite_path" (lokal auf dem Rechner, nicht im Repo).
## Ist er leer, sucht das Plugin an den ueblichen Installationsorten.
## Von Hand ausloesen: Projekt > Werkzeuge > "Aseprite: Sync now".

const SETTING := "aseprite_sync/aseprite_path"
const MENU_ITEM := "Aseprite: Sync now"
## Wie oft auf gespeicherte Aenderungen geprueft wird (Sekunden).
const CHECK_INTERVAL := 1.0

var _timer: Timer
# Letzte bekannte Aenderungszeit je Aseprite-Datei.
var _known_times := {}
var _warned_missing_exe := false


func _enter_tree() -> void:
	_ensure_setting()
	add_tool_menu_item(MENU_ITEM, _sync_all)
	_timer = Timer.new()
	_timer.wait_time = CHECK_INTERVAL
	_timer.timeout.connect(_check_for_changes)
	add_child(_timer)
	_timer.start()


func _exit_tree() -> void:
	remove_tool_menu_item(MENU_ITEM)
	if _timer:
		_timer.queue_free()


## Exportiert alle Eintraege, egal ob geaendert.
func _sync_all() -> void:
	for entry in AsepriteSync.load_entries():
		_sync(entry)


func _check_for_changes() -> void:
	for entry in AsepriteSync.load_entries():
		var source_time := AsepriteSync.modified_time(entry.source)
		if source_time == 0:
			continue
		var known: int = _known_times.get(entry.source, -1)
		if known == -1:
			# Erster Blick auf die Datei: nur exportieren, wenn sie neuer ist
			# als der letzte Export.
			_known_times[entry.source] = source_time
			if source_time > AsepriteSync.modified_time(entry.data):
				_sync(entry)
		elif source_time != known:
			_known_times[entry.source] = source_time
			_sync(entry)


func _sync(entry: Dictionary) -> void:
	var exe := _aseprite_path()
	if exe.is_empty():
		if not _warned_missing_exe:
			_warned_missing_exe = true
			push_warning("Aseprite-Sync: Aseprite nicht gefunden. Pfad in Editor > Editor-Einstellungen > %s eintragen." % SETTING)
		return
	if AsepriteSync.export_sheet(exe, entry) != OK:
		return
	AsepriteSync.copy_source_to_project(entry)
	# Neues Sheet einlesen lassen, bevor die SpriteFrames darauf verweisen.
	var filesystem := EditorInterface.get_resource_filesystem()
	if ResourceLoader.exists(entry.sheet):
		filesystem.reimport_files(PackedStringArray([entry.sheet]))
	else:
		filesystem.update_file(entry.sheet)
		filesystem.reimport_files(PackedStringArray([entry.sheet]))
	var texture := load(entry.sheet) as Texture2D
	if texture == null:
		push_error("Aseprite-Sync: Sheet %s konnte nicht geladen werden." % entry.sheet)
		return
	# Vorhandene SpriteFrames direkt aendern: Offene Szenen zeigen das sofort.
	var frames: SpriteFrames
	if ResourceLoader.exists(entry.frames):
		frames = load(entry.frames) as SpriteFrames
	if frames == null:
		frames = SpriteFrames.new()
	AsepriteSync.fill_frames(frames, texture, AsepriteSync.read_data(entry), entry.play_once)
	ResourceSaver.save(frames, entry.frames)
	filesystem.update_file(entry.frames)
	print("Aseprite-Sync: %s aktualisiert (%s)." % [entry.name, ", ".join(frames.get_animation_names())])


## Pfad zu Aseprite aus den Editor-Einstellungen; leer, wenn nicht vorhanden.
func _aseprite_path() -> String:
	var path: String = EditorInterface.get_editor_settings().get_setting(SETTING)
	return path if FileAccess.file_exists(path) else ""


## Legt die Editor-Einstellung an und sucht Aseprite, falls sie leer ist.
func _ensure_setting() -> void:
	var settings := EditorInterface.get_editor_settings()
	if not settings.has_setting(SETTING):
		settings.set_setting(SETTING, "")
	settings.add_property_info({
		"name": SETTING,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_GLOBAL_FILE,
		"hint_string": "*.exe",
	})
	if FileAccess.file_exists(settings.get_setting(SETTING)):
		return
	# Uebliche Installationsorte (Windows-Installer und Steam).
	var candidates := []
	for root in [OS.get_environment("ProgramFiles"), OS.get_environment("ProgramFiles(x86)")]:
		if root.is_empty():
			continue
		candidates.append(root.path_join("Aseprite/Aseprite.exe"))
		candidates.append(root.path_join("Steam/steamapps/common/Aseprite/Aseprite.exe"))
	for candidate in candidates:
		if FileAccess.file_exists(candidate):
			settings.set_setting(SETTING, candidate)
			print("Aseprite-Sync: Aseprite gefunden.")
			return
