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
