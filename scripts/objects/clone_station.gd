extends Node2D
## Klonstation (Doku 2.6): Checkpoint am Anfang jedes Levels. Beim Levelstart
## erscheint der Professor hier mit einem kurzen Strahl. Stirbt er, wird nach
## kurzer Wartezeit das Level neu geladen und er erscheint wieder hier.
## Der Node liegt am Boden in der Mitte der Station (dort stehen die Fuesse).

## Dauer des Erscheinens; so lange kann der Professor sich nicht bewegen (Sekunden).
@export var spawn_time := 0.5
## Wartezeit zwischen Tod und Neustart des Levels (Sekunden).
@export var restart_delay := 0.7

## Farben des Klon-Strahls (Palette).
const BEAM_COLORS := [Color("8fd3ff"), Color("ffffff"), Color("4d9be6")]
## Innenraum der Station relativ zum Node (fuer den Strahl).
const BEAM_RECT := Rect2(-17, -68, 34, 60)

var _beam_left := 0.0


func _ready() -> void:
	# Erst nach dem Aufbau des ganzen Levels, damit der Professor sicher da ist.
	_spawn_professor.call_deferred()


func _spawn_professor() -> void:
	var professor := get_tree().get_first_node_in_group("player") as Node2D
	if professor == null:
		push_warning("Klonstation: kein Professor (Gruppe 'player') im Level.")
		return
	professor.global_position = global_position
	professor.play_spawn(spawn_time)
	Sound.play_at("spawn", global_position)
	professor.died.connect(_on_professor_died)
	_beam_left = spawn_time
	# Kamera sofort auf den Professor setzen statt hinzugleiten.
	var camera := get_viewport().get_camera_2d()
	if camera and camera.has_method("snap_to_target"):
		camera.snap_to_target()


func _process(delta: float) -> void:
	if _beam_left > 0.0:
		_beam_left -= delta
		queue_redraw()


func _on_professor_died() -> void:
	await get_tree().create_timer(restart_delay).timeout
	get_tree().reload_current_scene()


func _draw() -> void:
	if _beam_left <= 0.0:
		return
	# Klon-Strahl: flackernde senkrechte Linien im Innenraum.
	for x in range(int(BEAM_RECT.position.x), int(BEAM_RECT.end.x), 3):
		if randf() < 0.6:
			var color: Color = BEAM_COLORS[randi() % BEAM_COLORS.size()]
			draw_line(Vector2(x, BEAM_RECT.position.y), Vector2(x, BEAM_RECT.end.y), color, 1.0)
