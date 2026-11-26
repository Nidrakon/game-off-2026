@tool
extends Node2D
## Gleichzeitig-Schalter (Doku 2.4): wartet, bis ALLE Ausloeser in "sources"
## (Trefferflaechen, Lichtschranken) kurz hintereinander ausgeloest haben,
## hoechstens "tolerance" Sekunden auseinander. Dann sendet er "action" an
## alle Ziele in "targets" (z. B. Tuer auf). Einzelne Treffer bewirken nichts.
## Kleiner Kasten mit einer Lampe je Ausloeser: gelb = eben ausgeloest
## (wartet auf die anderen), gruen = geschafft.
## Die Toleranz zaehlt in echter Spielzeit (nicht von der Zeitblase
## beeinflusst). Der Node liegt in der Mitte des Kastens (an die Wand setzen).

## Wird gesendet, wenn alle Ausloeser gleichzeitig ausgeloest haben.
signal synced

## Ausloeser, die gleichzeitig kommen muessen (brauchen ein Signal
## "triggered", z. B. Trefferflaeche oder Lichtschranke).
@export var sources: Array[Node] = []:
	set(value):
		sources = value
		queue_redraw()
## Wie weit die Ausloeser hoechstens auseinander liegen duerfen (Sekunden).
@export_range(0.0, 5.0, 0.05, "or_greater") var tolerance := 0.3
## Ziele, die das Signal bekommen (Doku 2.4, Signal-Empfaenger).
@export var targets: Array[Node] = []
## Was bei den Zielen passiert.
@export var action := SignalSender.Action.ACTIVATE
## Nur einmal ausloesen (danach bleibt die Lampe gruen).
@export var one_shot := true

## So lange leuchtet die gruene Lampe nach dem Erfolg (Sekunden, ohne one_shot).
const SUCCESS_TIME := 1.0
const LAMP := 4.0
const GAP := 3.0
# Farben aus der Palette: Kasten, Lampen aus / wartend / geschafft.
const COLOR_OUTLINE := Color("2e222f")
const COLOR_BODY := Color("7f708a")
const COLOR_LIGHT := Color("9babb2")
const COLOR_OFF := Color("3e3546")
const COLOR_WAIT := Color("f9c22b")
const COLOR_DONE := Color("1ebc73")

# Zeitpunkt (Sekunden seit Levelstart) des letzten Ausloesens je Quelle.
var _hits := {}
var _clock := 0.0
var _done := false
var _success_left := 0.0


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	for i in sources.size():
		var source := sources[i]
		if source == null:
			continue
		if source.has_signal("triggered"):
			source.triggered.connect(_on_source_triggered.bind(i))
		else:
			push_warning("%s: Ausloeser %s hat kein Signal 'triggered'." % [name, source.name])


## Wurde er schon (einmal) erfolgreich ausgeloest?
func is_done() -> bool:
	return _done


func _on_source_triggered(index: int) -> void:
	if _done and one_shot:
		return
	_hits[index] = _clock
	queue_redraw()
	# Alle da und alle innerhalb der Toleranz?
	for i in sources.size():
		if sources[i] != null and (not _hits.has(i) or _clock - float(_hits[i]) > tolerance):
			return
	_done = true
	_success_left = SUCCESS_TIME
	_hits.clear()
	Sound.play_at("barrier_beep", global_position)
	synced.emit()
	SignalSender.send(targets, action, self)
	queue_redraw()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_clock += delta
	if _success_left > 0.0:
		_success_left -= delta
		if _success_left <= 0.0:
			queue_redraw()
	if not _hits.is_empty():
		queue_redraw()


func _draw() -> void:
	var count := maxi(sources.size(), 2)
	var width := count * LAMP + (count + 1) * GAP
	var box := Rect2(-floorf(width * 0.5) - 2.0, -7.0, width + 4.0, 14.0)
	draw_rect(box, COLOR_OUTLINE)
	draw_rect(box.grow(-1), COLOR_LIGHT)
	draw_rect(Rect2(box.position + Vector2(2, 2), box.size - Vector2(3, 3)), COLOR_BODY)
	var green := (_done and one_shot) or _success_left > 0.0
	for i in count:
		var color := COLOR_OFF
		if green and not Engine.is_editor_hint():
			color = COLOR_DONE
		elif _hits.has(i) and _clock - float(_hits[i]) <= tolerance:
			color = COLOR_WAIT
		var x := box.position.x + 2.0 + GAP + i * (LAMP + GAP)
		draw_rect(Rect2(x - 1, -3, LAMP + 2, LAMP + 2), COLOR_OUTLINE)
		draw_rect(Rect2(x, -2, LAMP, LAMP), color)
