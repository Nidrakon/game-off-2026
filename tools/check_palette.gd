extends SceneTree
## Prueft alle PNG-Dateien unter graphics/ auf Farben ausserhalb der Palette
## Resurrect 64 (graphics/palettes/resurrect_64.hex).
## Voll transparente Pixel werden ignoriert, halbtransparente gemeldet.
##
## Aufruf aus dem Projektordner (Konsolenfassung von Godot):
##   godot --headless --path . --script tools/check_palette.gd
## Rueckgabewert 0 = alles in Ordnung, 1 = Abweichungen gefunden.

const PALETTE_PATH := "res://graphics/palettes/resurrect_64.hex"
const GRAPHICS_DIR := "res://graphics"
const MAX_REPORTS_PER_FILE := 10


func _init() -> void:
	var palette := _load_palette()
	var files := _find_png_files(GRAPHICS_DIR)
	var problem_count := 0
	for path in files:
		problem_count += _check_file(path, palette)
	print("Geprueft: %d Datei(en), Palette mit %d Farben." % [files.size(), palette.size()])
	if problem_count == 0:
		print("OK: alle Farben stammen aus der Palette.")
	else:
		print("FEHLER: %d Datei(en) mit Farben ausserhalb der Palette." % problem_count)
	quit(1 if problem_count > 0 else 0)


## Liest die Palette als Menge von Hex-Strings ("2e222f").
func _load_palette() -> Dictionary:
	var palette := {}
	var file := FileAccess.open(PALETTE_PATH, FileAccess.READ)
	while not file.eof_reached():
		var line := file.get_line().strip_edges().to_lower()
		if line.length() == 6:
			palette[line] = true
	return palette


## Sucht rekursiv alle PNG-Dateien.
func _find_png_files(dir_path: String) -> Array[String]:
	var result: Array[String] = []
	for sub_dir in DirAccess.get_directories_at(dir_path):
		result.append_array(_find_png_files(dir_path.path_join(sub_dir)))
	for file_name in DirAccess.get_files_at(dir_path):
		if file_name.get_extension().to_lower() == "png":
			result.append(dir_path.path_join(file_name))
	return result


## Gibt 1 zurueck, wenn die Datei fremde Farben enthaelt, sonst 0.
func _check_file(path: String, palette: Dictionary) -> int:
	# Direkt von der Platte laden (nicht ueber den Import), damit die
	# Originalpixel geprueft werden.
	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	if image == null:
		print("FEHLER: %s konnte nicht geladen werden." % path)
		return 1
	image.convert(Image.FORMAT_RGBA8)
	var reports := 0
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			if color.a8 == 0:
				continue
			var hex := color.to_html(false).to_lower()
			if color.a8 < 255 or not palette.has(hex):
				if reports < MAX_REPORTS_PER_FILE:
					print("  %s (%d, %d): #%s Alpha %d" % [path, x, y, hex, color.a8])
				reports += 1
	if reports > 0:
		print("FEHLER: %s hat %d Pixel ausserhalb der Palette." % [path, reports])
		return 1
	return 0
