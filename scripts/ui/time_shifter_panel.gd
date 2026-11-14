extends CanvasLayer
## Bedienfeld des Time Shifters ("Kupplung", Doku 2.2/2.3).
## Solange Shift gehalten wird, ist das Bedienfeld sichtbar und das Spiel
## pausiert. Laeuft auch waehrend der Pause (process_mode = Always).


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_set_open(false)


func _process(_delta: float) -> void:
	var want_open := Input.is_action_pressed("time_shifter_panel")
	if want_open != visible:
		_set_open(want_open)


func _input(event: InputEvent) -> void:
	# Mausrad bei gehaltener Shift-Taste (Bedienfeld offen): hoch = eine Stufe
	# schneller, runter = eine Stufe langsamer. Wirkt ueberall im Fenster.
	var button := event as InputEventMouseButton
	if not visible or button == null or not button.pressed:
		return
	var step := 0
	if button.button_index == MOUSE_BUTTON_WHEEL_UP:
		step = 1
	elif button.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		step = -1
	if step == 0:
		return
	var bubble := get_tree().get_first_node_in_group(TimeBubble.GROUP) as TimeBubble
	if bubble:
		# Stufen: 0 = langsam, 1 = normal, 2 = schnell; am Ende bleibt sie stehen.
		bubble.stage = clampi(bubble.stage + step, TimeBubble.Stage.SLOW, TimeBubble.Stage.FAST) as TimeBubble.Stage
	get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	# Fenster verliert den Fokus (z. B. Alt+Tab mit gehaltener Shift-Taste):
	# Bedienfeld schliessen, damit das Spiel nicht pausiert haengen bleibt.
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and visible:
		_set_open(false)


func _set_open(open: bool) -> void:
	if open != visible:
		Sound.play("panel_open" if open else "panel_close")
	visible = open
	get_tree().paused = open
