extends Hazard
## Toedliche Seiten des Projektils. Ausnahme: Wer gerade oben drauf stand, darf
## an der Kante herunterlaufen, ohne sofort zu sterben.


func _is_safe_for(_body: Node2D) -> bool:
	return get_parent().is_ridden_recently()
