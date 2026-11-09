@tool
extends Area2D
## Lichtschranke: ein Laserstrahl zwischen zwei Sendern. Laeuft der Professor
## hindurch, sendet sie ein Signal an alle Ziele in "targets" (z. B. eine
## fliegende Plattform an- oder ausschalten).
## Der Node selbst ist Sender A; Sender B liegt bei "beam_end".
## Im Editor sind Strahl und Sender sofort sichtbar (@tool), damit man sie
## beim Levelbau richtig platzieren kann.

## Wird gesendet, wenn jemand den Strahl durchquert.
signal triggered

## Position von Sender B relativ zu Sender A (Pixel). (0, -144) = 9 Tiles nach oben.
@export var beam_end := Vector2(0, -144):
	set(value):
		beam_end = value
		_update_shape()
		queue_redraw()
## Ziele, die das Signal bekommen. Jedes Ziel braucht die Funktionen
## activate(), deactivate() und toggle() (siehe Doku 2.4, Signal-Empfaenger).
@export var targets: Array[Node] = []
## Was bei den Zielen passiert: umschalten, einschalten oder ausschalten.
@export var action := SignalSender.Action.TOGGLE
## Nur einmal ausloesen; danach erlischt der Strahl.
@export var one_shot := false

## Dauer des Aufblitzens nach dem Ausloesen (Sekunden).
const FLASH_TIME := 0.15
## Farben aus der Palette: Rand und Kern des Strahls, Blitz, erloschen.
const COLOR_BEAM := Color("e83b3b")
const COLOR_CORE := Color("f68181")
const COLOR_FLASH := Color("ffffff")
const COLOR_OFF := Color("6e2727")

const EMITTER_TEXTURE := preload("res://graphics/sprites/objects/object_light_barrier_emitter_placeholder.png")

var _shape: CollisionShape2D
var _used := false
var _flash_left := 0.0


func _ready() -> void:
	# Die Form wird im Code erzeugt, damit jede Lichtschranke ihre eigene hat.
	_shape = CollisionShape2D.new()
	_shape.shape = SegmentShape2D.new()
	add_child(_shape)
	_update_shape()
	if Engine.is_editor_hint():
		return
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if _flash_left > 0.0:
		_flash_left -= delta
		if _flash_left <= 0.0:
			queue_redraw()


func _on_body_entered(_body: Node2D) -> void:
	if _used:
		return
	if one_shot:
		_used = true
		_shape.set_deferred("disabled", true)
	_flash_left = FLASH_TIME
	queue_redraw()
	triggered.emit()
	SignalSender.send(targets, action, self)


func _update_shape() -> void:
	if _shape == null:
		return
	var segment := _shape.shape as SegmentShape2D
	if segment:
		segment.a = Vector2.ZERO
		segment.b = beam_end


func _draw() -> void:
	# Strahl: 3 px breit, heller Kern; beim Ausloesen kurz weiss, verbraucht dunkel.
	if _used:
		draw_line(Vector2.ZERO, beam_end, COLOR_OFF, 1.0)
	else:
		var core := COLOR_FLASH if _flash_left > 0.0 else COLOR_CORE
		draw_line(Vector2.ZERO, beam_end, COLOR_BEAM, 3.0)
		draw_line(Vector2.ZERO, beam_end, core, 1.0)
	# Sender an beiden Enden, die Linse zeigt jeweils zum anderen Sender.
	var angle := beam_end.angle()
	_draw_emitter(Vector2.ZERO, angle)
	_draw_emitter(beam_end, angle + PI)


func _draw_emitter(at: Vector2, angle: float) -> void:
	draw_set_transform(at, angle)
	draw_texture(EMITTER_TEXTURE, -EMITTER_TEXTURE.get_size() * 0.5)
	draw_set_transform(Vector2.ZERO)
