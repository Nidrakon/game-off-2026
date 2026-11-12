extends Node
## Startszene des Spiels (Hauptszene): startet sofort das erste Level der
## Reihenfolge (data/level_order.tres). Wird mit Schritt 16 durch den
## Titelbildschirm ersetzt.


func _ready() -> void:
	LevelFlow.start_game.call_deferred()
