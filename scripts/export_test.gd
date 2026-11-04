extends Control
## Vorlaeufige Startszene nur fuer den Export-Test (Schritt 2).
## Zeigt an, auf welcher Plattform das Spiel laeuft und in welcher
## Aufloesung gezeichnet wird. Wird in Schritt 3 durch die Testszene ersetzt.

@onready var _info_label: Label = $InfoLabel


func _ready() -> void:
	var viewport_size := get_viewport_rect().size
	_info_label.text = "Time Shifter\nExport test\n\nPlatform: %s\nViewport: %d x %d" % [
		OS.get_name(),
		viewport_size.x,
		viewport_size.y,
	]
