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


func _notification(what: int) -> void:
	# Fenster verliert den Fokus (z. B. Alt+Tab mit gehaltener Shift-Taste):
	# Bedienfeld schliessen, damit das Spiel nicht pausiert haengen bleibt.
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and visible:
		_set_open(false)


func _set_open(open: bool) -> void:
	visible = open
	get_tree().paused = open
