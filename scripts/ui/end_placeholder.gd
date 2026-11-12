extends Control
## Vorlaeufiger Endbildschirm (Doku 2.9): erscheint nach dem letzten Level der
## Reihenfolge, bis das echte Ende gebaut ist. Taste oder Klick startet das
## Spiel von vorn.

## Erst nach dieser Zeit reagiert er auf Tasten (Sekunden), damit ein noch
## gehaltener Sprung ihn nicht sofort ueberspringt.
const INPUT_DELAY := 0.8

var _wait := INPUT_DELAY


func _process(delta: float) -> void:
	_wait -= delta


func _unhandled_input(event: InputEvent) -> void:
	if _wait > 0.0:
		return
	if (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed() and not event.is_echo():
		LevelFlow.start_game()
