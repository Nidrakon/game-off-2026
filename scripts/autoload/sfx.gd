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
## Songs mit fester ID (Doku 1.7): ID -> Name, Datei (audio/music/), Lautstaerke.
const MUSIC_FILE := "res://data/music.json"
## Ueberblendzeit zwischen Songs (Sekunden).
const MUSIC_FADE := 1.5
## Gedaempfte Musik (Spielmenue, Bedienfeld): Grenzfrequenz und Blendzeit.
const MUFFLED_CUTOFF := 700.0
const OPEN_CUTOFF := 20000.0
const MUFFLE_TIME := 0.25
## Gleichzeitige Sounds ohne Ort.
const POOL_SIZE := 12
## Reichweite verorteter Sounds (Pixel) und wie schnell sie leiser werden.
const MAX_DISTANCE := 900.0
const ATTENUATION := 1.6
## Ueberblendung der Umgebung (Sekunden).
const AMBIENT_FADE := 1.2
## Lautstaerke-Einstellungen (Spielmenue, Doku 2.5): eigene Datei, nicht im
## Spielstand. Tests schreiben in eine eigene Datei.
const SETTINGS_PATH := "user://settings.cfg"
const TEST_SETTINGS_PATH := "user://settings_test.cfg"
## Busse, die im Spielmenue einstellbar sind, und ihre Voreinstellung (0 bis 1).
## Gesamtlautstaerke startet bewusst leise.
const VOLUME_DEFAULTS := {"Master": 0.5, "SFX": 1.0, "Ambient": 1.0, "Music": 1.0}

var _table := {}
var _streams := {}
var _pool: Array[AudioStreamPlayer] = []
var _next := 0
var _ambient: AudioStreamPlayer
var _ambient_id := ""
var _music_table := {}
var _music: Array[AudioStreamPlayer] = []
var _music_active := 0
var _music_id := 0
var _lowpass: AudioEffectLowPassFilter
var _muffle_tween: Tween
var _music_tween: Tween


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
	var music_data: Variant = JSON.parse_string(FileAccess.get_file_as_string(MUSIC_FILE))
	_music_table = music_data if music_data is Dictionary else {}
	for i in 2:
		var player := AudioStreamPlayer.new()
		player.bus = &"Music"
		add_child(player)
		_music.append(player)
	_setup_lowpass()
	load_volumes()


## Lautstaerke eines Busses (0 bis 1, linear).
func get_volume(bus: String) -> float:
	var index := AudioServer.get_bus_index(bus)
	if index < 0 or AudioServer.is_bus_mute(index):
		return 0.0
	return clampf(db_to_linear(AudioServer.get_bus_volume_db(index)), 0.0, 1.0)


## Lautstaerke setzen (0 bis 1); "store" = gleich in die Einstellungen schreiben.
func set_volume(bus: String, value: float, store := true) -> void:
	var index := AudioServer.get_bus_index(bus)
	if index < 0:
		return
	value = clampf(value, 0.0, 1.0)
	AudioServer.set_bus_mute(index, value <= 0.001)
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(value, 0.001)))
	if store:
		save_volumes()


## Einstellungen laden (fehlt die Datei: Voreinstellungen).
func load_volumes() -> void:
	var config := ConfigFile.new()
	config.load(_settings_path())
	for bus in VOLUME_DEFAULTS:
		set_volume(bus, float(config.get_value("volume", bus, VOLUME_DEFAULTS[bus])), false)


func save_volumes() -> void:
	var config := ConfigFile.new()
	config.load(_settings_path())
	for bus in VOLUME_DEFAULTS:
		config.set_value("volume", bus, snappedf(get_volume(bus), 0.01))
	config.save(_settings_path())


func _settings_path() -> String:
	var save_game := get_node_or_null("/root/SaveGame")
	return TEST_SETTINGS_PATH if save_game and save_game.test_mode else SETTINGS_PATH


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


## Song mit fester ID spielen (Schleife, Ueberblendung). Gleicher Song laeuft
## einfach weiter; 0 = Musik aus.
func play_music(id: int) -> void:
	if id == _music_id and _music[_music_active].playing:
		return
	if id <= 0 or not _music_table.has(str(id)):
		stop_music()
		return
	var entry: Dictionary = _music_table[str(id)]
	var stream := load("res://audio/music/%s.ogg" % entry.get("file", "")) as AudioStreamOggVorbis
	if stream == null:
		stop_music()
		return
	stream.loop = true
	_music_id = id
	var old := _music[_music_active]
	_music_active = 1 - _music_active
	var player := _music[_music_active]
	player.stream = stream
	player.volume_db = -40.0
	player.play()
	# Laufende Ueberblendung abbrechen (sonst stoppt sie evtl. den neuen Song)
	if _music_tween:
		_music_tween.kill()
	_music_tween = create_tween().set_parallel()
	_music_tween.tween_property(player, "volume_db", float(entry.get("volume_db", 0.0)), MUSIC_FADE)
	if old.playing:
		_music_tween.tween_property(old, "volume_db", -40.0, MUSIC_FADE)
		_music_tween.chain().tween_callback(old.stop)


## Musik ausblenden.
func stop_music() -> void:
	_music_id = 0
	if _music_tween:
		_music_tween.kill()
	_music_tween = create_tween().set_parallel()
	for player in _music:
		if player.playing:
			_music_tween.tween_property(player, "volume_db", -40.0, MUSIC_FADE * 0.5)
	_music_tween.chain().tween_callback(func() -> void:
		for player in _music:
			player.stop())


## ID des laufenden Songs (0 = keiner).
func get_music_id() -> int:
	return _music_id


## Name eines Songs aus der Tabelle (z. B. fuer Abspann/Tests).
func get_music_name(id: int) -> String:
	return str(_music_table.get(str(id), {}).get("name", ""))


## Musik gedaempft (wie hinter einer Tuer), z. B. bei offenem Spielmenue.
func set_music_muffled(on: bool) -> void:
	if _lowpass == null:
		return
	if _muffle_tween:
		_muffle_tween.kill()
	_muffle_tween = create_tween()
	_muffle_tween.tween_property(_lowpass, "cutoff_hz", MUFFLED_CUTOFF if on else OPEN_CUTOFF, MUFFLE_TIME)


func is_music_muffled() -> bool:
	return _lowpass != null and _lowpass.cutoff_hz < OPEN_CUTOFF * 0.5


func _setup_lowpass() -> void:
	var bus := AudioServer.get_bus_index("Music")
	if bus < 0:
		return
	for i in AudioServer.get_bus_effect_count(bus):
		if AudioServer.get_bus_effect(bus, i) is AudioEffectLowPassFilter:
			_lowpass = AudioServer.get_bus_effect(bus, i)
			return
	_lowpass = AudioEffectLowPassFilter.new()
	_lowpass.cutoff_hz = OPEN_CUTOFF
	AudioServer.add_bus_effect(bus, _lowpass)


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
