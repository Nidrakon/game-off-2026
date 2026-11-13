@tool
extends VBoxContainer
## Die Baukasten-Leiste im Editor (Doku 2.9).
##   - Bausteine (Liste in data/building_blocks.json) mit Vorschaubild: ins
##     Level ziehen (landen an der Mausposition) oder doppelklicken (landen in
##     der Bildmitte). Beschreibung als Tooltip.
##   - "Neues Level anlegen": legt eine geerbte Szene der Level-Vorlage an,
##     traegt sie in die Levelreihenfolge ein und oeffnet sie.
##   - "Testlauf starten": speichert die Szene und startet sie im Testmodus
##     (der echte Spielstand bleibt unberuehrt), wahlweise mit allen Upgrades.
##   - "Malen": waehlt im offenen Level die Mal-Ebene fuer Boden und Waende
##     (Ground) bzw. Rohre vorn (PipesFront) oder hinten (PipesBack); unten
##     oeffnet sich der TileMap-Editor.
## Texte deutsch: Die Leiste ist ein Werkzeug fuer den Nutzer, kein Teil des
## Spiels.

const CATALOG := "res://data/building_blocks.json"
const TEMPLATE := "res://scenes/levels/level_base.tscn"
const LEVEL_FOLDER := "res://scenes/levels"
const LEVEL_ORDER := "res://data/level_order.tres"
## Wird beim Testlauf geschrieben und vom Entwickler-Menue beim Start gelesen.
const QUICKSTART := "user://dev_quickstart.json"
const CATEGORY_TITLES := {
	"gelaende": "Waende & Boeden",
	"rohre": "Rohre & Dampf",
	"level": "Level",
	"plattformen": "Plattformen & Tueren",
	"gefahren": "Gefahren",
	"schalter": "Ausloeser & Schalter",
}
## Raster, auf das per Doppelklick eingefuegte Bausteine einrasten (Pixel).
const SNAP := 16.0
## Mal-Ebenen: Knopftext, Node im Level, Hinweis, Vorschaubild (Ausschnitt).
const PAINT_LAYERS := [
	["Boden & Waende malen", "Ground", "Unten im TileMap-Editor ein Tile waehlen und malen (Boden-Oberseite, Fuellung, Block).", "res://graphics/tilesets/tileset_placeholder.png", Rect2(0, 0, 16, 16)],
	["Rohre vorn malen", "PipesFront", "Unten Reiter 'Terrains' > 'Rohr vorn (Kollision)' waehlen und malen; die Rohre verbinden sich selbst.", "res://graphics/tilesets/tileset_pipes.png", Rect2(48, 48, 16, 16)],
	["Rohre hinten malen", "PipesBack", "Unten Reiter 'Terrains' > 'Rohr hinten (Deko)' waehlen und malen; keine Kollision, liegt hinter allem.", "res://graphics/tilesets/tileset_pipes.png", Rect2(112, 48, 16, 16)],
]
const COLOR_TITLE := Color("f9c22b")
const COLOR_HINT := Color("9babb2")

var undo_redo: EditorUndoRedoManager

var _new_level_dialog: ConfirmationDialog
var _level_name: LineEdit
var _add_to_order: CheckBox
var _all_upgrades: CheckBox
var _status: Label


## Ein Baustein in der Liste: ziehbar, Doppelklick fuegt ein.
class BlockButton extends Button:
	var scene_path := ""
	var dock: Node

	func _get_drag_data(_at_position: Vector2) -> Variant:
		var preview := TextureRect.new()
		preview.texture = icon
		preview.custom_minimum_size = Vector2(48, 48)
		preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		set_drag_preview(preview)
		return {"type": "files", "files": [scene_path]}

	func _gui_input(event: InputEvent) -> void:
		var click := event as InputEventMouseButton
		if click != null and click.double_click and click.button_index == MOUSE_BUTTON_LEFT:
			dock.insert_block(scene_path)
			accept_event()


func _ready() -> void:
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 4)
	_build_tools()
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	_build_blocks(list)


# --- Werkzeuge oben -------------------------------------------------------------------

func _build_tools() -> void:
	var new_level := Button.new()
	new_level.text = "Neues Level anlegen ..."
	new_level.tooltip_text = "Legt eine geerbte Szene der Level-Vorlage an, traegt sie in die Levelreihenfolge ein und oeffnet sie."
	new_level.pressed.connect(_ask_new_level)
	add_child(new_level)

	var test_row := HBoxContainer.new()
	add_child(test_row)
	var test := Button.new()
	test.text = "Testlauf starten"
	test.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	test.tooltip_text = "Speichert die offene Szene und startet sie im Testmodus (dein Spielstand bleibt unberuehrt)."
	test.pressed.connect(_start_test)
	test_row.add_child(test)
	_all_upgrades = CheckBox.new()
	_all_upgrades.text = "alle Upgrades"
	_all_upgrades.button_pressed = true
	_all_upgrades.tooltip_text = "Beim Testlauf Drehregler und Cursor freischalten."
	test_row.add_child(_all_upgrades)

	var paint_title := Label.new()
	paint_title.text = "Malen"
	paint_title.add_theme_color_override("font_color", COLOR_TITLE)
	add_child(paint_title)
	var paint_row := HFlowContainer.new()
	add_child(paint_row)
	for layer in PAINT_LAYERS:
		var paint := Button.new()
		paint.text = layer[0]
		paint.tooltip_text = layer[2]
		var atlas := AtlasTexture.new()
		atlas.atlas = load(layer[3])
		atlas.region = layer[4]
		paint.icon = atlas
		paint.expand_icon = false
		paint.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		paint.focus_mode = Control.FOCUS_NONE
		paint.pressed.connect(select_paint_layer.bind(layer[1], layer[2]))
		paint_row.add_child(paint)
	var fill_wall := Button.new()
	fill_wall.text = "Rueckwand fuellen"
	fill_wall.tooltip_text = "Fuellt die Ebene BackWall mit der Paneelwand, ueberall im Inneren der bemalten Flaeche von Ground (z. B. nach dem Vergroessern eines Raums). Strg+Z macht es rueckgaengig."
	var wall_icon := AtlasTexture.new()
	wall_icon.atlas = load("res://graphics/tilesets/tileset_wall.png")
	wall_icon.region = Rect2(16, 16, 16, 16)
	fill_wall.icon = wall_icon
	fill_wall.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	fill_wall.focus_mode = Control.FOCUS_NONE
	fill_wall.pressed.connect(fill_back_wall)
	paint_row.add_child(fill_wall)
	var fill_tesla := Button.new()
	fill_tesla.text = "Rueckwand Tesla"
	fill_tesla.tooltip_text = "Wie 'Rueckwand fuellen', aber im Look der Teslakammer (blaue Paneele, Kupferspulen)."
	var tesla_icon := AtlasTexture.new()
	tesla_icon.atlas = load("res://graphics/tilesets/tileset_wall.png")
	tesla_icon.region = Rect2(112, 0, 16, 16)
	fill_tesla.icon = tesla_icon
	fill_tesla.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	fill_tesla.focus_mode = Control.FOCUS_NONE
	fill_tesla.pressed.connect(fill_back_wall.bind(BackWall.Variant.TESLA))
	paint_row.add_child(fill_tesla)

	var hint := Label.new()
	hint.text = "Bausteine ins Level ziehen oder doppelklicken (Bildmitte). Tooltip = Erklaerung."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_color_override("font_color", COLOR_HINT)
	add_child(hint)
	_status = Label.new()
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.add_theme_color_override("font_color", COLOR_TITLE)
	add_child(_status)

	_new_level_dialog = ConfirmationDialog.new()
	_new_level_dialog.title = "Neues Level"
	var box := VBoxContainer.new()
	var info := Label.new()
	info.text = "Dateiname (englisch, snake_case, z. B. level_sentry_02):"
	box.add_child(info)
	_level_name = LineEdit.new()
	box.add_child(_level_name)
	_add_to_order = CheckBox.new()
	_add_to_order.text = "hinten in die Levelreihenfolge eintragen"
	_add_to_order.button_pressed = true
	box.add_child(_add_to_order)
	_new_level_dialog.add_child(box)
	_new_level_dialog.confirmed.connect(func() -> void: _create_level(_level_name.text.strip_edges()))
	add_child(_new_level_dialog)


# --- Bausteine ----------------------------------------------------------------------------

func _build_blocks(list: VBoxContainer) -> void:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(CATALOG))
	if not data is Array:
		var missing := Label.new()
		missing.text = "Katalog fehlt oder ist fehlerhaft: " + CATALOG
		list.add_child(missing)
		return
	var flows := {}
	for entry in data:
		var category: String = entry.get("category", "")
		if not flows.has(category):
			var title := Label.new()
			title.text = CATEGORY_TITLES.get(category, category)
			title.add_theme_color_override("font_color", COLOR_TITLE)
			list.add_child(title)
			var flow := HFlowContainer.new()
			flow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			list.add_child(flow)
			flows[category] = flow
		var button := BlockButton.new()
		button.scene_path = entry.path
		button.dock = self
		button.text = entry.name
		button.tooltip_text = "%s\n\n%s" % [entry.name, entry.get("description", "")]
		button.custom_minimum_size = Vector2(88, 64)
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		button.expand_icon = true
		button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		button.clip_text = true
		button.add_theme_font_size_override("font_size", 11)
		button.focus_mode = Control.FOCUS_NONE
		flows[category].add_child(button)
		button.icon = _entry_icon(entry)
		if button.icon == null:
			EditorInterface.get_resource_previewer().queue_resource_preview(entry.path, self, "_on_preview", button)


## Vorschaubild aus dem Katalog ("icon", optional "icon_region" = x, y, w, h).
func _entry_icon(entry: Dictionary) -> Texture2D:
	var path: String = entry.get("icon", "")
	if path == "" or not ResourceLoader.exists(path):
		return null
	var texture := load(path) as Texture2D
	var region: Array = entry.get("icon_region", [])
	if region.size() == 4:
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(region[0], region[1], region[2], region[3])
		return atlas
	return texture


func _on_preview(_path: String, preview: Texture2D, _thumbnail: Texture2D, button: Variant) -> void:
	if preview != null and is_instance_valid(button):
		button.icon = preview


## Fuegt einen Baustein in der Bildmitte ein (vor dem Professor, damit er vor
## den Objekten gezeichnet wird), rastet auf 8 px ein und waehlt ihn aus.
## Rueckgaengig mit Strg+Z.
func insert_block(path: String) -> void:
	var root := EditorInterface.get_edited_scene_root()
	if root == null:
		_status.text = "Erst ein Level oeffnen."
		return
	var block: Node = (load(path) as PackedScene).instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	block.name = _free_name(root, path.get_file().get_basename().to_pascal_case())
	var viewport := EditorInterface.get_editor_viewport_2d()
	var center: Vector2 = viewport.global_canvas_transform.affine_inverse() * (Vector2(viewport.size) / 2.0)
	center = center.snapped(Vector2(SNAP, SNAP))
	var professor := root.get_node_or_null("Professor")
	var index := professor.get_index() if professor != null else root.get_child_count()
	undo_redo.create_action("Baustein einfuegen")
	undo_redo.add_do_method(root, "add_child", block, true)
	undo_redo.add_do_method(root, "move_child", block, index)
	undo_redo.add_do_method(block, "set_owner", root)
	undo_redo.add_do_property(block, "position", root.to_local(center) if root is Node2D else center)
	undo_redo.add_do_reference(block)
	undo_redo.add_undo_method(root, "remove_child", block)
	undo_redo.commit_action()
	EditorInterface.get_selection().clear()
	EditorInterface.get_selection().add_node(block)
	_status.text = "Eingefuegt: %s" % block.name


## Waehlt die Mal-Ebene im offenen Level aus; der TileMap-Editor oeffnet sich.
func select_paint_layer(node_name: String, hint: String) -> void:
	var root := EditorInterface.get_edited_scene_root()
	var layer := root.get_node_or_null(node_name) if root != null else null
	if layer == null:
		_status.text = "Im offenen Level gibt es keine Ebene '%s' (nur in Leveln aus der Vorlage)." % node_name
		return
	EditorInterface.get_selection().clear()
	EditorInterface.get_selection().add_node(layer)
	EditorInterface.edit_node(layer)
	_status.text = "%s gewaehlt. %s" % [node_name, hint]


## Fuellt BackWall passend zu Ground (rueckgaengig mit Strg+Z).
func fill_back_wall(variant := BackWall.Variant.LAB) -> void:
	var root := EditorInterface.get_edited_scene_root()
	var wall := root.get_node_or_null("BackWall") as TileMapLayer if root != null else null
	var ground := root.get_node_or_null("Ground") as TileMapLayer if root != null else null
	if wall == null or ground == null:
		_status.text = "Im offenen Level fehlen die Ebenen BackWall oder Ground (nur in Leveln aus der Vorlage)."
		return
	var before := wall.tile_map_data
	var temp := TileMapLayer.new()
	temp.tile_set = wall.tile_set
	var count := BackWall.fill(temp, ground, variant)
	var after := temp.tile_map_data
	temp.free()
	undo_redo.create_action("Rueckwand fuellen")
	undo_redo.add_do_property(wall, "tile_map_data", after)
	undo_redo.add_undo_property(wall, "tile_map_data", before)
	undo_redo.commit_action()
	_status.text = "Rueckwand gefuellt (%d Tiles)." % count


func _free_name(root: Node, base: String) -> String:
	var name := base
	var n := 2
	while root.has_node(name):
		name = "%s%d" % [base, n]
		n += 1
	return name


# --- Aktionen ---------------------------------------------------------------------------

func _ask_new_level() -> void:
	_level_name.text = _next_free_name("level_sentry_")
	_new_level_dialog.popup_centered(Vector2i(360, 120))
	_level_name.grab_focus()
	_level_name.select_all()


func _next_free_name(prefix: String) -> String:
	var n := 1
	while FileAccess.file_exists("%s/%s%02d.tscn" % [LEVEL_FOLDER, prefix, n]):
		n += 1
	return "%s%02d" % [prefix, n]


## Legt das Level als geerbte Szene der Vorlage an (die Datei speichert nur
## Unterschiede zur Vorlage), traegt es ein und oeffnet es.
func _create_level(id: String) -> void:
	var valid := RegEx.create_from_string("^[a-z][a-z0-9_]*$")
	if valid.search(id) == null:
		_status.text = "Ungueltiger Name: '%s' (englisch, snake_case, z. B. level_sentry_02)." % id
		return
	var path := "%s/%s.tscn" % [LEVEL_FOLDER, id]
	if FileAccess.file_exists(path):
		_status.text = "%s gibt es schon - es wird geoeffnet." % path.get_file()
		EditorInterface.open_scene_from_path(path)
		return
	var text := '[gd_scene format=4]\n\n[ext_resource type="PackedScene" path="%s" id="1_base"]\n\n[node name="%s" instance=ExtResource("1_base")]\n' % [TEMPLATE, id.to_pascal_case()]
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_status.text = "Konnte %s nicht anlegen." % path
		return
	file.store_string(text)
	file.close()
	if _add_to_order.button_pressed:
		_register_level(path)
	EditorInterface.get_resource_filesystem().update_file(path)
	EditorInterface.get_resource_filesystem().scan()
	EditorInterface.open_scene_from_path(path)
	_status.text = "%s angelegt%s." % [path.get_file(), " und in die Levelreihenfolge eingetragen" if _add_to_order.button_pressed else ""]


func _register_level(path: String) -> void:
	var order: Resource = load(LEVEL_ORDER)
	var levels: Array[String] = []
	levels.assign(order.get("levels"))
	if levels.has(path):
		return
	levels.append(path)
	order.set("levels", levels)
	ResourceSaver.save(order, LEVEL_ORDER)


func _start_test() -> void:
	var root := EditorInterface.get_edited_scene_root()
	if root == null:
		_status.text = "Erst ein Level oeffnen."
		return
	EditorInterface.save_scene()
	var file := FileAccess.open(QUICKSTART, FileAccess.WRITE)
	file.store_string(JSON.stringify({"test_mode": true, "all_upgrades": _all_upgrades.button_pressed}))
	file.close()
	EditorInterface.play_current_scene()
