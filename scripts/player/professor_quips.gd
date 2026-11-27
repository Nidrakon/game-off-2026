extends Node
## Sprueche des Professors (Doku 2.8, 3.6): Kind-Node "Quips" im Professor.
## - In zufaelligen Abstaenden ein zufaelliger Spruch aus dialogues/speech.json
##   (Liste "quips_random"), nie zweimal hintereinander derselbe.
## - Nach dem Tod, beim Erscheinen in der Klonstation, ein Respawn-Spruch mit
##   der Klon-Nummer (Liste "quips_respawn", Platzhalter {n}).
## Alle Zeiten in data/speech_settings.tres. Laeuft nur, solange das Spiel
## nicht pausiert ist; spricht nicht, wenn schon eine Blase steht.
## Seit v0.77 nur, wenn der Professor still steht ("idle_required"); die
## Blase verschwindet, sobald er laeuft oder springt.

@export var settings: SpeechSettings = preload("res://data/speech_settings.tres")

var _next_quip := 0.0
var _last_quip := -1
var _idle_time := 0.0

@onready var _professor: Node2D = get_parent()


func _ready() -> void:
	_next_quip = settings.first_delay
	_check_respawn.call_deferred()


func _process(delta: float) -> void:
	_idle_time = 0.0 if SpeechBubble.is_speaker_moving(_professor) else _idle_time + delta
	if not settings.random_enabled or _professor.get("is_dead") or _professor.get("is_leaving"):
		return
	_next_quip -= delta
	# Faellig, aber erst, wenn er still steht (sonst stoert die Blase).
	if _next_quip > 0.0 or not is_idle():
		return
	_next_quip = randf_range(settings.random_interval_min, settings.random_interval_max)
	if SpeechBubble.is_speaking(_professor):
		return
	say_random()


## Steht der Professor lange genug still fuer einen Spruch?
func is_idle() -> bool:
	return _idle_time >= settings.idle_required


## Sagt einen zufaelligen Spruch (nicht denselben wie zuletzt).
func say_random() -> void:
	var quips := GameTexts.get_list("speech", "quips_random")
	if quips.is_empty():
		return
	var index := randi() % quips.size()
	if quips.size() > 1 and index == _last_quip:
		index = (index + 1) % quips.size()
	_last_quip = index
	SpeechBubble.say_text(_professor, str(quips[index]), 64.0, true)


## Respawn-Spruch mit Klon-Nummer.
func say_respawn() -> void:
	var lines := GameTexts.get_list("speech", "quips_respawn")
	if lines.is_empty():
		return
	var text := str(lines[randi() % lines.size()]).replace("{n}", str(SaveGame.clone_number))
	SpeechBubble.say_text(_professor, text, 64.0, true)


func _check_respawn() -> void:
	if not SaveGame.take_respawn_pending() or randf() > settings.respawn_chance:
		return
	await get_tree().create_timer(settings.respawn_delay, false).timeout
	# Auf einen ruhigen Moment warten; laeuft er sofort los, entfaellt der Spruch.
	var waited := 0.0
	while is_instance_valid(_professor) and not _professor.get("is_dead") and SpeechBubble.is_speaker_moving(_professor):
		if waited >= settings.respawn_max_wait:
			return
		await get_tree().process_frame
		waited += get_process_delta_time()
	if is_instance_valid(_professor) and not _professor.get("is_dead"):
		say_respawn()
