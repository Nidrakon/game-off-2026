extends Control
## Titelbildschirm (Doku 2.5), Hauptszene des Spiels: New Game, Continue,
## Quit.
## - Continue ist nur aktiv, wenn es einen Spielstand gibt.
## - New Game fragt nach, wenn es schon einen Spielstand gibt (er wird
##   ueberschrieben).
## - Quit fehlt im Browser (ein Browser-Spiel kann sich nicht beenden).
## Bedienbar mit Maus und Tastatur (Pfeiltasten, Enter). Texte aus
## dialogues/menu.json, Look aus MenuStyle (nur Palettenfarben).

const TEXT_FILE := "res://dialogues/menu.json"
## So lange nach dem Erscheinen reagieren die Knoepfe nicht (Sekunden), damit
## eine noch gedrueckte Taste vom vorigen Bildschirm nichts ausloest.
const INPUT_DELAY := 0.3

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
	Sound.stop_ambient()
	Sound.play_music(1)
	_texts = _load_texts()
	theme = MenuStyle.make_theme()
	_title.text = _text("menu_title")
	_title.add_theme_color_override("font_color", MenuStyle.COLOR_TITLE)
	_title.add_theme_font_size_override("font_size", 48)
	_new_game.text = _text("menu_new_game")
	_continue.text = _text("menu_continue")
	_quit.text = _text("menu_quit")
	_confirm_text.text = _text("menu_confirm_new_game")
	_yes.text = _text("menu_yes")
	_no.text = _text("menu_no")
	_confirm.add_theme_stylebox_override("panel", MenuStyle.box(MenuStyle.COLOR_PANEL, MenuStyle.COLOR_PANEL_BORDER, 2, 16))

	_continue.disabled = not SaveGame.has_save()
	_quit.visible = not OS.has_feature("web")
	_confirm.visible = false

	for button in [_new_game, _continue, _quit, _yes, _no]:
		button.mouse_entered.connect((func() -> void: Sound.play("ui_hover")))
		button.focus_entered.connect((func() -> void: Sound.play("ui_hover")))
		button.pressed.connect((func() -> void: Sound.play("ui_click")))
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
