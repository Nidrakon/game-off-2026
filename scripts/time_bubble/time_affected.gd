class_name TimeAffected
extends Node2D
## Baustein fuer alles, was auf die Zeitblase reagiert. Als Kind-Node an ein
## Objekt haengen. Das Objekt rechnet dann mit "delta * time_scale" statt nur
## mit "delta".
##
## Pixelgenau (seit v0.63, Wunsch des Nutzers): Die Blase wirkt erst, wenn sie
## die sichtbaren Pixel des Objekts beruehrt. Der Umriss kommt, in dieser
## Reihenfolge, aus
## 1. einer eigenen Pixelquelle (set_pixel_source, z. B. Requisiten im Atlas),
## 2. dem Sprite des Objekts (Geschwister-Node "Sprite" oder sprite_path;
##    Sprite2D mit Frames/Region oder AnimatedSprite2D, aktuelles Bild),
## 3. einem eigenen Polygon (custom_polygon, z. B. der Laserstrahl),
## 4. sonst dem Rechteck "bounds".
## Alles dreht, spiegelt und skaliert mit dem Objekt mit.
## Solange das Objekt die Blase beruehrt, wird sein Umriss farbig markiert,
## aber nur, wenn das im F1-Menue eingeschaltet ist (zum Testen; im Spiel nie).

## Wird gesendet, wenn sich das Tempo dieses Objekts aendert.
signal time_scale_changed(new_scale: float)

## Flaeche des Objekts relativ zu diesem Node, wenn es keinen Pixel-Umriss
## gibt (Objekte, die sich selbst zeichnen).
@export var bounds := Rect2(-8, -8, 16, 16):
	set(value):
		bounds = value
		queue_redraw()
## Reagiert ueberhaupt auf die Zeitblase? Aus = immer normales Tempo. Die
## Bausteine setzen das ueber ihren Schalter "time_shifter" im Inspector.
@export var active := true
## Umriss aus den sichtbaren Pixeln des Sprites (aus = immer "bounds").
@export var pixel_perfect := true
## Sprite fuer den Pixel-Umriss; leer = Geschwister-Node "Sprite".
@export var sprite_path: NodePath

## Eigenes Umriss-Polygon relativ zu diesem Node (statt bounds), z. B. ein
## schmaler Streifen um einen Laserstrahl.
var custom_polygon := PackedVector2Array():
	set(value):
		custom_polygon = value
		queue_redraw()

## Aktuelles Tempo dieses Objekts (1 = normal). Nur lesen.
var time_scale := 1.0

# Umrisse je Bildausschnitt (Pixelkoordinaten im Ausschnitt), fuer alle geteilt.
static var _outline_cache := {}

var _bubble: TimeBubble
var _marker_color := Color.TRANSPARENT
var _markers_shown := false
# Eigene Pixelquelle (set_pixel_source).
var _px_texture: Texture2D
var _px_region := Rect2()
var _px_origin := Vector2.ZERO
var _px_flip_h := false


func _ready() -> void:
	# Vor dem Objekt selbst rechnen, damit es im selben Physik-Schritt schon
	# das aktuelle Tempo verwendet.
	process_physics_priority = -1


func _physics_process(_delta: float) -> void:
	var bubble := _find_bubble()
	var new_scale := 1.0
	var new_color := Color.TRANSPARENT
	if active and bubble and touches_bubble(bubble):
		new_scale = bubble.get_time_scale()
		if bubble.stage != TimeBubble.Stage.NORMAL:
			new_color = bubble.get_stage_color()

	var shown := _markers_enabled()
	if new_color != _marker_color or shown != _markers_shown:
		_marker_color = new_color
		_markers_shown = shown
	if shown:
		queue_redraw()
	if new_scale != time_scale:
		time_scale = new_scale
		time_scale_changed.emit(time_scale)


## Beruehrt der Umriss des Objekts die Blase?
func touches_bubble(bubble: TimeBubble) -> bool:
	for poly in get_global_polygons():
		if bubble.overlaps_polygon(poly):
			return true
	return false


## Eigene Pixelquelle: Ausschnitt "region" aus "texture", gezeichnet mit der
## linken oberen Ecke bei "origin" (relativ zu diesem Node).
func set_pixel_source(texture: Texture2D, region: Rect2, origin: Vector2, flip_h := false) -> void:
	_px_texture = texture
	_px_region = region
	_px_origin = origin
	_px_flip_h = flip_h
	queue_redraw()


## Umriss des Objekts in Weltkoordinaten (ein oder mehrere Polygone).
func get_global_polygons() -> Array[PackedVector2Array]:
	var result: Array[PackedVector2Array] = []
	if pixel_perfect and _px_texture:
		for poly in _outline(_px_texture, _px_region):
			result.append(global_transform * _place(poly, _px_origin, _px_region.size, _px_flip_h, false))
		if not result.is_empty():
			return result
	if pixel_perfect:
		var sprite := _get_sprite()
		if sprite:
			result = _sprite_polygons(sprite)
			if not result.is_empty():
				return result
	if not custom_polygon.is_empty():
		result.append(global_transform * custom_polygon)
		return result
	var r := bounds
	result.append(global_transform * PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]))
	return result


## Rechteck des Objekts in Weltkoordinaten (umschliessend, fuer Vortests).
func get_global_bounds() -> Rect2:
	var polys := get_global_polygons()
	var box := Rect2(polys[0][0], Vector2.ZERO)
	for poly in polys:
		for p in poly:
			box = box.expand(p)
	return box


func _get_sprite() -> Node2D:
	var node: Node = get_node_or_null(sprite_path) if not sprite_path.is_empty() else get_parent().get_node_or_null("Sprite")
	return node if node is Sprite2D or node is AnimatedSprite2D else null


func _sprite_polygons(sprite: Node2D) -> Array[PackedVector2Array]:
	var result: Array[PackedVector2Array] = []
	var texture: Texture2D
	var region: Rect2
	var centered := true
	var offset := Vector2.ZERO
	var flip_h := false
	var flip_v := false
	if sprite is Sprite2D:
		var s := sprite as Sprite2D
		texture = s.texture
		if texture == null:
			return result
		var full := s.region_rect if s.region_enabled else Rect2(Vector2.ZERO, texture.get_size())
		var frame_size := full.size / Vector2(s.hframes, s.vframes)
		region = Rect2(full.position + Vector2(s.frame_coords) * frame_size, frame_size)
		centered = s.centered
		offset = s.offset
		flip_h = s.flip_h
		flip_v = s.flip_v
	else:
		var a := sprite as AnimatedSprite2D
		if a.sprite_frames == null or not a.sprite_frames.has_animation(a.animation):
			return result
		texture = a.sprite_frames.get_frame_texture(a.animation, a.frame)
		if texture == null:
			return result
		region = Rect2(Vector2.ZERO, texture.get_size())
		centered = a.centered
		offset = a.offset
		flip_h = a.flip_h
		flip_v = a.flip_v
	var origin := offset - (region.size * 0.5 if centered else Vector2.ZERO)
	for poly in _outline(texture, region):
		result.append(sprite.global_transform * _place(poly, origin, region.size, flip_h, flip_v))
	return result


## Pixel-Umriss eines Bildausschnitts (Pixelkoordinaten im Ausschnitt).
static func _outline(texture: Texture2D, region: Rect2) -> Array:
	var key := "%d:%s" % [texture.get_instance_id(), region]
	if _outline_cache.has(key):
		return _outline_cache[key]
	var polys := []
	var image := texture.get_image()
	if image != null:
		if image.is_compressed():
			image.decompress()
		# AtlasTexture liefert schon den Ausschnitt, sonst ausschneiden.
		var r := Rect2i(region)
		if image.get_size() != r.size:
			r = r.intersection(Rect2i(Vector2i.ZERO, image.get_size()))
			image = image.get_region(r)
		var bitmap := BitMap.new()
		bitmap.create_from_image_alpha(image, 0.1)
		for poly in bitmap.opaque_to_polygons(Rect2i(Vector2i.ZERO, image.get_size()), 0.5):
			polys.append(poly)
	_outline_cache[key] = polys
	return polys


## Umriss an seine Stelle setzen (Ursprung, Spiegelung); Drehsinn bleibt gleich.
static func _place(poly: PackedVector2Array, origin: Vector2, size: Vector2, flip_h: bool, flip_v: bool) -> PackedVector2Array:
	var out := PackedVector2Array()
	out.resize(poly.size())
	for i in poly.size():
		var p := poly[i]
		if flip_h:
			p.x = size.x - p.x
		if flip_v:
			p.y = size.y - p.y
		out[i] = p + origin
	if flip_h != flip_v:
		out.reverse()
	return out


## Schalter "Time markers" im F1-Menue. Im exportierten Spiel ist das Menue
## aus, dann bleibt die Markierung immer unsichtbar.
func _markers_enabled() -> bool:
	var dev_menu := get_node_or_null("/root/DevMenu")
	return dev_menu != null and dev_menu.show_time_markers


func _find_bubble() -> TimeBubble:
	if not is_instance_valid(_bubble):
		_bubble = get_tree().get_first_node_in_group(TimeBubble.GROUP) as TimeBubble
	return _bubble


func _draw() -> void:
	# Markierung: Umriss in der Farbe der Zeitstufe (genau die Flaeche, die
	# die Blase beruehren muss).
	if not (_markers_shown and _marker_color.a > 0.0):
		return
	var to_local := global_transform.affine_inverse()
	for poly in get_global_polygons():
		var local := to_local * poly
		local.append(local[0])
		draw_polyline(local, _marker_color, 1.0)
