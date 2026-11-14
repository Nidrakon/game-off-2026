class_name DustPuff
extends Node2D
## Staubwoelkchen (Doku 2.2, Spielgefuehl): ein paar Pixel-Woelkchen fliegen
## auseinander, steigen leicht auf und schrumpfen weg. Ohne Transparenz, nur
## Palettenfarben. Entfernt sich danach selbst.

const LIFE := 0.45
const COLORS := [Color("c7dcd0"), Color("9babb2"), Color("7f708a")]

var _parts: Array[Dictionary] = []
var _age := 0.0


## Erzeugt "count" Woelkchen an "position" in "parent". "spread" = Richtung
## (z. B. Vector2(1, 0) = vor allem seitlich), "speed" = Tempo in px/s.
static func spawn(parent: Node, position: Vector2, count: int, speed := 60.0, upward := 0.3) -> DustPuff:
	var puff := DustPuff.new()
	puff.global_position = position
	puff.z_index = 3
	for i in count:
		var side := -1.0 if i % 2 == 0 else 1.0
		var dir := Vector2(side * randf_range(0.5, 1.0), -randf_range(0.0, upward)).normalized()
		puff._parts.append({"pos": Vector2(side * randf_range(0.0, 4.0), 0.0), "vel": dir * speed * randf_range(0.6, 1.2), "size": randf_range(2.0, 4.0), "color": COLORS[randi() % COLORS.size()]})
	parent.add_child(puff)
	return puff


func _process(delta: float) -> void:
	_age += delta
	if _age >= LIFE:
		queue_free()
		return
	for p in _parts:
		p.pos += p.vel * delta
		p.vel *= 0.9
		p.vel.y -= 12.0 * delta
	queue_redraw()


func _draw() -> void:
	var t := _age / LIFE
	for p in _parts:
		var s := roundf(p.size * (1.0 - t))
		if s < 1.0:
			continue
		draw_rect(Rect2((p.pos - Vector2(s, s) * 0.5).round(), Vector2(s, s)), p.color)
