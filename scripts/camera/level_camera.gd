extends Camera2D
## Kamera, die im Physik-Takt einem Ziel (dem Professor) folgt.
## Die Grenzen (limit_*) werden im Level an der Kamera eingestellt.

## Node, dem die Kamera folgt.
@export var target: Node2D
## Versatz zum Ziel; negativ = Kamera etwas hoeher als die Fuesse der Figur.
@export var offset_to_target := Vector2(0, -32)


func _physics_process(_delta: float) -> void:
	if target:
		global_position = target.global_position + offset_to_target


## Kamera sofort aufs Ziel setzen, ohne weich hinzugleiten (z. B. beim
## Levelstart an der Klonstation).
func snap_to_target() -> void:
	if target:
		global_position = target.global_position + offset_to_target
		reset_smoothing()
