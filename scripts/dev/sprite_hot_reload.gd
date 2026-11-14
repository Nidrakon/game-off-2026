extends Node
## Live-Nachladen von Sprites im laufenden Spiel (nur Debug-Start aus dem
## Editor, wird vom DevMenu angelegt). Sobald das Editor-Plugin "Aseprite
## Sync" eine Aseprite-Datei neu exportiert hat, liest dieser Node Sheet und
## Daten direkt von der Festplatte und tauscht die Animationen aller Figuren
## aus, die diese SpriteFrames benutzen. So sieht man Aenderungen aus Aseprite
## ohne Neustart.

## Wie oft auf einen neuen Export geprueft wird (Sekunden).
const CHECK_INTERVAL := 0.5
## Merker an einer Figur: welche SpriteFrames-Datei sie urspruenglich benutzt.
const META_SOURCE := &"aseprite_frames_path"

var _entries: Array[Dictionary] = []
# Letzte bekannte Aenderungszeit der Daten-Datei je Eintrag.
var _data_times := {}
# Neu gebaute SpriteFrames je SpriteFrames-Pfad (gilt auch fuer spaeter
# erscheinende Figuren, z. B. nach einem Level-Neustart).
var _overrides := {}
var _check_left := CHECK_INTERVAL


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_entries = AsepriteSync.load_entries()
	for entry in _entries:
		_data_times[entry.data] = AsepriteSync.modified_time(entry.data)
	get_tree().node_added.connect(_on_node_added)


func _process(delta: float) -> void:
	_check_left -= delta
	if _check_left > 0.0:
		return
	_check_left = CHECK_INTERVAL
	for entry in _entries:
		var time := AsepriteSync.modified_time(entry.data)
		if time != _data_times[entry.data]:
			_data_times[entry.data] = time
			_reload(entry)


func _reload(entry: Dictionary) -> void:
	# Nur Sheet ohne SpriteFrames (z. B. Comic-Panels): nichts zu ersetzen.
	if entry.frames == "":
		return
	# Direkt von der Festplatte lesen: Der importierte Stand im Spiel ist alt.
	var image := Image.load_from_file(ProjectSettings.globalize_path(entry.sheet))
	if image == null or image.is_empty():
		return
	var frames := SpriteFrames.new()
	AsepriteSync.fill_frames(frames, ImageTexture.create_from_image(image), AsepriteSync.read_data(entry), entry.play_once)
	_overrides[entry.frames] = frames
	for node in get_tree().root.find_children("*", "AnimatedSprite2D", true, false):
		_apply_if_matching(node)
	print("Sprite neu geladen: ", entry.name)


func _on_node_added(node: Node) -> void:
	if node is AnimatedSprite2D:
		_apply_if_matching(node)


func _apply_if_matching(sprite: AnimatedSprite2D) -> void:
	if sprite.sprite_frames == null:
		return
	var path: String = sprite.get_meta(META_SOURCE, sprite.sprite_frames.resource_path)
	if not _overrides.has(path):
		return
	var frames: SpriteFrames = _overrides[path]
	if sprite.sprite_frames == frames:
		return
	sprite.set_meta(META_SOURCE, path)
	var animation := sprite.animation
	var was_playing := sprite.is_playing()
	sprite.sprite_frames = frames
	if frames.has_animation(animation):
		sprite.animation = animation
		if was_playing:
			sprite.play(animation)
