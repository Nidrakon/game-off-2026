# Versionsprotokoll: Time Shifter

Gehoert zur Projektdokumentation (`projektdokumentation.md`, Kapitel 5).
Neue Eintraege werden fortlaufend oben ergaenzt, bestehende nie ueberschrieben.

> **Regeln fuer dieses Protokoll (Block nach dem Ausfuellen behalten oder
> in die Projektdoku, Regel 8, uebernehmen)**
>
> **Wann ein Eintrag entsteht:** nach jedem abgeschlossenen Schritt, nach
> jeder Runde Nachbesserungen und bei jeder Festlegung, die die Doku aendert
> (auch ohne Code, z. B. neue Regel, eingepflegte Notizen, geaenderte
> Handlung). Ein Eintrag pro Commit bzw. pro Runde, nicht pro Datei.
>
> **Format:**
>
> ```
> **vX.Y - JJJJ-MM-TT: Titel**
>
> - Aenderung 1
> - Aenderung 2
> ```
>
> **Versionsnummern:**
>
> - `v0.1` ist der Projektstart; jeder Eintrag zaehlt die zweite Zahl um
>   eins hoch (`v0.9`, `v0.10`, `v0.11` ...). Die zweite Zahl ist ein
>   Zaehler, kein Dezimalbruch: Auf `v0.99` folgt `v0.100`.
> - `v1.0` ist die erste veroeffentlichte Fassung (Release). Danach geht es
>   mit `v1.1`, `v1.2` ... weiter.
> - Ein grosser Umbruch nach dem Release (z. B. neue Plattform, grosse
>   Erweiterung) darf `v2.0` werden.
>
> **Titel:** sagt, was sich fuer den Spieler bzw. das Projekt geaendert hat,
> nicht welche Dateien. Bei Schritten der Aufgabenliste die Nummer davor:
> "Schritt 12 - Schalter und Tuer", bei Bloecken "Titel (Schritte 12-16)".
> Sonst z. B. "Nachbesserungen", "Feinschliff Level 3", "Festlegung:
> Handlung des zweiten Akts".
>
> **Punkte:**
>
> - Zwei bis sechs Punkte, je ein bis drei Zeilen.
> - Aus Sicht des Spielers bzw. Nutzers formulieren ("Die Tuer oeffnet sich
>   erst nach dem Schalter"), nicht als Code-Beschreibung. Dateinamen oder Werte
>   nur, wenn man sie spaeter wiederfinden muss (neue Datendatei, neues
>   Werkzeug, neue Taste).
> - Geaenderte Regeln und Arbeitsweisen ausdruecklich nennen ("Regel 8
>   geaendert: ...").
> - Entscheidungen des Nutzers festhalten, wenn sie eine fruehere Fassung
>   ersetzen ("Gegner prallen am Schild ab (vorher liefen sie hindurch)").
> - Optional am Ende: "Geprueft: ..." (was die KI selbst getestet hat).
> - Was technisch im Detail passiert ist, steht in Git; was jetzt gilt, steht
>   in der Projektdokumentation. Das Protokoll wiederholt beides nicht.

**v0.55 - 2026-11-14: Blasen-Shader auffaelliger, Seifenblasen-Rand**

- Langsam: Woelbung, traege Ringwellen, kuehler Schimmer; schnell: Zeilenzittern, Unschaerfe nach aussen, starke Farbtrennung; Rand: Zug zur Randlinie und schillernder Film; farbiger Kreis entfaellt.

**v0.54 - 2026-11-14: Elektromagnet: Anziehen/Abstossen, Drehung, Breite**

- Modus Anziehen oder Abstossen (Feldlinien fliessen passend), Feldrichtung folgt der Drehung, `field_width` verbreitert Sprite, Kollision und Feld; Kraft beim Professor in beliebiger Richtung (`apply_magnet_force`).

**v0.53 - 2026-11-14: Rohre verbinden sich beim Malen**

- Rohr-Ebenen mit eigenem Skript: beliebiges Rohr-Tile malen, Form und Variante werden automatisch gesetzt (auch beim Loeschen).

**v0.52 - 2026-11-14: Aseprite-Quellen fuer Intro und Ende**

- Elf Panels als .aseprite mit Ebenen (Hintergrund, Figuren, Effekte) und Frames in `graphics/source/comic/`, im Aseprite-Sync als Eintraege nur mit Sheet; Intro und Ende lesen die Bilderzahl aus dem Sheet.

**v0.51 - 2026-11-13: Lineare Level, Sandbox**

- Bereiche gestrichen: Level heissen `level_01` (Werkstatt) bis `level_05`; `level_sentry_01` des Nutzers ist jetzt `level_02`.
- Testlevel heisst `sandbox` (Spielwiese des Nutzers); eingefrorene Testszenen fuer die automatischen Tests in `scenes/test/fixtures/` (nicht im F1-Menue); Beispiel-Level dorthin verschoben.
- Szenarien `level_03`, `level_04`, `level_05`, `sandbox_all_upgrades`; Baukasten schlaegt `level_NN` vor; Level-Vorlage nicht mehr in der F1-Levelauswahl; Rueckwand-Variante "Elektro" statt "Tesla".

**v0.50 - 2026-11-13: Schritt 23: Ende und Abspann**

- Comic: Pizza-Uebergabe, Keycard funktioniert doch (gruen), Kinnlade; Fahrstuhlfahrt nach unten mit Pizza und laufenden Credits (`dialogues/credits.json`), THE END mit Klon-Zahl, Taste zum Titel, Esc springt ans Ende.
- Vorlaeufiger Endbildschirm entfernt; Marke `story_finished`.

**v0.49 - 2026-11-13: Schritt 22: Intro-Comic**

- Vier Szenen ohne Text, sieben animierte Panels (Platzhalter-Pixelart), Klick fuer Klick, Esc ueberspringt; erscheint nach New Game, danach das erste Level.

**v0.48 - 2026-11-13: Schritt 21: Teslakammer, Elektromagnet**

- Elektromagnet (`magnet`): Takt, Warnflackern, zieht den Professor nach oben, Schweben, Signal-Empfaenger, Zeitblase; im Baukasten.
- Tesla-Rueckwand (blau, Kupferspulen), Baukasten-Knopf "Rueckwand Tesla".
- Platzhalter `level_tesla_01` (Laser, Magnetlift, Schrotthaufen Form), Szenario `tesla_01`, Durchlauf-Test.

**v0.47 - 2026-11-13: Schritt 20: Platzhalter Selbstschussanlage 3**

- `level_sentry_03`: Raketen-Fahrt ueber eine Starkstrom-Grube, Schrotthaufen "Radius"; Szenarien `sentry_02`, `sentry_03`; automatischer Durchlauf-Test.

**v0.46 - 2026-11-13: Schritt 19b: Zeitblase als Shader**

- Linse in der Form der Blase: Wobble und chromatische Aberration, Tempo je Zeitstufe, Staerken einstellbar; farbige Flaeche entfaellt, Rand bleibt.

**v0.45 - 2026-11-13: Schritt 19: Grafik der Selbstschussanlage**

- Gelaende-Tiles, Werfer (Geschuetzturm) und Projektil (Rakete) neu gezeichnet.
- Rueckwand in der Level-Vorlage vorbefuellt; Baukasten-Knopf "Rueckwand fuellen" (`BackWall.fill`).

**v0.44 - 2026-11-13: Schritt 18: Sprechblasen-System**

- Zufaellige Sprueche des Professors und Respawn-Spruch mit Klon-Nummer (zaehlt im Spielstand mit); Texte in `dialogues/speech.json`, Einstellungen in `data/speech_settings.tres`.

**v0.43 - 2026-11-13: Schritt 17: Werkstatt als Wimmelbild, Deko, Platzhalter-Level**

- 18 Deko-Requisiten (Atlas `deco_workshop`, teils animiert, Zeitblase) als Bausteine in der Baukasten-Gruppe "Deko".
- Rueckwand-Tileset (Paneele, Gitter, Warnstreifen, Kabelkanal), Ebene `BackWall` in der Vorlage.
- Werkstatt dicht bestueckt (ca. 70 Requisiten, Hintergrundrohre mit Dampf); Wandhinweise mit hellem Schild.
- Platzhalter-Level `level_sentry_02` (Starkstrom-Luecke, Werfer), in der Reihenfolge nach `level_sentry_01`.

**v0.42 - 2026-11-13: Rohre, Wand- und Bodenelemente im Baukasten, Streckenanzeige der Plattform**

- Tileset Rohre (`tileset_pipes`) mit Autotiling, vorn mit Kollision, hinten als Deko; Ebenen `PipesFront`/`PipesBack` in der Level-Vorlage (Schritt 19a, Platzhalter-Grafik).
- Baustein Dampfaustritt (`steam_vent`), Takt laeuft mit der Zeitblase.
- Wand- und Bodenelemente (`terrain_block`: Boden, Wand, Block, Steg) mit Groesse in Tiles.
- Baukasten: Mal-Knoepfe fuer Boden, Rohre vorn und hinten; neue Gruppen; Einrasten auf 16 px.
- Fliegende Plattform zeigt im Editor Strecke, Wendepunkt und Startposition.

**v0.41 - 2026-11-13: Baukasten-Leiste im Editor**

- Editor-Plugin `addons/building_blocks/`: Reiter "Baukasten" rechts neben dem Inspector mit allen Bausteinen (Vorschaubild, Tooltip, Ziehen oder Doppelklick), "Neues Level anlegen" (geerbte Szene, Eintrag in die Reihenfolge) und "Testlauf starten" (Testmodus, wahlweise alle Upgrades).
- Bausteine-Liste in `data/building_blocks.json`; Schnellstart ueber `user://dev_quickstart.json` im Entwickler-Menue.

**v0.40 - 2026-11-13: Schritt 17 begonnen: Grundgerueste der Level**

- `level_workshop` (Tutorial-Hinweise in Reihenfolge, Fahrstuhl, Sprungblock, Platz fuer das Pflichtraetsel) und leeres `level_sentry_01`; Levelreihenfolge jetzt Werkstatt -> Selbstschussanlage 1, Beispiel-Level nur noch fuer Tests.
- Szenario `new_game` startet in der Werkstatt.
- Titelbildschirm: 0,3 s Eingabesperre nach dem Erscheinen (verhindert versehentliches New Game).

**v0.39 - 2026-11-13: Schritt 16a: Bausteine fuer Werkstatt und Tutorial**

- Eingabe-Aktion `interact` (E), Grundbaustein `Interactable` mit schwebender E-Tastenkappe.
- Fahrstuhl (`elevator`): Keycard-Leser blinkt rot, E = Sprechblase "Keycard geroestet" (Text in `dialogues/speech.json`, Wortlaut als Vorschlag).
- Einfache Sprechblase (`SpeechBubble`) bis Schritt 18; Textlader `GameTexts`.
- Wandhinweis (`wall_hint`): aufgemalte Tasten und Wort aus `dialogues/hints.json`, Wandfarbe aus der Palette.
- Beispiel-Level 1 mit Fahrstuhl und drei Wandhinweisen.

**v0.38 - 2026-11-13: Schritt 16: Titelbildschirm, Speichern und Laden**

- Titelbildschirm als Hauptszene: New Game (Sicherheitsabfrage bei vorhandenem Spielstand), Continue (ausgegraut ohne Spielstand), Quit (im Browser ausgeblendet); Texte in `dialogues/menu.json`.
- Globales System `SaveGame`: JSON in `user://` mit Version, Level, Upgrades und Marken; automatisch am Levelanfang; sicheres Schreiben, beschaedigte Dateien als `.bak`.
- F1-Menue: Hauptmenue, Test-Szenarien (`data/dev_scenarios/`, mit `based_on`, Testmodus mit eigener Datei), "Save state as scenario"; zwei Spalten.
- Endbildschirm fuehrt zum Titel, Startszene `boot` entfernt.

**v0.37 - 2026-11-12: Schritt 15: Level-Builder und Levelfolge**

- Level-Vorlage `scenes/levels/level_base.tscn` (Raum, Klonstation, Ausgang, Professor, Kamera, UI); neue Level als geerbte Szene, Kameragrenzen automatisch aus dem Boden.
- Ausgang (`level_exit`): Schiebetuer, Professor verschwindet darin, Abblenden ueber das Rastermuster, naechstes Level.
- Levelreihenfolge in `data/level_order.tres`, globales System `LevelFlow`; Hauptszene `scenes/boot.tscn` startet das erste Level, nach dem letzten ein vorlaeufiger Endbildschirm.
- Zwei Beispiel-Level, Bausteine-Tabelle und Anleitung zum Levelbau in der Doku (2.9).

**v0.36 - 2026-11-12: Schritt 14: Schrotthaufen und Upgrades**

- Globales System `Upgrades`: Radius (Drehregler) und Form (Cursor) werden freigeschaltet, bleiben beim Neustart des Levels erhalten, Kennungen fuer den Spielstand.
- Schrotthaufen (`scrap_heap`): funkelt, beim Beruehren wird das Upgrade eingebaut, Funken, Reste bleiben; Einblendung mit Texten aus `dialogues/upgrades.json`.
- Gesperrte Regler: Abdeckplatte statt Drehregler, Oszilloskop ohne Cursor.
- F1-Menue: "Unlock all upgrades", "Reset upgrades". Export-Filter fuer `dialogues/*.json`.
- Testlevel: zwei Schrotthaufen (Stufe: Radius, Block 1: Form).

**v0.35 - 2026-11-12: Schritt 12a: Toedlicher Laser, Lichtschranke blau**

- Toedlicher Laser (`deadly_laser`): Takt mit an, aus, Startversatz, Warnstrahl, optional dauerhaft an; laeuft mit der Zeitblase; Signal-Empfaenger; rot, dick, flackernd.
- Projektile koennen den Strahl aufhalten (Werfer-Parameter `projectiles_block_laser`, Standard aus).
- Lichtschranke auf Blau umgestellt (Strahl und Linse), neuer Platzhalter fuer den Laser-Sender.
- Testlevel: Laser bei x = 304.

**v0.34 - 2026-11-12: Drehregler begrenzt und magnetisch**

- Groesster Radius 128 -> 80 px (untere Haelfte des alten Bereichs); Skala des Drehreglers umfasst den neuen Bereich.
- Drehregler zeigt beim Klicken/Ziehen immer zur Maus (Luecke unten = naeherer Anschlag).
- Oszilloskop wieder mit festem Massstab (groesstes Ei reicht gerade bis an den Rand), kein Herauszoomen mehr noetig.

**v0.33 - 2026-11-12: Oszilloskop: Professor bleibt in der Mitte**

- Kreuz des Professors wieder fest in der Bildschirmmitte, Groesse des Kreises bleibt; nur wenn die Spitze des Eis sonst ueber den Rand ragt, zoomt die Anzeige heraus.

**v0.32 - 2026-11-12: Groessere Darstellung auf dem Oszilloskop**

- Das Ei steht mittig auf dem Bildschirm (Kreuz des Professors rueckt gegen die Streckrichtung), das groesste Ei reicht gerade von Rand zu Rand; der Kreis mit Startradius wird dadurch etwa 1,5-mal so gross.

**v0.31 - 2026-11-12: Kleineres Ei, Oszilloskop zeigt es immer ganz**

- Groesste Streckung 2,5 -> 2 (Ei hoechstens doppelt so lang wie der Kreis).
- Oszilloskop: Massstab aus groesstem Radius und groesster Streckung berechnet, das Ei ist immer vollstaendig zu sehen.

**v0.30 - 2026-11-11: Zeitblase als Ei in Cursorrichtung**

- Die Blase streckt sich in Richtung des Cursors (auch schraeg, z. B. Ecke x = y = 1) statt getrennt je Achse.
- Form ist ein Ei: Halbkreis um den Professor, schmaler Teil (halbe Ellipse) nach aussen. Beruehrungstest ueber das Umriss-Polygon; Oszilloskop zeigt dieselbe Form.

**v0.29 - 2026-11-11: Cursor auf dem Oszilloskop statt Schieberegler**

- Formregler: Die beiden Schieberegler sind entfallen, stattdessen ein in x und y beweglicher Cursor auf dem Oszilloskop (Klicken/Ziehen, Einrasten an den Mittellinien, Rechtsklick = Mitte). Oszilloskop auf 152 x 152 vergroessert.
- Sprungwerte: Die eingestellten Werte entsprechen bereits den Standardwerten, keine Aenderung noetig.

**v0.28 - 2026-11-11: Verzoegerten Absprung zurueckgenommen**

- Ausholen vor dem Sprung wieder entfernt (Steuerung fuehlte sich indirekt an): Sprung startet sofort, Absprung-Bild zeitgesteuert nach dem Abheben (`takeoff_time` 0,1 s wieder in den Animationswerten).

**v0.27 - 2026-11-11: Ausholen vor dem Sprung, Entwurf der Sprung-Bilder**

- Sprung beginnt erst nach dem Absprung-Bild: Ausholzeit `jump_windup_time` (0,1 s) in den Bewegungswerten; Coyote-Sprung und Kante waehrend des Ausholens springen sofort.
- Absprung-Zeit aus den Animationswerten entfernt (jetzt Teil der Bewegung), Landungszeit 0,1 s.
- Entwurf der 5 Sprung-Bilder in einer Kopie der Arbeitsdatei des Nutzers (ausserhalb des Repos), Hilfsebenen ausgefuellt.

**v0.26 - 2026-11-11: Sprunganimation nach Geschwindigkeit**

- Sprung (jetzt 5 Bilder) wird nach der senkrechten Geschwindigkeit gezeigt: Steigen, Hoehepunkt, Fallen; Absprung- und Landungsbild zeitgesteuert.
- Neuer Animator im Professor (`professor_animator.gd`), Werte in `data/professor_animation.tres` (Zeiten, Hoehepunkt-Geschwindigkeit, Bildnummern, Laufschwelle).
- Aseprite-Sync: `play_once` fuer den Sprung entfernt (nicht mehr noetig).

**v0.25 - 2026-11-11: Schritt 13, Formregler und Oszilloskop**

- Zeitblase mit Radius (32 bis 128 px) und einseitiger Streckung je Achse (Ei-Form, bis 2,5-facher Durchmesser); Erfassung und Zeichnung als Ellipse.
- Bedienfeld neu aufgebaut: Zeitregler, Oszilloskop (Leuchtspur der Blasenform, Tempo je Zeitstufe), vertikaler und horizontaler Schieberegler, Drehregler fuer den Radius; Rechtsklick setzt zurueck, Schieber rasten in der Mitte ein.
- Grenzen und Einrasten in `data/time_bubble_settings.tres`.

**v0.24 - 2026-11-11: Konzept Intro, Tutorial und neue Bausteine (nur Doku)**

- Intro als Comic zum Durchklicken ohne Text, vier Szenen; neue Pointe am Ende (Keycard war nie kaputt) (3.5).
- Tutorial-Level in der Werkstatt, Level baut der Nutzer selbst; neue Bausteine Wandhinweis, Interaktionstaste E, Fahrstuhl, Rohre-Tileset (2.2, 2.9).
- Toedlicher Laser im Takt geplant, Lichtschranke wird blau (2.4).
- Zeitblase spaeter als Shader mit Wobble und chromatischer Aberration (2.3, 1.7, 1.11).
- Neue Regel 17: Zeiten jedes Bausteins im Inspector einstellbar, mit Startversatz (1.4).
- Aufgabenliste: neue Schritte 12a, 16a, 19a, 19b; Schritte 17, 22, 23 angepasst.
- Aseprite-Sync: Professor exportiert wieder alle beim Speichern sichtbaren Ebenen, auch Hilfsebenen (zum Testen gewollt); `layers` bleibt als Option.

**v0.23 - 2026-11-09: Schritt 12, Zeitschaltuhr**

- Neu: Zeitschaltuhr (`time_switch`): Signal startet einen Countdown, sendet beim Start und beim Ablauf je ein Signal an ihre Ziele; Restzeit als Tortenstueck auf dem Ziffernblatt; reagiert auf die Zeitblase; Optionen Neustart, Autostart, Wiederholen.
- Testlevel: Trefferflaeche -> Zeitschaltuhr -> Tuer (2,5 s offen).
- Aseprite-Sync: Option `layers`, exportiert nur die Ebene `charakter`, auch wenn sie beim Speichern ausgeblendet ist (vorher landeten eingeblendete Hilfsebenen im Spiel).

**v0.22 - 2026-11-09: Sprunganimation, eigene Arbeitsdatei fuer den Sync**

- Sprunganimation (Platzhalter des Nutzers, 8 Bilder): laeuft in der Luft einmal ab dem Absprung und bleibt auf dem letzten Bild.
- Aseprite-Sync: `play_once` fuer einmalige Animationen (auch Aseprite-"Repeat"); lokale Ueberschreibung `data/aseprite_sync.local.cfg` (nicht im Repo) fuer eine Arbeitsdatei ausserhalb des Projekts, die beim Export ins Projekt kopiert wird.

**v0.21 - 2026-11-09: Aseprite-Sync**

- Editor-Plugin `addons/aseprite_sync`: exportiert die Aseprite-Datei des Professors beim Speichern automatisch als Sheet plus JSON und baut die SpriteFrames neu (Tags = Animationen, Bilddauern aus Aseprite).
- Live-Nachladen im laufenden Spiel (nur Debug-Start aus dem Editor).
- Liste der Dateien in `data/aseprite_sync.cfg`.

**v0.20 - 2026-11-09: Nachbesserungen Schritt 11**

- Fliegende Plattformen von unten durchspringbar (Einweg-Kollision).
- Farbige Umrandung zeitmanipulierter Objekte nur noch per F1-Schalter "Time markers" (Standard aus).
- Projektil-Werfer mit Ladebalken, der sich bis zum naechsten Schuss fuellt und auf die Zeitblase reagiert; Werfer-Sprite mit Fenster dafuer.
- Pendel: Kugel-Bild dreht sich nicht mehr mit.

**v0.19 - 2026-11-09: Schritt 11, Pendel und rotierende Gefahr**

- Neu: Pendel (`pendulum`) mit Stachelkugel, schwingt oder dreht sich; Laenge, Ausschlag, Periode, Startstellung und Drehrichtung im Inspector; reagiert auf die Zeitblase; im Editor sichtbar.
- Lichtschranken werden auch von Projektilen ausgeloest; Mitfliegen zaehlt als ein Durchqueren.
- Testlevel: Pendel unter Block 2, rotierende Stachelkugel am Boden vor der Tuer.

**v0.18 - 2026-11-09: Heller Testhintergrund, neue Bewegungswerte**

- Testlevel bekommt einen hellen Hintergrund (`b2ba90`, Node `TestBackground`), nur zum Testen; echte Level behalten die dunkle Grundfarbe.
- Bewegungswerte vom Nutzer eingestellt und als Standard uebernommen: Lauftempo 200 px/s, Steigzeit 0,35 s, hoechste Fallgeschwindigkeit 1000 px/s, kleiner Sprung x 0,6.

**v0.17 - 2026-11-09: Laufanimation, Projektil-Fehlbild, Mausrad**

- Professor-Sprite vom Nutzer aktualisiert: Idle neu, Laufanimation (8 Frames) dazu; Umschalten Idle/Lauf im Professor-Skript.
- Fehler behoben: Neue Projektile standen fuer ein Bild bei (0, 0); der Werfer setzt die Position jetzt vor dem Einhaengen.
- Zeitstufe zusaetzlich mit Shift + Mausrad einstellbar (hoch = schneller, runter = langsamer).

**v0.16 - 2026-11-08: Schritt 10, Trefferflaeche und Tuer**

- Neu: Trefferflaeche (`impact_switch`): Projektile loesen sie aus, sie sendet ein Signal an ihre Ziele und zeigt kurz Funken.
- Neu: Tuer (`door`): Signal-Empfaenger, reagiert auf die Zeitblase, wartet beim Schliessen, wenn jemand im Weg steht.
- Projektil meldet dem getroffenen Objekt den Aufprall (`on_projectile_hit()`).
- Senden an Ziele in `SignalSender` ausgelagert, Lichtschranke nutzt es ebenfalls.
- Testlevel: Tuer mit Sturz links der Lichtschranke, Trefferflaeche an der Prellwand; das Boden-Projektil schaltet die Tuer im Takt.

**v0.15 - 2026-11-08: Schritt 9 - Projektil und Projektil-Werfer**

- Werfer feuern im einstellbaren Takt grosse Projektile nach links oder
  rechts; Projektil und Werfer-Takt reagieren auf die Zeitblase.
- Auf dem Projektil kann man stehen und mitfliegen; seitliche Beruehrung ist
  toedlich, der Stoss von unten nicht; beim Aufprall verschwindet es.
- Neue Kollisionsebene 3 `projectile`; `Hazard` prueft jetzt jeden
  Physik-Schritt und erlaubt Ausnahmen.
- Testlevel: Werfer hoch oben (Mitfliegen ueber das Level) und am Boden
  rechts (mit Prellwand).
- Geprueft: automatischer Test (14 Pruefungen), Bildaufnahme, bisherige
  Tests, Palette, Exporte.

**v0.14 - 2026-11-07: Schritt 8 - Entwickler-Menue (F1)**

- F1 oeffnet das Entwickler-Menue (nur beim Start aus dem Editor):
  Unverwundbar, Level neu starten, Level-Auswahl.
- Strg + Linksklick setzt den Professor an die Mausposition.
- Standardschrift ohne Kantenglaettung, damit auch Text nur Palettenfarben
  hat.
- "Alle Upgrades" und Test-Szenarien folgen, sobald es Upgrades
  (Schritt 14) und Spielstaende (Schritt 16) gibt.
- Geprueft: automatischer Test (9 Pruefungen), Farbpruefung der
  Bildaufnahme (keine Fremdfarben), bisherige Tests, Exporte.

**v0.13 - 2026-11-07: Schritt 7 - Tod und Klonstation**

- Das Level beginnt in der Klonstation: Der Professor erscheint mit
  Klon-Strahl, kurz ohne Steuerung.
- Neue Gefahr Starkstrom-Bodenplatte (Luecke im Boden); Beruehrung ist
  toedlich.
- Tod: Professor flackert und verschwindet, nach kurzer Pause startet das
  Level neu an der Klonstation.
- Baustein `Hazard` fuer alle kuenftigen toedlichen Objekte.
- Festlegung: Nach dem Tod startet die Zeitstufe wieder auf normal.
- Geprueft: automatischer Test (10 Pruefungen: Erscheinen, Sperre, Tod,
  Neustart, Sprung ueber die Luecke), bisherige Tests, Bildaufnahmen,
  Palette, Exporte.

**v0.12 - 2026-11-07: Schritt 6 - Bedienfeld des Time Shifters**

- Shift halten oeffnet das Bedienfeld gross in der Mitte, das Spiel
  pausiert; loslassen schliesst es.
- Zeitregler wie eine Tankanzeige: per Mausklick oder Ziehen der Nadel
  langsam, normal oder schnell waehlen.
- Kleines Symbol oben links zeigt die aktuelle Stufe (1, 2, 3 Pfeile in der
  Farbe der Stufe).
- Die vorlaeufigen Tasten 1/2/3 sind entfallen.
- Geprueft: automatischer Test (12 Pruefungen: Pause, Klicks, Ziehen,
  Nadel, Symbol, Weiterlaufen), Bildaufnahmen, bisherige Tests, Palette,
  Exporte.

**v0.11 - 2026-11-07: Schritte 5 und 5a - Zeitblase und Lichtschranke**

- Zeitblase um den Professor mit drei Stufen (langsam, normal, schnell);
  Werte in `data/time_bubble_settings.tres`.
- Objekte, die die Blase beruehren, laufen langsamer (x 0,3) oder schneller
  (x 2) und bekommen einen Rahmen in der Farbe der Stufe.
- Erstes Spielobjekt: fliegende Plattform (`scenes/objects/`), man kann
  darauf mitfahren; zwei Stueck im Testlevel.
- Im Testlevel vorlaeufig Tasten 1/2/3 zum Umschalten der Stufe.
- Erstes echtes Professor-Sprite (vom Nutzer) mit Idle-Animation ersetzt
  den Platzhalter. Festlegung: Die Figur bleibt gross (ca. 30 x 57 px).
- Alles an die neue Groesse angepasst: Kollision 18 x 50, Laufen 160 px/s,
  Sprung ca. 100 px, Zeitblase Radius 80, Plattformen 64 px breit;
  Testlevel neu aufgeteilt (Stufe 3 Tiles, Bloecke mit 4 Tiles Platz
  darunter). Bisherige Werte (Schritt 4) dadurch ersetzt.
- Aufloesung auf 960 x 540 erhoeht (Fenster 1440 x 810, vorher 480 x 270;
  640 x 360 war ein Zwischenschritt), damit trotz grosser Figur viel Platz
  fuer Raetsel bleibt; Testlevel jetzt 80 x 34 Tiles.
- Neues Objekt Lichtschranke (Schritt 5a): Durchlaufen schaltet Ziele um,
  ein oder aus, auch als Einmal-Ausloeser. Fliegende Plattform kann jetzt
  warten (`active`) und an den Enden pausieren (`wait_time`).
- Geprueft: automatischer Test (12 Pruefungen, u. a. Tempo je Stufe, nur
  beruehrte Plattform betroffen, Beruehrung am Rand, Mitfahren),
  Bewegungstest und Erreichbarkeit im neuen Testlevel (inkl. Durchlaufen
  unter Bloecken), Lichtschranke (9 Pruefungen, Kante nur mit Plattform
  erreichbar), Bildaufnahmen, Palette, Exporte.

**v0.10 - 2026-11-05: Schritt 4 - Professor laeuft und springt**

- Platzhalter-Professor (16 x 32, Aseprite) mit Laufen (A/D) und Springen
  (Leertaste): kurz tippen = kleiner Sprung, Coyote Time, Sprungpuffer.
- Alle Bewegungswerte in der Datendatei `data/professor_movement.tres`.
- Kamera folgt dem Professor weich und bleibt in den Levelgrenzen; im
  Testlevel steht sie senkrecht fest (vorher 1-2 px Versatz beim Springen).
- Schwebende Bloecke im Testlevel tiefer bzw. naeher gesetzt, damit sie
  erreichbar sind.
- Geprueft: automatischer Test mit simulierten Tasten (11 Pruefungen, u. a.
  Sprunghoehe, kleiner Sprung, Coyote Time, Sprungpuffer, Kamera) und
  Erreichbarkeit der Bloecke; Palette; Exporte.

**v0.9 - 2026-11-05: Schritt 3 - Testlevel mit Boden und Kamera**

- Neues Testlevel (`scenes/test/test_level.tscn`, zwei Bildschirme breit)
  mit Boden, Waenden, Stufe und schwebenden Bloecken ist jetzt die
  Startszene; die Export-Testszene ist entfernt.
- Platzhalter-Tileset mit drei Tiles, erstellt in Aseprite aus der
  Palette; Tiles haben Kollision auf Ebene 1 "world".
- Kamera mit Grenzen am Levelrand, laeuft im Physik-Takt.
- Neues Werkzeug `tools/check_palette.gd` prueft alle Grafiken auf die
  Palette.
- Geprueft: Bildaufnahme des Levels, Palettenpruefung (auch Gegenprobe mit
  falscher Farbe), Exporte fuer Browser und Windows ohne Fehler.

**v0.8 - 2026-11-04: Schritt 2 - Export fuer Browser und Windows**

- Export-Voreinstellungen "Web" (ohne Threads, fuer itch.io) und "Windows"
  (eine Exe) angelegt; Ausgabe nach `build/`.
- Vorlaeufige Testszene zeigt Plattform und Aufloesung an.
- Neue strikte Regel: nur Farben der Palette Resurrect 64
  (`graphics/palettes/`); Startbildschirm deshalb ohne Godot-Logo in
  Palettenfarbe. Ausnahme: Die Zeitblase darf halbtransparent sein
  (Mischfarben erlaubt, voraussichtlich als Shader).
- Geprueft: beide Exporte ohne Fehler; Windows-Build startet; Web-Export
  wird lokal ausgeliefert. Nutzer hat Browser und Windows erfolgreich
  getestet.

**v0.7 - 2026-11-04: Schritt 1 - Projekt anlegen**

- Godot-Projekt "Time Shifter" angelegt (Godot 4.8-dev6).
- Einstellungen: 480 x 270, Fenster 960 x 540, Skalierung `canvas_items`
  mit festem Seitenverhaeltnis, scharfe Pixel, Renderer Compatibility,
  Physik-Interpolation an.
- Geprueft: Projekt laedt ohne Fehler; alle Einstellungen per Skript
  ausgelesen und bestaetigt.

**v0.6 - 2026-11-04: Aufgabenliste erstellt**

- Aufgabenliste mit 26 Schritten in vier Meilensteinen bis zur Abgabe
  (Fundament 10.11., Vertical Slice 17.11., Inhalt und Grafik 24.11., Ton und
  Abgabe 28.11., Puffer bis 01.12.).
- Regel: Haengt ein Meilenstein deutlich zurueck, wird der Umfang gekuerzt,
  nicht der Puffer.

**v0.5 - 2026-11-04: Festlegung: Titel, Sprache, Aufloesung, Arbeitsweise**

- Arbeitstitel "Time Shifter".
- Spiel nur auf Englisch; Doku und Code-Kommentare bleiben Deutsch.
- Pixel Art in 480 x 270 mit 16er-Tiles, Renderer Compatibility.
- Kenntnisstand des Nutzers eingetragen (erste kleine Godot-Spiele,
  Basiskenntnisse GDScript).
- Commit erst, wenn der Nutzer mit einem Schritt zufrieden ist; nicht jeder
  Teilschritt einzeln.

**v0.4 - 2026-11-04: Festlegung: Spielkonzept aus dem Brainstorming**

- Thema der Jam: SHIFT; Umsetzung als "Time Shifter" mit Shift-Taste als
  "Kupplung".
- Spielkonzept: humorvoller 2D-Puzzle-Plattformer in Pixel Art; ein
  Professor steuert eine formbare Zeitblase, um aus seinem Labor nach oben
  zur Pizza zu kommen.
- Mechaniken, Spielobjekte, Steuerung (vorlaeufig), Klonstation als
  Checkpoint, Speichern und Titelbildschirm festgehalten.
- Story mit Intro, Bereichen (Werkstatt, Selbstschussanlage, Teslakammer)
  und Fahrstuhl-Abspann eingetragen; Glossar angelegt.

**v0.3 - 2026-11-01: Ordnerstruktur angelegt**

- Ordner aus 1.5 angelegt (Szenen, Skripte, Grafik, Audio, Schriften, Daten,
  Texte, Ablage `_inbox/`, Hilfsskripte `tools/`); noch kein Godot-Projekt.
- Blender 5.1 und Aseprite 1.3.18 als Werkzeuge eingetragen; ob sie genutzt
  werden, entscheidet sich mit dem Thema.

**v0.2 - 2026-11-01: Festlegung: Engine-Version und Zielplattformen**

- Engine bleibt bewusst bei Godot 4.8-dev6 (kein Wechsel auf Beta oder
  Stable ohne Absprache).
- Zielplattformen: Browser (Web-Export auf itch.io) und Windows-PC.

**v0.1 - 2026-11-01: Projektstart (Vorbereitung)**

- Oeffentliches Repo eingerichtet, Teilnahme an der Game Off 2026 erfolgt;
  Termine und Jam-Regeln festgehalten (1.11).
- Strikte Vorgabe: keine persoenlichen Daten im oeffentlichen Repo, einzige
  Kennung ist das Pseudonym "Nidrakon" (neue Regel 15, Abschnitt 1.12).
- Technische Basis: Godot 4.8 (exakte Version offen), GDScript, itch.io.
- Neue Regel 16: Jam-Regeln und Deadline haben Vorrang.
- Arbeitstitel, Leitvision und Aufgabenliste folgen nach Bekanntgabe des
  Themas. Noch kein Code geschrieben.
