extends Control
## Titelbildschirm (Doku 2.5), Hauptszene des Spiels: New Game, Continue,
## Quit.
## - Continue ist nur aktiv, wenn es einen Spielstand gibt.
## - New Game fragt nach, wenn es schon einen Spielstand gibt (er wird
##   ueberschrieben).
## - Quit fehlt im Browser (ein Browser-Spiel kann sich nicht beenden).
## Bedienbar mit Maus und Tastatur (Pfeiltasten, Enter). Texte aus
## dialogues/menu.json, nur Palettenfarben.

const TEXT_FILE := "res://dialogues/menu.json"
## So lange nach dem Erscheinen reagieren die Knoepfe nicht (Sekunden), damit
## eine noch gedrueckte Taste vom vorigen Bildschirm nichts ausloest.
const INPUT_DELAY := 0.3

# Farben aus der Palette.
const COLOR_BG := Color("2e222f")
const COLOR_TITLE := Color("f9c22b")
const COLOR_BUTTON := Color("3e3546")
const COLOR_HOVER := Color("484a77")
const COLOR_PRESSED := Color("4d65b4")
const COLOR_FOCUS := Color("f9c22b")
const COLOR_TEXT := Color("c7dcd0")
const COLOR_DISABLED := Color("313638")
const COLOR_DISABLED_TEXT := Color("625565")
const COLOR_PANEL := Color("2e222f")
const COLOR_PANEL_BORDER := Color("7f708a")

var _texts := {}

@onready var _title: Label = $Title
@onready var _new_game: Button = $Buttons/NewGame
@onready var _continue: Button = $Buttons/Continue
@onready var _quit: Button = $Buttons/Quit
@onready var _confirm: PanelContainer = $Confirm
@onready var _confirm_text: Label = $Confirm/Box/Text
@onready var _yes: Button = $Confirm/Box/Answers/Yes
@onready var _no: Button = $Confirm/Box/Answers/No


func _ready() -> void:
	get_tree().paused = false
	_texts = _load_texts()
	theme = _make_theme()
	_title.text = _text("menu_title")
	_title.add_theme_color_override("font_color", COLOR_TITLE)
	_title.add_theme_font_size_override("font_size", 48)
	_new_game.text = _text("menu_new_game")
	_continue.text = _text("menu_continue")
	_quit.text = _text("menu_quit")
	_confirm_text.text = _text("menu_confirm_new_game")
	_yes.text = _text("menu_yes")
	_no.text = _text("menu_no")
	_confirm.add_theme_stylebox_override("panel", _box(COLOR_PANEL, COLOR_PANEL_BORDER, 2, 16))

	_continue.disabled = not SaveGame.has_save()
	_quit.visible = not OS.has_feature("web")
	_confirm.visible = false

	_new_game.pressed.connect(_on_new_game)
	_continue.pressed.connect(_on_continue)
	_quit.pressed.connect(_on_quit)
	_yes.pressed.connect(_start_new_game)
	_no.pressed.connect(_close_confirm)
	_set_menu_enabled(false)
	await get_tree().create_timer(INPUT_DELAY).timeout
	_set_menu_enabled(true)
	(_continue if not _continue.disabled else _new_game).grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if _confirm.visible and event.is_action_pressed("ui_cancel"):
		_close_confirm()
		get_viewport().set_input_as_handled()


func _on_new_game() -> void:
	if SaveGame.has_save():
		_confirm.visible = true
		_set_menu_enabled(false)
		_no.grab_focus()
	else:
		_start_new_game()


func _on_continue() -> void:
	_set_menu_enabled(false)
	if not SaveGame.continue_game():
		_set_menu_enabled(true)
		_continue.disabled = true


func _on_quit() -> void:
	get_tree().quit()


func _start_new_game() -> void:
	_confirm.visible = false
	_set_menu_enabled(false)
	SaveGame.new_game()


func _close_confirm() -> void:
	_confirm.visible = false
	_set_menu_enabled(true)
	_new_game.grab_focus()


func _set_menu_enabled(enabled: bool) -> void:
	for button in [_new_game, _continue, _quit]:
		button.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE
		button.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE


func _text(id: String) -> String:
	return str(_texts.get(id, id))


func _load_texts() -> Dictionary:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(TEXT_FILE))
	return data if data is Dictionary else {}


func _make_theme() -> Theme:
	var t := Theme.new()
	t.set_stylebox("normal", "Button", _box(COLOR_BUTTON, COLOR_BUTTON, 1, 8))
	t.set_stylebox("hover", "Button", _box(COLOR_HOVER, COLOR_HOVER, 1, 8))
	t.set_stylebox("pressed", "Button", _box(COLOR_PRESSED, COLOR_PRESSED, 1, 8))
	t.set_stylebox("hover_pressed", "Button", _box(COLOR_PRESSED, COLOR_PRESSED, 1, 8))
	t.set_stylebox("disabled", "Button", _box(COLOR_DISABLED, COLOR_DISABLED, 1, 8))
	t.set_stylebox("focus", "Button", _box(Color(0, 0, 0, 0), COLOR_FOCUS, 2, 8))
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
		t.set_color(state, "Button", COLOR_TEXT)
	t.set_color("font_disabled_color", "Button", COLOR_DISABLED_TEXT)
	t.set_font_size("font_size", "Button", 20)
	t.set_color("font_color", "Label", COLOR_TEXT)
	t.set_font_size("font_size", "Label", 18)
	return t


func _box(fill: Color, border: Color, border_width: int, padding: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.draw_center = fill.a > 0.0
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_content_margin_all(padding)
	style.anti_aliasing = false
	return style
