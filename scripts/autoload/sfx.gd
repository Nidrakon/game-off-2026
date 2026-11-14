extends Node
## Soundeffekte (Doku 1.7, Schritt 24), globales System (Autoload "Sfx").
## Kennungen, Dateien, Lautstaerken und Tonhoehen-Streuung stehen in
## data/sfx.json (Dateien in audio/sfx/, erzeugt mit tools/make_sfx.py).
##
## - play(id): Sound ohne Ort (Oberflaeche, Spielfigur).
## - play_at(id, position): Sound an einem Ort in der Welt (leiser mit Abstand).
## - loop(id, parent, time_source): Dauerton an einem Objekt; seine Tonhoehe
##   folgt dem Zeittempo (TimeAffected) - in der Blase tiefer bzw. hoeher.
## - play_ambient(id): Umgebungsgeraeusch (Schleife, Bus "Ambient"),
##   ueberblendet; stop_ambient() blendet aus.
## Busse: SFX, Ambient, Music (default_bus_layout.tres).

const TABLE_FILE := "res://data/sfx.json"
## Gleichzeitige Sounds ohne Ort.
const POOL_SIZE := 12
## Reichweite verorteter Sounds (Pixel) und wie schnell sie leiser werden.
const MAX_DISTANCE := 900.0
const ATTENUATION := 1.6
## Ueberblendung der Umgebung (Sekunden).
const AMBIENT_FADE := 1.2

var _table := {}
var _streams := {}
var _pool: Array[AudioStreamPlayer] = []
var _next := 0
var _ambient: AudioStreamPlayer
var _ambient_id := ""


## Dauerton an einem Objekt; Tonhoehe folgt dem Zeittempo.
class LoopSound extends AudioStreamPlayer2D:
	var time_source: TimeAffected
	var base_pitch := 1.0

	func _process(_delta: float) -> void:
		if time_source and is_instance_valid(time_source):
			pitch_scale = clampf(base_pitch * time_source.time_scale, 0.25, 3.0)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(TABLE_FILE))
	_table = data if data is Dictionary else {}
	for i in POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.bus = &"SFX"
		add_child(player)
		_pool.append(player)
	_ambient = AudioStreamPlayer.new()
	_ambient.bus = &"Ambient"
	add_child(_ambient)


## Gibt es den Sound?
func has(id: String) -> bool:
	return _table.has(id)


## Sound ohne Ort. "volume_db" kommt zur Lautstaerke aus der Tabelle dazu.
func play(id: String, volume_db := 0.0, pitch := 1.0) -> void:
	var entry: Dictionary = _table.get(id, {})
	var stream := _pick(id)
	if stream == null:
		return
	var player := _pool[_next]
	_next = (_next + 1) % POOL_SIZE
	player.stream = stream
	player.bus = StringName(entry.get("bus", "SFX"))
	player.volume_db = float(entry.get("volume_db", 0.0)) + volume_db
	player.pitch_scale = pitch * _pitch_variation(entry)
	player.play()


## Sound an einem Ort in der Welt (aktuelle Szene).
func play_at(id: String, position: Vector2, volume_db := 0.0, pitch := 1.0) -> void:
	var entry: Dictionary = _table.get(id, {})
	var stream := _pick(id)
	var scene := get_tree().current_scene
	if stream == null or scene == null:
		return
	var player := AudioStreamPlayer2D.new()
	player.stream = stream
	player.bus = StringName(entry.get("bus", "SFX"))
	player.volume_db = float(entry.get("volume_db", 0.0)) + volume_db
	player.pitch_scale = pitch * _pitch_variation(entry)
	player.max_distance = MAX_DISTANCE
	player.attenuation = ATTENUATION
	player.global_position = position
	scene.add_child(player)
	player.finished.connect(player.queue_free)
	player.play()


## Dauerton als Kind von "parent" (spielt sofort). Tonhoehe folgt
## "time_source" (oder bleibt fest, wenn null).
func loop(id: String, parent: Node, time_source: TimeAffected = null, volume_db := 0.0) -> AudioStreamPlayer2D:
	var entry: Dictionary = _table.get(id, {})
	var player := LoopSound.new()
	player.stream = _pick(id)
	player.bus = StringName(entry.get("bus", "SFX"))
	player.volume_db = float(entry.get("volume_db", 0.0)) + volume_db
	player.max_distance = MAX_DISTANCE
	player.attenuation = ATTENUATION
	player.time_source = time_source
	player.autoplay = true
	parent.add_child(player)
	return player


## Umgebungsgeraeusch (Schleife) mit Ueberblendung; gleiche Kennung = nichts tun.
func play_ambient(id: String) -> void:
	if id == _ambient_id and _ambient.playing:
		return
	_ambient_id = id
	var stream := _pick(id)
	if stream == null:
		stop_ambient()
		return
	var target := float(_table.get(id, {}).get("volume_db", 0.0))
	var tween := create_tween()
	if _ambient.playing:
		tween.tween_property(_ambient, "volume_db", -40.0, AMBIENT_FADE * 0.5)
	tween.tween_callback(func() -> void:
		_ambient.stream = stream
		_ambient.volume_db = -40.0
		_ambient.play())
	tween.tween_property(_ambient, "volume_db", target, AMBIENT_FADE)


## Umgebung ausblenden.
func stop_ambient() -> void:
	_ambient_id = ""
	if not _ambient.playing:
		return
	var tween := create_tween()
	tween.tween_property(_ambient, "volume_db", -40.0, AMBIENT_FADE * 0.5)
	tween.tween_callback(_ambient.stop)


## Kennung der laufenden Umgebung (fuer Tests).
func get_ambient_id() -> String:
	return _ambient_id


func _pitch_variation(entry: Dictionary) -> float:
	var spread := float(entry.get("pitch_var", 0.0))
	return 1.0 + randf_range(-spread, spread)


## Stream zur Kennung; bei mehreren Dateien eine zufaellige (z. B. Schritte).
func _pick(id: String) -> AudioStream:
	var entry: Dictionary = _table.get(id, {})
	var files: Array = entry.get("files", [])
	if files.is_empty():
		return null
	var file: String = files[randi() % files.size()]
	if not _streams.has(file):
		var stream := load("res://audio/sfx/%s.wav" % file) as AudioStreamWAV
		if stream and entry.get("loop", false):
			stream = stream.duplicate()
			stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			stream.loop_begin = 0
			stream.loop_end = int(stream.get_length() * stream.mix_rate)
		_streams[file] = stream
	return _streams[file]
