class_name BackgroundTheme
extends RefCounted
## Hintergrund-Themen fuer Level (Doku 2.9): Farbe der Rueckwand und Satz
## der Hintergrund-Silhouetten mit zwei dezenten Toenen (Palette).
## Gewaehlt wird je Level an der Wurzel (level.gd, Gruppe "Hintergrund").

enum Kind { WORKSHOP, FACTORY, CHEMICAL, ELECTRO, MAGNET, QUANTUM }

## Je Thema: Wand-Variante (Spaltenblock in tileset_wall.png), Reihe im
## Silhouetten-Atlas, zwei Toene (Palettenfarben) fuer die Silhouetten.
const DATA := {
	Kind.WORKSHOP: {"wall": 0, "row": 0, "tones": ["3e3546", "2e222f"]},
	Kind.FACTORY: {"wall": 2, "row": 1, "tones": ["3e3546", "2e222f"]},
	Kind.CHEMICAL: {"wall": 3, "row": 2, "tones": ["0b5e65", "2e222f"]},
	Kind.ELECTRO: {"wall": 1, "row": 3, "tones": ["484a77", "2e222f"]},
	Kind.MAGNET: {"wall": 4, "row": 4, "tones": ["7a3045", "45293f"]},
	Kind.QUANTUM: {"wall": 5, "row": 5, "tones": ["45293f", "7a3045"]},
}
## Silhouetten je Thema (Spalten im Atlas) und Groesse einer Zelle.
const SHAPES_PER_THEME := 9
const CELL := 96


## Wand-Variante des Themas.
static func wall_variant(theme: Kind) -> int:
	return DATA[theme].wall


## Reihe des Themas im Silhouetten-Atlas.
static func silhouette_row(theme: Kind) -> int:
	return DATA[theme].row


## Die beiden Toene des Themas.
static func tones(theme: Kind) -> Array[Color]:
	var result: Array[Color] = []
	for hex in DATA[theme].tones:
		result.append(Color(hex))
	return result
