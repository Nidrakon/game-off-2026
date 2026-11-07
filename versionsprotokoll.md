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
