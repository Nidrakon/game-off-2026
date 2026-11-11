@tool
extends Node2D
## Zeitschaltuhr (Doku 2.4): sitzt zwischen einem Ausloeser und seinen Zielen.
## Ein Signal startet den Countdown und sendet sofort "start_action" an die
## Ziele (z. B. Tuer auf). Ist die Zeit abgelaufen, sendet sie "end_action"
## (z. B. Tuer zu). In der Zeitblase laeuft die Uhr langsamer oder schneller,
## so bleibt eine Tuer z. B. laenger offen.
##
## Signal-Empfaenger: activate() = starten (laeuft sie schon: neu starten),
## deactivate() = sofort beenden, toggle() = starten bzw. beenden.
## Das Ziffernblatt zeigt die Restzeit als Tortenstueck.
## Der Node liegt in der Mitte der Uhr. Die Werte gehoeren zum Level und
## werden je Uhr im Inspector gesetzt.

## Wird gesendet, wenn der Countdown beginnt.
signal started
## Wird gesendet, wenn der Countdown endet (abgelaufen oder beendet).
signal finished

## Laufzeit bei normalem Tempo (Sekunden).
@export var duration := 3.0
## Ziele, die die Signale bekommen (Doku 2.4, Signal-Empfaenger).
@export var targets: Array[Node] = []
## Was beim Start bei den Zielen passiert.
@export var start_action := SignalSender.Action.ACTIVATE
## Was beim Ablauf bei den Zielen passiert.
@export var end_action := SignalSender.Action.DEACTIVATE
## Ein neues Signal waehrend des Laufens startet die Zeit von vorn (an) oder
## wird ignoriert (aus).
@export var restart_on_trigger := true
## Startet beim Levelbeginn von selbst.
@export var autostart := false
## Beginnt nach dem Ablauf sofort von vorn (Taktgeber, z. B. fuer zwei Uhren,
## die man mit der Zeitblase in Gleichtakt bringt).
@export var repeat := false

## Mitte des Ziffernblatts relativ zum Node und Radius der Restzeit-Anzeige.
const DIAL_CENTER := Vector2(-0.5, -2.5)
const DIAL_RADIUS := 8.0
## Ab diesem Rest (Anteil) wird die Anzeige rot: gleich ist die Zeit um.
const WARNING_FRACTION := 0.25
# Farben aus der Palette: Restzeit, Warnung, Zeiger.
const COLOR_TIME := Color("f9c22b")
const COLOR_WARNING := Color("e83b3b")
const COLOR_HAND := Color("2e222f")

var _time_left := 0.0

@onready var _time: TimeAffected = $TimeAffected
@onready var _dial: Node2D = $Dial


func _ready() -> void:
	_dial.draw.connect(_draw_dial)
	if not Engine.is_editor_hint() and autostart:
		_start()


## Laeuft der Countdown gerade?
func is_running() -> bool:
	return _time_left > 0.0


## Anteil der Restzeit (1 = gerade gestartet, 0 = abgelaufen).
func get_fraction() -> float:
	if duration <= 0.0:
		return 0.0
	return clampf(_time_left / duration, 0.0, 1.0)


## Signal-Empfaenger: starten bzw. neu starten.
func activate() -> void:
	if is_running() and not restart_on_trigger:
		return
	_start()


## Signal-Empfaenger: sofort beenden.
func deactivate() -> void:
	if is_running():
		_finish()


## Signal-Empfaenger: starten, wenn sie steht, sonst beenden.
func toggle() -> void:
	if is_running():
		_finish()
	else:
		_start()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or not is_running():
		return
	# Die Zeit der Uhr laeuft mit dem Tempo aus der Zeitblase.
	_time_left -= delta * _time.time_scale
	_dial.queue_redraw()
	if _time_left <= 0.0:
		_finish()
		if repeat:
			_start()


func _start() -> void:
	var was_running := is_running()
	_time_left = duration
	_dial.queue_redraw()
	# Beim Neustart waehrend des Laufens nicht erneut senden, sonst wuerde
	# z. B. "umschalten" die Tuer gleich wieder schliessen.
	if was_running:
		return
	started.emit()
	SignalSender.send(targets, start_action, self)


func _finish() -> void:
	_time_left = 0.0
	_dial.queue_redraw()
	finished.emit()
	SignalSender.send(targets, end_action, self)


func _draw_dial() -> void:
	var fraction := get_fraction()
	var angle := -PI * 0.5
	if fraction > 0.0:
		# Tortenstueck von 12 Uhr im Uhrzeigersinn, so gross wie die Restzeit.
		var color := COLOR_WARNING if fraction <= WARNING_FRACTION else COLOR_TIME
		var points := PackedVector2Array([DIAL_CENTER])
		var steps := maxi(2, ceili(32.0 * fraction))
		for i in steps + 1:
			var a := angle + TAU * fraction * float(i) / float(steps)
			points.append(DIAL_CENTER + Vector2(cos(a), sin(a)) * DIAL_RADIUS)
		_dial.draw_colored_polygon(points, color)
		angle += TAU * fraction
	# Zeiger an der Kante der Restzeit (steht auf 12, wenn die Uhr ruht).
	_dial.draw_line(DIAL_CENTER, DIAL_CENTER + Vector2(cos(angle), sin(angle)) * DIAL_RADIUS, COLOR_HAND, 1.0)
