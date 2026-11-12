@tool
extends Hazard
## Toedlicher Laser (Doku 2.4): roter Strahl zwischen zwei Sendern. Beruehrt
## der Professor den Strahl, stirbt er (Baustein Hazard; der Schalter
## "Unverwundbar" im F1-Menue gilt). Er sendet kein Signal.
##
## Takt: an fuer "on_time", aus fuer "off_time", kurz vor dem Einschalten
## erscheint als Warnung ein duenner, blasser Strahl. Mit "start_offset"
## laufen mehrere Laser versetzt. Der Takt laeuft in der Zeitblase langsamer
## oder schneller mit.
##
## Signal-Empfaenger: activate() = einschalten (Takt laeuft, beginnt mit der
## Warnung), deactivate() = ganz aus, toggle() = umschalten.
##
## Projektile mit "blocks_laser" (am Werfer einstellbar) halten den Strahl
## auf: Hinter ihnen ist er unterbrochen.
##
## Der Node selbst ist Sender A; Sender B liegt bei "beam_end". Im Editor sind
## Strahl und Sender sofort sichtbar (@tool).

## Zustand des Strahls.
enum State { OFF, WARNING, ON }

## Wird gesendet, wenn der Strahl an- oder ausgeht (nicht bei der Warnung).
signal switched(is_on: bool)

## Position von Sender B relativ zu Sender A (Pixel). (0, -144) = 9 Tiles nach oben.
@export var beam_end := Vector2(0, -144):
	set(value):
		beam_end = value
		_update_shape()
		queue_redraw()

@export_group("Takt")
## So lange ist der Strahl an (Sekunden, bei normalem Tempo).
@export_range(0.05, 30.0, 0.05, "or_greater") var on_time := 1.5
## So lange ist er aus (Sekunden, bei normalem Tempo), die Warnung eingerechnet.
@export_range(0.05, 30.0, 0.05, "or_greater") var off_time := 1.5
## Versatz im Takt beim Levelstart (Sekunden). Damit laufen mehrere Laser
## versetzt; 0 = beginnt mit "an".
@export_range(0.0, 30.0, 0.05, "or_greater") var start_offset := 0.0
## So lange vor dem Einschalten erscheint der Warnstrahl (Sekunden;
## hoechstens so lang wie off_time).
@export_range(0.0, 5.0, 0.05) var warning_time := 0.4
## Dauerhaft an statt im Takt (nach dem Einschalten per Signal mit Warnung).
@export var always_on := false

@export_group("Steuerung")
## Laeuft beim Levelstart (sonst erst nach activate() bzw. toggle()).
@export var active := true

## Wie oft hoechstens nach weiteren Projektilen im Strahl gesucht wird.
const MAX_RAY_STEPS := 8
## Physik-Ebene der Projektile (Ebene 3).
const PROJECTILE_MASK := 4
## Wechsel des Flackerns (Sekunden).
const FLICKER_TIME := 0.05
# Farben aus der Palette: aussen, Strahl, Kern (flackert zwischen beiden),
# Warnstrahl.
const COLOR_OUTER := Color("ae2334")
const COLOR_BEAM := Color("e83b3b")
const COLOR_CORE := Color("f68181")
const COLOR_CORE_BRIGHT := Color("ffffff")
const COLOR_WARNING := Color("f68181")

const EMITTER_TEXTURE := preload("res://graphics/sprites/objects/object_deadly_laser_emitter_placeholder.png")

var _shape: CollisionShape2D
# Position im Takt (Sekunden seit Beginn der An-Phase).
var _cycle_pos := 0.0
# Restzeit der Warnung nach dem Einschalten im Modus "dauerhaft an".
var _warn_left := 0.0
var _state := State.OFF
# Wo der Strahl endet (relativ, verkuerzt, wenn ein Projektil ihn aufhaelt).
var _beam_stop := Vector2.ZERO
var _flicker_left := 0.0
var _flicker_bright := false

@onready var _time: TimeAffected = $TimeAffected


func _ready() -> void:
	# Die Form wird im Code erzeugt, damit jeder Laser seine eigene hat.
	_shape = CollisionShape2D.new()
	_shape.shape = SegmentShape2D.new()
	add_child(_shape)
	_beam_stop = beam_end
	_update_shape()
	super._ready()
	if Engine.is_editor_hint():
		return
	_cycle_pos = fposmod(start_offset, _cycle_length())
	_warn_left = 0.0
	_state = _compute_state()


## Ist der Strahl gerade toedlich an?
func is_on() -> bool:
	return _state == State.ON


## Aktueller Zustand (aus, Warnung, an).
func get_state() -> State:
	return _state


## Wo der Strahl gerade endet (relativ zu Sender A).
func get_beam_stop() -> Vector2:
	return _beam_stop


## Signal-Empfaenger: einschalten. Der Strahl beginnt mit der Warnung.
func activate() -> void:
	if active:
		return
	active = true
	_warn_left = warning_time
	# Im Takt direkt vor die An-Phase springen, also in die Warnung.
	_cycle_pos = _cycle_length() - _warning_length()
	_set_state(_compute_state())


## Signal-Empfaenger: ganz ausschalten.
func deactivate() -> void:
	if not active:
		return
	active = false
	_set_state(State.OFF)


## Signal-Empfaenger: umschalten.
func toggle() -> void:
	if active:
		deactivate()
	else:
		activate()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if active:
		# Der Takt laeuft mit dem Tempo aus der Zeitblase.
		var step := delta * _time.time_scale
		if always_on:
			_warn_left = maxf(_warn_left - step, 0.0)
		else:
			_cycle_pos = fposmod(_cycle_pos + step, _cycle_length())
	_set_state(_compute_state())
	_update_beam_stop()
	# Erst danach pruefen, ob jemand im (an-geschalteten) Strahl steht.
	super._physics_process(delta)


func _process(delta: float) -> void:
	if _state != State.ON:
		return
	_flicker_left -= delta
	if _flicker_left <= 0.0:
		_flicker_left = FLICKER_TIME
		_flicker_bright = randf() < 0.35
		queue_redraw()


## Toedlich nur, solange der Strahl an ist.
func _is_safe_for(_body: Node2D) -> bool:
	return not is_on()


func _cycle_length() -> float:
	return maxf(on_time + off_time, 0.01)


func _warning_length() -> float:
	return clampf(warning_time, 0.0, off_time)


func _compute_state() -> State:
	if not active:
		return State.OFF
	if always_on:
		return State.WARNING if _warn_left > 0.0 else State.ON
	if _cycle_pos < on_time:
		return State.ON
	if _cycle_pos >= _cycle_length() - _warning_length():
		return State.WARNING
	return State.OFF


func _set_state(new_state: State) -> void:
	if new_state == _state:
		return
	var was_on := _state == State.ON
	_state = new_state
	queue_redraw()
	if was_on != (_state == State.ON):
		switched.emit(_state == State.ON)


## Sucht das erste Projektil im Strahl, das ihn aufhaelt, und kuerzt den
## Strahl (Form und Bild) bis dorthin.
func _update_beam_stop() -> void:
	var stop := beam_end
	if _state != State.OFF:
		var space := get_world_2d().direct_space_state
		var query := PhysicsRayQueryParameters2D.create(global_position, to_global(beam_end), PROJECTILE_MASK)
		query.collide_with_areas = false
		var exclude: Array[RID] = []
		for i in MAX_RAY_STEPS:
			query.exclude = exclude
			var hit := space.intersect_ray(query)
			if hit.is_empty():
				break
			var body: Object = hit.collider
			if body != null and body.get("blocks_laser") == true:
				stop = to_local(hit.position)
				break
			exclude.append(hit.rid)
	if not stop.is_equal_approx(_beam_stop):
		_beam_stop = stop
		_update_shape()
		queue_redraw()


func _update_shape() -> void:
	if _shape != null:
		var segment := _shape.shape as SegmentShape2D
		segment.a = Vector2.ZERO
		segment.b = beam_end if Engine.is_editor_hint() else _beam_stop
	# Die Zeitblase wirkt, sobald sie irgendeinen Teil des Strahls beruehrt.
	var time := get_node_or_null("TimeAffected") as TimeAffected
	if time != null:
		var area := Rect2(Vector2.ZERO, Vector2.ZERO).expand(beam_end)
		time.bounds = area.grow(4.0)


func _draw() -> void:
	var end := beam_end if Engine.is_editor_hint() else _beam_stop
	var state := State.ON if Engine.is_editor_hint() else _state
	match state:
		State.WARNING:
			# Duenner, blasser Strahl, gestrichelt.
			var length := end.length()
			var dir := end.normalized() if length > 0.0 else Vector2.ZERO
			var d := 0.0
			while d < length:
				draw_line(dir * d, dir * minf(d + 3.0, length), COLOR_WARNING, 1.0)
				d += 6.0
		State.ON:
			draw_line(Vector2.ZERO, end, COLOR_OUTER, 5.0 if not _flicker_bright else 4.0)
			draw_line(Vector2.ZERO, end, COLOR_BEAM, 3.0)
			draw_line(Vector2.ZERO, end, COLOR_CORE_BRIGHT if _flicker_bright else COLOR_CORE, 1.0)
	# Sender an beiden Enden, die Linse zeigt jeweils zum anderen Sender.
	var angle := beam_end.angle()
	_draw_emitter(Vector2.ZERO, angle)
	_draw_emitter(beam_end, angle + PI)


func _draw_emitter(at: Vector2, angle: float) -> void:
	draw_set_transform(at, angle)
	draw_texture(EMITTER_TEXTURE, -EMITTER_TEXTURE.get_size() * 0.5)
	draw_set_transform(Vector2.ZERO)
