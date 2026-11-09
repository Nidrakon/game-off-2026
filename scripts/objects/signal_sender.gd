class_name SignalSender
extends RefCounted
## Gemeinsamer Baustein aller Ausloeser (Lichtschranke, Trefferflaeche): schickt
## ein Signal an eine Liste von Zielen. Jedes Ziel braucht die Funktionen
## activate(), deactivate() und toggle() (Doku 2.4, Signal-Empfaenger).

## Was der Ausloeser bei den Zielen bewirkt.
enum Action { TOGGLE, ACTIVATE, DEACTIVATE }

const METHODS := {
	Action.TOGGLE: "toggle",
	Action.ACTIVATE: "activate",
	Action.DEACTIVATE: "deactivate",
}


static func send(targets: Array[Node], action: Action, source: Node) -> void:
	var method: String = METHODS[action]
	for target in targets:
		if target == null:
			continue
		if target.has_method(method):
			target.call(method)
		else:
			push_warning("%s: Ziel %s kennt die Funktion %s() nicht." % [source.name, target.name, method])
