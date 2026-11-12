class_name TimeShifterUpgrades
extends Node
## Upgrades des Time Shifters (Doku 2.3, Freischalten), globales System
## (Autoload "Upgrades"). Merkt sich, welche Regler der Professor schon an
## Schrotthaufen eingebaut hat. Der Zeitregler ist von Anfang an da.
##
## Bleibt beim Neustart eines Levels erhalten (Autoload). Gespeichert wird
## spaeter mit dem Spielstand (Schritt 16) ueber get_ids() / set_ids().

## Freischaltbare Funktionen. Die Reihenfolge der Upgrades im Spiel legt das
## Leveldesign fest (welcher Schrotthaufen welches Upgrade bringt).
enum Upgrade { RADIUS, SHAPE }

## Feste Kennungen fuer den Spielstand (nie umbenennen, Doku 1.6).
const IDS := {
	Upgrade.RADIUS: "upgrade_radius",
	Upgrade.SHAPE: "upgrade_shape",
}

## Wird gesendet, wenn ein Upgrade neu freigeschaltet wurde.
signal unlocked(upgrade: Upgrade)
## Wird gesendet, wenn sich die freigeschalteten Upgrades aendern (auch
## beim Zuruecksetzen oder Laden).
signal changed

var _unlocked := {}


## Ist das Upgrade schon eingebaut?
func has(upgrade: Upgrade) -> bool:
	return _unlocked.has(upgrade)


## Schaltet ein Upgrade frei. Gibt false zurueck, wenn es schon da war.
func unlock(upgrade: Upgrade) -> bool:
	if has(upgrade):
		return false
	_unlocked[upgrade] = true
	unlocked.emit(upgrade)
	changed.emit()
	return true


## Alle Upgrades freischalten (Entwickler-Menue).
func unlock_all() -> void:
	for upgrade in Upgrade.values():
		if not has(upgrade):
			_unlocked[upgrade] = true
			unlocked.emit(upgrade)
	changed.emit()


## Alle Upgrades wieder entfernen (neues Spiel, Entwickler-Menue).
func reset() -> void:
	_unlocked.clear()
	changed.emit()


## Kennungen der freigeschalteten Upgrades (fuer den Spielstand).
func get_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for upgrade in _unlocked:
		ids.append(IDS[upgrade])
	return ids


## Freigeschaltete Upgrades aus dem Spielstand setzen.
func set_ids(ids: PackedStringArray) -> void:
	_unlocked.clear()
	for upgrade in IDS:
		if ids.has(IDS[upgrade]):
			_unlocked[upgrade] = true
	changed.emit()
