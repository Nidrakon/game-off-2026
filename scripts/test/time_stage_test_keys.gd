extends Node
## Nur fuer das Testlevel: Zeitstufe mit den Tasten 1, 2, 3 umschalten
## (1 = langsam, 2 = normal, 3 = schnell). Wird ersetzt durch das Bedienfeld
## des Time Shifters (Schritt 6).

## Die Zeitblase, die umgeschaltet wird.
@export var bubble: TimeBubble


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	match key.physical_keycode:
		KEY_1:
			bubble.stage = TimeBubble.Stage.SLOW
		KEY_2:
			bubble.stage = TimeBubble.Stage.NORMAL
		KEY_3:
			bubble.stage = TimeBubble.Stage.FAST
