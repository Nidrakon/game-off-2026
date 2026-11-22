#!/bin/bash
# Fuehrt alle automatischen Tests (tests/test_*.gd) headless aus.
# Aufruf im Projektordner:  GODOT=/pfad/zur/godot_console.exe bash tools/run_tests.sh [export] [name ...]
#   export  = danach Web- und Windows-Export bauen
#   name    = nur diese Tests (z. B. test_music)
# Echter Spielstand und Einstellungen werden vorher gesichert und am Ende
# automatisch zurueckgeschrieben, falls ein Test sie veraendert oder geloescht
# hat. Tests sollen nur die Test-Dateien benutzen (savegame_test.json,
# settings_test.cfg).
cd "$(dirname "$0")/.." || exit 1
if [ -z "$GODOT" ]; then echo "GODOT (Pfad zur Godot-Konsole) setzen"; exit 1; fi
U="$APPDATA/Godot/app_userdata/Time Shifter"
TMP="$(mktemp -d)"
for f in savegame.json settings.cfg; do
	[ -f "$U/$f" ] && cp "$U/$f" "$TMP/$f"
done
timeout 200 "$GODOT" --headless --path . --import < /dev/null > /dev/null 2>&1
DO_EXPORT=0
ONLY=()
for a in "$@"; do
	if [ "$a" = "export" ]; then DO_EXPORT=1; else ONLY+=("$a"); fi
done
bad=0
for t in tests/test_*.gd; do
	n=$(basename "$t" .gd)
	if [ ${#ONLY[@]} -gt 0 ] && [[ ! " ${ONLY[*]} " =~ " $n " ]]; then continue; fi
	r=$(timeout 150 "$GODOT" --headless --path . --script "res://tests/$n.gd" < /dev/null 2>&1)
	f=$(echo "$r" | grep -c '^FAIL')
	e=$(echo "$r" | grep -E '^FAIL|SCRIPT ERROR|Parse Error' | head -3)
	if [ "$f" != "0" ] || [ -n "$e" ] || ! echo "$r" | grep -q '^Fehler: 0'; then
		echo "$n: $f fail $e"
		bad=1
	else
		echo -n "$n ok($(echo "$r" | grep -c '^PASS')) "
	fi
done
echo
for f in savegame.json settings.cfg; do
	if [ -f "$TMP/$f" ]; then
		if cmp -s "$U/$f" "$TMP/$f"; then
			echo "$f unveraendert"
		else
			cp "$TMP/$f" "$U/$f" && echo "ACHTUNG $f von einem Test veraendert - zurueckgeschrieben"
			bad=1
		fi
	elif [ -f "$U/$f" ]; then
		echo "ACHTUNG $f von einem Test angelegt - entfernt"
		rm -f "$U/$f"
		bad=1
	fi
done
rm -f "$U/savegame_test.json" "$U/settings_test.cfg"
rm -rf "$TMP"
if [ $DO_EXPORT = 1 ]; then
	timeout 300 "$GODOT" --headless --path . --export-release "Web" build/web/index.html < /dev/null 2>&1 | grep -iE "error|fail" | head -3
	timeout 300 "$GODOT" --headless --path . --export-release "Windows" build/windows/time_shifter.exe < /dev/null 2>&1 | grep -iE "error|fail" | head -3
	echo "Exporte fertig"
fi
exit $bad
