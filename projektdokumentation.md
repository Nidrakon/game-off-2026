# Projektdokumentation: Time Shifter

> **STRIKTE VORGABE: Das Repository ist oeffentlich. Keine persoenlichen
> oder privaten Informationen.** Kein echter Name, keine E-Mail-Adresse,
> keine Telefonnummer, keine Adresse, keine sonstigen persoenlichen Daten,
> weder in Code, Doku, Assets, Commits noch auf der Store-Seite. Einzige
> erlaubte Kennung ist das Pseudonym **Nidrakon**. Details: Regel 15 in 1.4
> und Abschnitt 1.12.

> **So wird diese Vorlage benutzt (Block nach dem Ausfuellen loeschen)**
>
> - Datei als `projektdokumentation.md` in den Projektordner kopieren,
>   daneben `versionsprotokoll.md` (eigene Vorlage).
> - Kapitel fuer Kapitel gemeinsam mit der KI ausfuellen. `[ECKIGE KLAMMERN]`
>   sind Platzhalter. Abschnitte, die nicht gebraucht werden, streichen.
> - Zeilen mit **Ausfuellhinweis** beim Ausfuellen loeschen. Sie beschreiben,
>   was in den Abschnitt gehoert, und halten Erfahrungen aus frueheren
>   Projekten fest.
> - Was noch nicht entschieden ist, kommt unter **Offene Punkte** im
>   jeweiligen Abschnitt. Die Doku darf luecken haben und waechst mit dem
>   Projekt.

**Wo steht was**

| Datei | Inhalt |
| --- | --- |
| `projektdokumentation.md` | Diese Datei: alles Verbindliche (Regeln, Technik, Mechaniken, Story, Aufgaben, aktueller Stand) |
| `versionsprotokoll.md` | Was sich wann geaendert hat (neueste Eintraege oben) |
| `README.md` | Oeffentliche Kurzinfo zum Spiel auf GitHub (Credits, KI-Hinweis) |
| `CLAUDE.md` | Einstieg fuer die KI: verweist auf diese Doku und die strikten Vorgaben |
| `CLAUDE.local.md` | Nur lokal, nicht im Repo: rechnerspezifische Angaben (z. B. Programmpfade) |
| `_inbox/` | Ablage fuer neue Assets und Notizen des Nutzers (siehe 1.7) |

> **Ausfuellhinweis:** Diese Datei ist das Gedaechtnis des Projekts. Der Chat
> kann verloren gehen oder wird bei langen Sitzungen zusammengefasst; was
> hier steht, bleibt. Deshalb gehoert jede dauerhafte Vereinbarung hierher.
> Gleichzeitig liest die KI die Datei vor jedem Schritt: Sie soll
> beschreiben, *was gilt*, nicht *wie es dazu kam* (das steht im
> Versionsprotokoll und in Git). Wird ein Bereich sehr gross (z. B. die
> komplette Handlung), wandert er in eine eigene Datei, und hier bleibt ein
> kurzer Verweis.

---

## Kapitel 1: Grundlagen und technisches Fundament

### 1.1 Arbeitstitel

**Time Shifter** (festgelegt am 04.11.2026)

Der Titel ist ausdruecklich als Arbeitstitel zu verstehen und kann sich im
Lauf der Entwicklung noch aendern.

### 1.2 Leitvision

Ein humorvoller 2D-Puzzle-Plattformer in Pixel Art: Ein verpeilter
Professor muss mit seiner Zeitmaschine, dem **Time Shifter**, aus seinem
eigenen, mit Fallen vollgestopften unterirdischen Labor nach oben
entkommen, weil dort seine Pizza geliefert wird.

Kern der Idee:

- **Lokale, formbare Zeitblase:** Der Time Shifter verlangsamt oder
  beschleunigt die Zeit in einer Blase um den Professor. Nur die Umgebung
  wird beeinflusst, nicht er selbst. Form und Lage der Blase lassen sich
  einstellen.
- **Grundton durchgehend humorvoll:** Der Professor wird Opfer seiner eigenen
  Sicherheitsvorkehrungen und kommentiert das mit trockenen Spruechen.
- **Wichtigstes Spielelement:** Raetsel und Geschicklichkeit mit Objekten,
  deren Tempo man veraendert (Projektile, Pendel, Plattformen, Timer).

Offene Punkte:

- Look, Sound und Musik.

### 1.3 Technische Basis

| Bereich | Festlegung |
| --- | --- |
| Engine | Godot **4.8-dev6** (bewusst diese Entwicklungsversion, festgelegt am 01.11.2026; kein Wechsel ohne Absprache). Export-Templates dafuer sind installiert |
| Programmiersprache | GDScript |
| Zielplattformen | Browser (Web-Export, auf itch.io direkt spielbar) und Windows-PC (Download), festgelegt am 01.11.2026 |
| Veroeffentlichung | itch.io, als Beitrag zur Game Off 2026 (siehe 1.11) |
| Eingabegeraete | Tastatur und Maus (siehe 2.2). Controller und Touch: [offen] |
| Sprachen im Spiel | Nur Englisch (festgelegt am 04.11.2026) |
| Grafikstil | Pixel Art |
| Perspektive | 2D seitlich (Side-Scroller) |
| Tile-Groesse | 16 x 16 px; Professor ca. 16 x 32 px (zwei Tiles hoch) |
| Basisaufloesung | 480 x 270 px (16:9; ganzzahlig skalierbar: x2 = 960 x 540, x4 = 1920 x 1080) |
| Skalierung | Stretch-Modus `canvas_items`, Seitenverhaeltnis `keep` (schwarze Raender statt Verzerrung) |
| Texturfilter | Nearest (scharfe Pixel) |
| Renderer | Compatibility (laeuft am zuverlaessigsten im Browser) |
| Fenstermodus | Entwicklung: Fenster 960 x 540 (x2). Fertiges Spiel: Windows Vollbild; Browser eingebettet in 960 x 540 mit Vollbild-Knopf |
| Standardschrift | [Datei, Groesse, Lizenz] |
| Versionsverwaltung | Git, oeffentliches Repo auf GitHub (`Nidrakon/game-off-2026`), Branch `main`, Autor "Nidrakon" mit GitHub-noreply-Adresse (nie eine private E-Mail, siehe 1.12). Die KI fuehrt Pull, Commit, Push, Merge und Pull Requests aus |
| Export | [Voreinstellungen und Zielordner, siehe Kapitel 6] |

> **Ausfuellhinweis:** Zielplattformen, Eingabegeraete und Sprachen frueh
> festlegen, auch wenn sie erst spaeter kommen. Wer von Anfang an weiss,
> dass es eine zweite Sprache oder Touch geben soll, legt Texte und
> Tastenhinweise gleich passend an; nachtraeglich muss man alles anfassen.
> Die Tabelle bleibt knapp (ein bis zwei Zeilen je Feld); Details stehen in
> dem Kapitel, zu dem sie gehoeren.
>
> Erfahrung bei Pixel Art in Godot: Ruckeln und Pixelzittern beim Scrollen
> vermeidet man mit Stretch-Modus `canvas_items` (gezeichnet wird in
> Bildschirmaufloesung), Physik-Interpolation an und einer Kamera, die im
> Physik-Takt nach der Figur nachzieht.

Begruendung Aufloesung und Tiles (Empfehlung der KI, uebernommen am
04.11.2026): 480 x 270 mit 16er-Tiles zeigt ca. 30 x 17 Tiles. Das ist genug
Ueberblick fuer Raetsel, bei denen man Blase, Projektile und Schalter
gleichzeitig sehen muss, und die Pixel bleiben gut erkennbar. 960 x 540 ist
eine uebliche Einbettungsgroesse auf itch.io und genau Faktor 2.

**Abweichungen je Plattform:** [z. B. was im Browser anders ist als unter
Windows; siehe Kapitel 6.]

### 1.4 Regeln fuer die KI

1. **Dokumentation zuerst lesen:** Die KI liest die Projektdokumentation,
   bevor sie Code schreibt oder aendert. Alles darin ist verbindlich. Was
   nicht dokumentiert ist, wird vorgeschlagen und nachgefragt, statt
   ungefragt eingebaut zu werden.
2. **Architektur einhalten:** Die KI haelt sich an die festgelegte
   Systemarchitektur bzw. Ordnerstruktur. Abweichungen werden vorher
   angekuendigt und begruendet, nicht einfach umgesetzt.
3. **Nur bauen, was verlangt ist:** Nichts auf Vorrat. Das Ergebnis muss
   lauffaehig und testbar sein, inklusive kurzer Anleitung, was zu testen
   ist (Arbeitsweise siehe Kapitel 4).
4. **Datengetrieben bauen:** Inhalte (Texte, Items, Level-Daten, Werte,
   Konfigurationen) gehoeren wo immer moeglich in Datendateien statt hart in
   den Code, damit sie spaeter ohne Programmierkenntnisse erweiterbar sind.
   Alle Texte, die im Spiel angezeigt werden, liegen mit einer ID in
   Datendateien (Voraussetzung fuer Lektorat und Uebersetzung).
5. **Modular und uebersichtlich bauen:** Klar getrennte Systeme mit sauberen
   Schnittstellen, viele kleine Dateien bzw. Skripte mit je einer klaren
   Aufgabe statt langer Monolith-Skripte.
6. **Nur aktuelle Engine- bzw. Sprach-Syntax verwenden:** Keine veraltete
   Syntax einer frueheren Engine-Version. Bei Unsicherheit zu einer API
   lieber nachfragen, statt etwas zu erfinden.
7. **Bestehenden Code respektieren:** Bei Fehlermeldungen oder vorhandenem
   Code vom aktuellen Stand ausgehen, nichts unnoetig neu schreiben, was
   bereits funktioniert.
8. **Dokumentation nach jedem Schritt aktualisieren:** Die KI pflegt die
   Aenderungen direkt in `projektdokumentation.md` ein (betroffene Kapitel,
   Aufgabenliste, Aktueller Stand) und ergaenzt einen Eintrag in
   `versionsprotokoll.md`. In der Antwort werden die Doku-Aenderungen
   **nicht** aufgelistet.
9. **Bei Unklarheiten nachfragen statt raten:** Wenn etwas nicht eindeutig
   ist, wird aktiv nachgefragt.
10. **Kenntnisstand beruecksichtigen:** Die KI passt Erklaertiefe und
    Code-Kommentare an den Kenntnisstand des Nutzers an (siehe unten).
11. **Vereinbarungen sofort festhalten:** Jede dauerhafte Anweisung aus dem
    Chat ("ab jetzt immer ...", "generelle Regel: ...", Stilvorgaben,
    Arbeitsablaeufe) traegt die KI sofort in den passenden Abschnitt dieser
    Doku ein, nicht erst am Ende. Der Chat ist nicht dauerhaft, die Doku
    schon.
12. **Selbst pruefen vor der Uebergabe:** Soweit moeglich prueft die KI ihr
    Ergebnis selbst (Start ohne Fehler, automatisierte Testlaeufe,
    Bildaufnahmen). In der Antwort steht, was sie geprueft hat und was nur
    der Nutzer beurteilen kann (Spielgefuehl, Aussehen, Ton).
13. **Bei Pruefauftraegen erst berichten, dann aendern:** Bei Lektorat,
    Review, Fehlersuche oder Analyse meldet die KI zuerst ihre Funde und
    Vorschlaege und aendert erst nach Freigabe.
14. **Eigenstaendig gestalten:** Vorbilder aus anderen Spielen dienen nur
    als Inspiration. Grafiken, Musik, Texte und Figuren werden nicht
    kopiert, sondern eigenstaendig erstellt. Fremde Assets nur mit passender
    Lizenz; die Lizenzdatei liegt neben dem Asset.
15. **Keine persoenlichen Daten (strikt, ohne Ausnahme):** Das Repo ist
    oeffentlich. Die KI schreibt niemals persoenliche oder private
    Informationen in Dateien, Commits, Commit-Nachrichten, Branch-Namen,
    Pull Requests, Issues, Assets oder Store-Texte. Vor jedem Commit prueft
    sie die Aenderungen darauf. Einzelheiten in 1.12.
16. **Jam-Regeln einhalten:** Alles, was die Teilnahme an der Game Off 2026
    gefaehrden koennte (Deadline, oeffentliches Repo, Lizenzen), hat Vorrang.
    Die KI weist rechtzeitig auf die Deadline hin (siehe 1.11).

**Kenntnisstand des Nutzers:** Erste kleine Spiele mit Godot entwickelt,
Basiskenntnisse in GDScript. Daraus folgt:

- Erklaerungen in einfacher Sprache; Godot-Grundbegriffe (Node, Szene,
  Signal) werden vorausgesetzt, fortgeschrittene Begriffe (z. B. Shader,
  Resource, Autoload, Physik-Ebenen) beim ersten Auftreten kurz erklaert.
- Code-Kommentare (auf Deutsch) erklaeren, *was* ein Abschnitt tut und
  *warum*, besonders bei nicht offensichtlicher Logik.
- Schritte im Editor (wo klicken, welche Einstellung) konkret beschreiben,
  wenn der Nutzer selbst etwas im Editor tun soll.

**Antwortform nach einem Schritt:**

- Kurz, was gebaut bzw. geaendert wurde.
- **Neu zu testen:** nur das, was neu ist. Grundbedienung (Editor oeffnen,
  Spiel starten) wird nicht jedes Mal erklaert.
- **Annahmen:** wenn die KI selbst entschieden hat (z. B. im Block-Modus,
  siehe 4.3), jede Annahme einzeln, damit der Nutzer sie pruefen kann.
- Am Ende eine **Kurzinfo zum naechsten Schritt** (Nummer und Titel).

**Ablaeufe rund um jeden Schritt:**

- **Commit:** erst, wenn der Nutzer mit einem Schritt zufrieden ist
  (festgelegt am 04.11.2026). Nicht jeder kleine Teilschritt wird committet;
  Nachbesserungen am selben Schritt kommen in denselben Commit. Nach dem
  Commit wird gepusht. Commit-Nachricht auf Englisch (oeffentliches Repo),
  Muster "Step 12: Title (v0.x)".
- **Editor:** [z. B. Nach jedem Schritt oeffnet die KI den Editor mit dem
  Projekt, falls er nicht laeuft.]
- **Projektdatei:** Bevor die KI die Projekteinstellungen (`project.godot`)
  direkt aendert, bittet sie, den Editor zu schliessen, weil der Editor die
  Datei sonst beim Speichern ueberschreibt.
- **Spielstand bei Tests:** [z. B. Der Spielstand des Nutzers darf bei
  Testlaeufen geloescht werden / muss gesichert werden. Einstellungen wie
  die Lautstaerke bleiben erhalten.]

### 1.5 Ordnerstruktur

Leitprinzip: Das Projekt soll fuer einen Menschen ohne tiefe
Programmierkenntnisse nachvollziehbar sein. Sprechende Ordnernamen, flache
Struktur, klare Zustaendigkeiten.

```
res://
  _inbox/        # Ablage fuer neue Assets und Notizen, wird von der KI geleert (siehe 1.7)
  scenes/        # Szenen, nach Bereich unterteilt
  scripts/       # Skripte, gespiegelt zur Szenenstruktur
  graphics/      # Grafiken (Unterordner siehe 1.7), Quellen in graphics/source/
  audio/         # Musik (music/), Soundeffekte (sfx/), Quellen in audio/source/
  fonts/         # Schriften mit Lizenzdatei
  data/          # Datendateien (Werte, Level-Listen, Test-Szenarien)
  dialogues/     # Texte, die im Spiel angezeigt werden (je Sprache ein Unterordner)
  tools/         # Hilfsskripte ausserhalb des Spiels, von der Engine ignoriert
```

Angelegt am 01.11.2026. Git speichert keine leeren Ordner; deshalb liegt in
noch leeren Ordnern eine leere Datei `.gitkeep`, die entfernt werden kann,
sobald echte Dateien darin liegen. `_inbox/` und `tools/` enthalten eine
`.gdignore`, damit die Engine sie ignoriert. Da es nur eine Sprache
(Englisch) gibt, liegen die Spieltexte direkt in `dialogues/` ohne
Sprach-Unterordner.

**Globale Systeme (Autoloads):**

| Name | Datei | Aufgabe |
| --- | --- | --- |
| [z. B. `GameState`] | [`scripts/autoload/game_state.gd`] | [Spielfortschritt] |

**Kollisionsebenen:**

| Ebene | Name | Wer liegt darauf |
| --- | --- | --- |
| 1 | `world` | [Terrain, feste Hindernisse] |
| [2] | [`player`] | [Spielfigur] |

Bauprinzip:

- Skripte und Spielelemente in kleinen, logischen Teilen.
- Jede Datei hat eine klar umrissene Aufgabe.
- Einzelne Teile sollen sich aendern lassen, ohne das ganze Projekt zu
  verstehen.

### 1.6 Konventionen

**Sprache:**

- **Englisch** ist alles, was im Projekt einen Namen bekommt: Ordner,
  Dateien, Szenen, Nodes, Skripte, Klassen, Variablen, Funktionen,
  Konstanten, Signale und Daten-Schluessel (IDs). Ebenso alle Texte im
  Spiel und die Commit-Nachrichten.
- **Deutsch** bleiben die Projektdokumentation und Code-Kommentare.
  Entwuerfe fuer Spieltexte duerfen auf Deutsch entstehen; im Spiel stehen
  sie frei uebersetzt auf Englisch (Wortwitz und Ton erhalten).
- Namen der Figuren im Code: Professor = `professor`.

**Code (Engine-Konventionen):**

- Dateinamen und Ordner: `snake_case`
- Variablen und Funktionen: `snake_case`
- Klassen und Node-Namen: `PascalCase`
- Konstanten: `CONSTANT_CASE`
- Private Member: fuehrender Unterstrich (`_internal_counter`)
- Signale: Vergangenheitsform (`jump_started`)

**Kennungen (IDs):** [z. B. Fortschrittsmarken, Text-IDs, Level-IDs:
englisch, `snake_case`, Muster `<bereich>_<was>`]. Einmal vergebene IDs
werden nicht umbenannt, weil Spielstaende und Datendateien darauf verweisen.

**Doku:**

- Festlegungen bekommen ein Datum, wenn es spaeter darauf ankommt
  ("festgelegt am TT.MM.JJJJ").
- Jeder Abschnitt kann eine Liste **Offene Punkte** haben; erledigte Punkte
  werden entfernt.
- [Schreibweise, z. B. Umlaute als ae/oe/ue in Doku und Code-Kommentaren]

### 1.7 Assets

**Ablage (`_inbox/`)**

1. Der Nutzer legt neue Assets aller Art (Grafiken, Musik, Sounds,
   Schriften) oder Notizen als `.md` einfach in `_inbox/` ab. Dateinamen und
   Unterordner sind egal.
2. Auf Zuruf ("Sortiere die Ablage") verschiebt die KI jede Datei in den
   passenden Zielordner und benennt sie nach der Konvention unten um.
   Notizen pflegt sie in die Doku ein (inklusive Aufgabenliste) und loescht
   sie danach.
3. Danach ist `_inbox/` wieder leer.
4. Die KI meldet, was wohin verschoben und wie umbenannt wurde.

Technisch: `_inbox/` enthaelt eine `.gdignore` (die Engine ignoriert den
Ordner, es entstehen keine verwaisten Import-Dateien), sein Inhalt wird
nicht in Git versioniert. Ist unklar, was eine Datei darstellt oder wohin
sie gehoert, fragt die KI nach; die Datei bleibt so lange liegen. Bereits
verwendete Assets werden nur nach Absprache verschoben oder umbenannt, dann
mit allen Verweisen.

**Zielordner**

| Asset-Art | Zielordner |
| --- | --- |
| Figuren-Sprites und Animationen | `graphics/sprites/<character>/` |
| Gegner | `graphics/sprites/enemies/` |
| Feste Objekte | `graphics/sprites/objects/` |
| Aufhebbare Gegenstaende | `graphics/sprites/items/` |
| Tilesets | `graphics/tilesets/` |
| Hintergruende | `graphics/backgrounds/` |
| UI-Grafiken | `graphics/ui/` |
| Musik | `audio/music/` |
| Soundeffekte | `audio/sfx/` |
| Schriften | `fonts/` |

**Namenskonvention**

- Nur Kleinbuchstaben, `snake_case`, keine Leerzeichen oder Sonderzeichen.
- [Englische], sprechende Namen nach dem Muster
  `<type>_<name>_<variant>_<number>`; unnoetige Teile entfallen.
- Nummern immer zweistellig: `_01`, `_02`.
- Animationen als Streifen (Sprite Sheet) enden auf `_sheet`.

| Asset-Art | Muster | Beispiel |
| --- | --- | --- |
| Figuren-Sprite | `<character>_<action>` | `hero_run_sheet.png` |
| Gegner | `enemy_<name>_<action>` | `enemy_slime_walk_sheet.png` |
| Objekt | `object_<name>_<state>` | `object_door_closed.png` |
| Gegenstand | `item_<name>` | `item_key.png` |
| Tileset | `tileset_<theme>` | `tileset_forest.png` |
| Hintergrund | `background_<theme>_<layer>` | `background_forest_sky.png` |
| UI | `ui_<element>` | `ui_cursor.png` |
| UI-Button | `ui_button_<name>_<state>` (`normal`, `hovered`, `pressed`) | `ui_button_play_normal.png` |
| Musik | `music_<place_or_mood>` | `music_title.ogg` |
| Soundeffekt | `sfx_<event>_<number>` | `sfx_jump_01.wav` |
| Schrift | `font_<name>` (Lizenz daneben: `font_<name>_license.txt`) | `font_pixel.ttf` |

**Grafikstil (verbindlich)**

- Farbpalette: [Name und Quelle, z. B. eine Lospec-Palette; Dateien in
  `graphics/palettes/`]. Gilt fuer alle Grafiken und fuer Farben, die im
  Code gesetzt werden. Pruefung: [Werkzeug/Befehl].
- Feste Grundfarben: [Hintergrund, Schrift, Umriss, Hervorhebung].
- Stilregeln: [Lichtrichtung, Umrissfarbe, Abstufungen je Material,
  Verlaeufe ja/nein].
- Bewegung: [z. B. Stauchen und Dehnen beim Springen und Landen].

**Quelldateien (verbindlich):** Die Quelle ist die Datei des
Grafikprogramms (z. B. `.aseprite` in `graphics/source/`), das PNG wird
daraus erzeugt und nie direkt bearbeitet. Export mit [Befehl]. Ablauf fuer
den Nutzer: Quelle oeffnen, aendern, speichern, der KI Bescheid geben.

**Audio (verbindlich)**

- Stil: [z. B. 8 Bit / 16 Bit / orchestral; Stimmung].
- Soundeffekte entstehen mit [Werkzeug], Musik mit [Werkzeug].
- Lautstaerke: [z. B. Voreinstellung niedrig (15 %), weil die meisten Spiele
  zu laut starten; Stufen].
- **Songs mit fester ID:** Jeder Song hat eine Nummer und einen Namen.
  "Song 1", "Lied 1" oder "Theme 1" meint immer denselben Song. IDs werden
  nie neu vergeben.

  | ID | Name | Datei | Wo | Charakter |
  | --- | --- | --- | --- | --- |
  | 1 | [Name] | `music_[...]` | [z. B. Titel, Hauptmenue] | [Tonart, Tempo, Stimmung] |

- Soundeffekte und wo sie klingen: [Liste].

**Dateiformate:** Grafiken `.png`, Musik `.ogg` (klein, gut als Schleife),
Soundeffekte `.wav` (kurz, ohne Verzoegerung), Schriften `.ttf`/`.otf`.
Andere Formate: Die KI weist darauf hin und fragt nach.

### 1.8 Werkzeuge

**Programme auf dem Rechner des Nutzers**

Konkrete Pfade auf dem Rechner stehen nur in `CLAUDE.local.md` (nicht im
Repo, siehe 1.12).

| Programm | Version | Pfad | Wie die KI es nutzt |
| --- | --- | --- | --- |
| Godot | 4.8-dev6, mit Konsolenfassung | siehe `CLAUDE.local.md` | Headless-Testlaeufe, Editor oeffnen, Export |
| Git | 2.54 | Standardinstallation | Versionsverwaltung |
| GitHub CLI (`gh`) | 2.103 | Standardinstallation | Pull Requests, Repo-Abfragen; angemeldet als Nidrakon |
| Blender | 5.1 | siehe `CLAUDE.local.md` | 3D-Modelle per Python-Skript ohne Fenster erzeugen, Vorschau rendern, als `.glb` exportieren (falls 3D) |
| Aseprite | 1.3.18 | siehe `CLAUDE.local.md` | Pixelart per Skript bzw. Kommandozeile, Export der Quellen nach PNG (falls Pixelart) |
| [Musikprogramm] | [Version] | [Pfad] | [z. B. Projekt rendern] |

**Hilfsskripte im Projekt (`tools/`)**

| Skript | Aufgabe | Aufruf |
| --- | --- | --- |
| [z. B. `export_graphics.py`] | [Quellen exportieren und Palette pruefen] | [`python tools/export_graphics.py [datei]`] |

### 1.9 Entwickler-Werkzeuge (Testen ohne Durchspielen)

> **Ausfuellhinweis:** Frueh einplanen, spaetestens wenn das Spiel mehr als
> ein paar Minuten lang ist. Sonst muss man fuer jeden Test von vorn
> spielen.

Nur beim Start aus dem Editor (Debug-Build) aktiv, im exportierten Spiel
nicht vorhanden.

- **F1** oeffnet das Entwickler-Menue (Spiel pausiert). Im fertigen
  Release-Build fuer den Jam ist es deaktiviert.
- **Direkter Einstieg in ein beliebiges Level.**
- **Alle Time-Shifter-Upgrades freischalten** (siehe 2.3).
- **Test-Szenarien:** gespeicherte Spielzustaende, die per Klick geladen
  werden, so als haette man bis dahin selbst gespielt (alle Marken,
  Levelzustaende, Figuren, Inventar), mit Startpunkt im Level. Die Liste
  scrollt.
- **Testmodus:** Nach dem Laden eines Szenarios wird in eine eigene
  Testdatei gespeichert; der echte Spielstand bleibt unberuehrt.
- **Teleport:** [z. B. Strg + Linksklick] setzt die Figur an die Mausposition.
- **Unverwundbar** (Schalter).
- **Sprung zur Levelauswahl / ins Hauptmenue.**
- **Aktuellen Stand als Szenario speichern.**
- [Weitere, z. B. Clip-Aufnahme fuer Abspann oder Trailer]

**Szenario-Dateien** (`data/dev_scenarios/<kennung>.json`):

```json
{
	"name": "[Anzeigename]",
	"order": 10,
	"based_on": "[andere_kennung]",
	"scene": "res://scenes/levels/[level].tscn",
	"marker": "[NodeName des Startpunkts]",
	"save": { "flags": [], "levels": {}, "characters": [] }
}
```

`based_on` baut auf einem anderen Szenario auf (Ketten wie "Anfang ->
Mitte -> vor dem Boss"); `marker` ist der Name eines Knotens im Level und
uebersteht Umbauten besser als feste Koordinaten.

| Kennung | Name | Stand |
| --- | --- | --- |
| `new_game` | Neues Spiel | frischer Spielstand |

Mit jedem Schritt, der einen neuen Spielabschnitt baut, legt die KI ein
passendes Szenario an.

### 1.10 Feste Bezeichnungen (Glossar)

Begriffe, mit denen Nutzer und KI sich verstaendigen. Wird etwas
umbenannt oder umnummeriert, steht der alte Name hier mit dabei.

| Begriff im Gespraech | Bedeutung / Name im Code |
| --- | --- |
| Professor | Die Spielfigur, verrueckter Erfinder (`professor`) |
| Time Shifter | Die Zeitmaschine, die der Professor traegt, mit Bedienfeld (`time_shifter`) |
| Zeitblase, Blase, Sphaere | Der Bereich um den Professor, in dem die Zeit veraendert ist (`time_bubble`) |
| Zeitstufe | Langsam, normal oder schnell (siehe 2.3) |
| Bedienfeld | Das grosse Reglerfeld des Time Shifters, erscheint bei gehaltener Shift-Taste |
| "Kupplung" | Shift-Taste halten: Bedienfeld einblenden, Spiel pausiert |
| Schrotthaufen | Fundstelle, mit der der Professor den Time Shifter um eine Funktion erweitert (Upgrade) |
| Klonstation | Checkpoint am Anfang jedes Levels (siehe 2.6) |
| Werkstatt | Startbereich ganz unten, zaehlt nicht als eigentlicher Bereich |
| Bereich | Grosser Teil des Labors (z. B. Teslakammer), besteht aus mehreren Leveln |
| Level | Einzelner, abgeschlossener Abschnitt innerhalb eines Bereichs |

### 1.11 Game Jam: Game Off 2026

Das Spiel ist ein Beitrag zur **Game Off 2026** (veranstaltet von GitHub und
Lee Reilly): https://itch.io/jam/game-off-2026. Teilnahme auf itch.io ist
erfolgt (Konto "nidrakon").

**Termine (deutsche Zeit, MEZ):**

| Was | Wann |
| --- | --- |
| Start und Bekanntgabe des Themas | 01.11.2026, 22:37 |
| **Abgabeschluss** (Repo gepusht und Spiel auf itch.io eingereicht) | **01.12.2026, 22:37** (= 13:37 PST) |
| Ende der Abstimmung | 01.01.2027, 22:37 |

**Thema:** **SHIFT**

Bezug zum Thema: ueber "Time Shift". Der Bezug ist eher indirekt, und
Zeitmanipulation ist in Jams verbreitet; die lokale, formbare Blase macht den
Ansatz eigenstaendiger. Damit der Bezug eindeutig wird:

- Das Geraet heisst **Time Shifter**.
- Bedienung ueber die **Shift-Taste** als "Kupplung" wie beim Gangschalten
  (siehe 2.2).
- Option: sichtbare Farb- bzw. Pixelverschiebung innerhalb der Blase.

**Regeln:**

- Spiel waehrend des Novembers bauen; Programmiersprache, Engine und
  Bibliotheken sind frei waehlbar.
- Der Quellcode liegt in einem **oeffentlichen GitHub-Repo** und muss vor dem
  Abgabeschluss gepusht sein.
- Abgabe ueber die Jam-Seite auf itch.io. Danach koennen andere Beitraege
  gespielt und bewertet werden.
- KI-Werkzeuge sind nicht verboten. Im Abgabeformular wird abgefragt, ob KI
  genutzt wurde; das wird wahrheitsgemaess angegeben (Entwicklung mit
  Claude Code). Der Hinweis steht auch in der `README.md`.
- Fremde Assets nur mit passender Lizenz, aufgefuehrt in den Credits der
  `README.md`.

**Bewertungskategorien:** Overall, Gameplay, Graphics, Audio, Innovation,
Theme Interpretation. Daraus folgt: Thema sichtbar umsetzen, und Grafik und
Ton nicht vernachlaessigen.

**Zeitplanung:** Der Umfang wird bewusst klein gehalten. Eine spielbare
Fassung soll frueh stehen; die letzten Tage vor dem Abgabeschluss sind
Puffer fuer Feinschliff, Export und Store-Seite, nicht fuer neue Features.

### 1.12 Datenschutz (strikte Vorgabe)

Festgelegt am 01.11.2026, gilt fuer die gesamte Entwicklung. Das Repo ist
oeffentlich; alles, was dort landet (auch die Git-Historie), ist dauerhaft
fuer jeden sichtbar.

**Verboten in allen veroeffentlichten Inhalten:**

- echter Name (auch Vor- oder Nachname allein), Initialen mit Bezug zur Person
- E-Mail-Adressen, Telefonnummern, Postanschriften
- Wohnort, Arbeitgeber, Alter, Geburtsdatum, Fotos oder sonstige persoenliche
  Details
- Zugangsdaten, Tokens, Schluessel
- lokale Pfade, Benutzernamen des Rechners und andere Angaben zum System des
  Nutzers

**Gilt fuer:** Code und Kommentare, Doku, Datendateien, Assets (auch
Metadaten, z. B. Autor-Feld in Grafik- oder Audiodateien), Screenshots,
Credits, Commit-Nachrichten, Autor-Angaben der Commits, Branch-Namen, Pull
Requests, Issues und die itch.io-Seite.

**Umsetzung:**

- Einzige erlaubte Kennung ist das Pseudonym **Nidrakon** (GitHub, itch.io,
  Credits).
- Git-Autor ist "Nidrakon" mit der GitHub-noreply-Adresse.
- Rechnerspezifisches (z. B. Programmpfade) steht nur in `CLAUDE.local.md`,
  die per `.gitignore` vom Repo ausgeschlossen ist.
- Exporte mit Debug-Informationen und Godot-Ordner `.godot/` kommen nicht ins
  Repo.
- Vor jedem Commit prueft die KI die Aenderungen auf persoenliche Daten.
  Landet doch etwas im Repo, meldet die KI das sofort, statt es still zu
  ueberschreiben, weil es in der Git-Historie erhalten bleibt.

---

## Kapitel 2: Spielmechaniken

### 2.1 Gameplay Loop

1. Level beginnt an der Klonstation (Checkpoint, Spielstand wird
   gespeichert).
2. Der Spieler erkennt Hindernisse und Raetsel (Projektile, Pendel,
   Plattformen, Timer ...).
3. Mit gehaltener Shift-Taste oeffnet er das Bedienfeld (Spiel pausiert)
   und stellt Zeitstufe und Form der Blase ein.
4. Er nutzt die Blase beim Laufen und Springen, um Objekte zu bremsen, zu
   beschleunigen oder zu synchronisieren.
5. Er erreicht den Ausgang, das naechste Level liegt weiter oben. Unterwegs
   erweitern Schrotthaufen den Time Shifter um neue Funktionen.

Wichtige Eigenschaften des Loops:

- Linear, von ganz unten im Labor Etage fuer Etage nach oben.
- Tod fuehrt zurueck an den Anfang des aktuellen Levels (siehe 2.6).
- Keine Begrenzung der Blase durch Energie oder Abklingzeit; die
  Herausforderung kommt allein aus dem Leveldesign.

### 2.2 Steuerung

Status: vorlaeufig festgehalten, kann sich noch aendern.

| Aktion | Eingabe-Aktion im Projekt | Tastatur / Maus | [Controller] | [Touch] |
| --- | --- | --- | --- | --- |
| Nach links laufen | `move_left` | A | [ ] | [ ] |
| Nach rechts laufen | `move_right` | D | [ ] | [ ] |
| Springen | `jump` | Leertaste | [ ] | [ ] |
| Bedienfeld des Time Shifters ("Kupplung") | `time_shifter_panel` | Shift gedrueckt halten | [ ] | [ ] |
| Regler im Bedienfeld bedienen | (Maus-Eingabe auf die Regler) | Maus | [ ] | [ ] |
| [Pause] | `pause` | [offen, z. B. Esc] | [ ] | [ ] |

- **Shift als "Kupplung":** Solange Shift gehalten wird, erscheint das
  Bedienfeld gross in der Bildschirmmitte, und das Spiel im Hintergrund ist
  pausiert. Ohne Shift ist das Bedienfeld ausgeblendet.
- Empfehlung: Im normalen Spiel zeigt ein kleines Symbol die aktuelle
  Zeitstufe. Die Blase selbst ist in der Spielwelt immer sichtbar.
- Offen: Belegung von W und S (bisher nur "WASD" genannt).

Werte der Bewegung (Datendatei `[data/...]`):

| Gruppe | Wert | Standard |
| --- | --- | --- |
| [Laufen] | [Hoechstgeschwindigkeit] | [ ] |
| [Springen] | [Sprunghoehe, Zeit bis zum hoechsten Punkt] | [ ] |
| [Sprunghilfen] | [Coyote Time, Sprungpuffer] | [ ] |

> **Ausfuellhinweis:** Bei Jump'n'Runs bewaehrt: Sprunghoehe und Steigzeit
> festlegen und Schwerkraft daraus berechnen; kurz tippen = kleiner Sprung,
> halten = hoher Sprung; Coyote Time und Sprungpuffer. Laufanimation und
> Geschwindigkeit so abstimmen, dass der aufgesetzte Fuss nicht rutscht.

### 2.3 Kernmechanik: Time Shifter und Zeitblase

Der Professor traegt den Time Shifter bei sich. Er erzeugt eine Blase
(Sphaere) um den Professor, in der die Zeit fuer die Umgebung langsamer
oder schneller laeuft. Der Professor selbst wird **nicht** beeinflusst.

**Bedienfeld (Regler):**

- **Zeitregler mit Anzeige** (Optik aehnlich einer Tankanzeige): drei feste
  Stufen: langsam (links), normal (Mitte), schnell (rechts). Nicht
  stufenlos.
- **Vertikaler Schieberegler:** verformt die Sphaere in Y-Richtung
  (elliptisch) bzw. verschiebt sie exzentrisch nach oben oder unten.
- **Horizontaler Schieberegler:** verformt die Sphaere in X-Richtung bzw.
  verschiebt sie exzentrisch nach links oder rechts. So kann die Blase vom
  Professor weg in eine Richtung zeigen.
- **Drehregler:** Radius der Sphaere.
- **Oszilloskop-Anzeige:** zeigt im XY-Modus als Lissajous-Figur die
  aktuelle Form der Sphaere (Kreis bzw. Ellipse). Die Figur pulsiert oder
  rotiert je nach Zeitstufe langsamer oder schneller.

**Freischalten (festgelegt):** Vier Stellgroessen koennen fummelig werden,
deshalb werden die Regler schrittweise freigeschaltet. Der Professor findet
Schrotthaufen, mit denen er den Time Shifter verbessert und eine neue
Funktion erhaelt. Sie liegen frei platziert, jeweils kurz bevor ein Level die
neue Funktion braucht (nicht an Bereichsgrenzen gebunden). Zu Beginn fehlen
die Schieberegler zur Formung der Sphaere noch.

**Regeln der Zeitblase:**

- Die Blase ist dauerhaft aktiv; auf Stufe "normal" ist sie faktisch aus.
- Keine Begrenzung durch Energie, Abklingzeit o. Ae. Die Level werden so
  gestaltet, dass sie trotzdem anspruchsvoll sind.
- Ein Objekt wird beeinflusst, sobald es die Blase beruehrt (es muss nicht
  vollstaendig drin sein).
- Zusammenhaengende Objekte (z. B. ein Pendel) werden als Ganzes
  beeinflusst.
- Empfehlung: beeinflusste Objekte sichtbar markieren (z. B. farbiger
  Schimmer).

**Werte:** [Datendatei; Tempo-Faktoren der Stufen, Radius-Grenzen,
Verformungs-Grenzen]

**Zusammenspiel:** Jedes Objekt aus 2.4 reagiert auf die Blase; die
Formregler erlauben, gezielt nur einzelne Objekte zu erfassen.

**Umsetzung:** [wird beim Bauen ergaenzt]

Offene Punkte:

- Genaue Reihenfolge der Upgrades.
- Risiken der Regel "Beruehrung genuegt": Die Blase wirkt effektiv groesser
  (relevant bei grossen Projektilen dicht beieinander), moegliches Flackern
  an der Grenze. Alternative: nur den Mittelpunkt pruefen.
- Feinschliff von Steuerung und Bedienfeld.

### 2.4 Spielobjekte, die auf die Zeitblase reagieren

**Projektil**

- Gross, etwa so gross wie der Professor; toedlich bei seitlicher
  Beruehrung.
- Der Professor kann daraufspringen und mitfliegen (Transportplattform).
- Kann Schalter bzw. Oberflaechen treffen und einen elektrischen Impuls
  ausloesen.
- Mitfliegen und Beschleunigen: Man fliegt schneller, reagiert selbst aber
  normal schnell; Chance und Gefahr zugleich.
- Raetselidee Synchronisation: Zwei Projektile muessen gleichzeitig zwei
  Schalter treffen (z. B. fuer eine Tuer). Eines startet frueher oder ist
  schneller und muss verlangsamt werden. Die Formregler helfen, nur ein
  Projektil in die Blase zu nehmen. Empfehlung: kleines Toleranzfenster
  (ca. 0,5 s).
- Levelidee Projektilwand: Projektile fliegen horizontal auf allen Hoehen.
  In der Blase werden sie langsamer, die anderen fliegen weiter, so entsteht
  eine Luecke. Die verlangsamten Projektile bleiben toedlich, koennen aber
  als Trittsteine dienen. Eine exzentrische Blase kann Richtung Wand
  geschoben werden.

**Pendel / rotierende Gefahr**

- Toedliches Objekt an einem Seil, pendelt oder rotiert zu schnell zum
  Passieren; durch Verlangsamen ueberwindbar.
- Ideen fuer Beschleunigung: Ein schneller schwingendes Pendel trifft einen
  Schalter oder zerschlaegt eine Wand; zwei gegenlaeufige Pendel
  synchronisieren, um eine Luecke zu erzeugen.

**Fliegende Plattform**

- Bewegt sich horizontal oder auf beliebiger Bahn; in der Blase schneller
  oder langsamer.
- Sicher und berechenbar, gut fuer Einsteiger-Level.
- Idee: aus der Ferne mit gestreckter Blase abbremsen, um sie zu erreichen,
  dann beschleunigen (z. B. um vor einer sich schliessenden Tuer anzukommen).

**Timer / Zeitschaltuhr / Zeitbombe**

- Laeuft in der Blase langsamer oder schneller; zwei asynchrone Timer
  lassen sich synchronisieren.
- Gut zum Erlernen der Mechanik ohne Gefahr.
- Ideen: Tuer mit Zeitschaltuhr laenger offen halten; Bombe bremsen, um zu
  entkommen, oder beschleunigen, um eine Wand zu sprengen.

**Schalter / Trefferflaechen**

- Werden von Projektilen ausgeloest (elektrischer Impuls) und oeffnen z. B.
  Tueren.

**Magnet (Idee fuer die Teslakammer)**

- Elektromagnet, der rhythmisch an- und ausgeht und per Zeitblase gesteuert
  wird.

**Umfang:** Die Elemente reichen fuer einen Jam. Lieber kombinieren als
neue erfinden.

**Ideenpool Beschleunigung (nur Inspiration, nicht festgelegt):**

- Ranke, die beschleunigt zur Kletterhilfe oder Bruecke waechst.
- Wasserhahn bzw. Tropfstein fuellt ein Becken, schwimmende Plattform steigt.
- Rostige Gitter bzw. Holzbarrieren altern im Zeitraffer und zerfallen.
- Kerze bzw. Zuendschnur brennt schneller ab und loest etwas aus.
- Eisblock schmilzt beschleunigt; Wasser gefriert bei Verlangsamung (nutzt
  beide Richtungen).

Offene Punkte:

- Bisher dominiert das Verlangsamen. Es fehlen Elemente, bei denen
  Beschleunigen der Hauptzweck ist; ob und welche aus dem Ideenpool
  aufgenommen werden.

### 2.5 Menues und Einstieg ins Spiel

- **Titelbildschirm:** drei Knoepfe: New Game, Continue und Beenden.
  - Continue ist nur aktiv, wenn ein Spielstand existiert, sonst
    ausgegraut.
  - New Game ueberschreibt einen vorhandenen Spielstand; vorher erscheint
    eine Sicherheitsabfrage.
  - Hinweis: Im Browser kann sich ein Spiel nicht selbst beenden (siehe
    6.2); dort wird Beenden voraussichtlich ausgeblendet.
- **Intro-Sequenz** nach New Game (siehe 3.5).
- **Hauptmenue / Levelauswahl:** [offen]
- **Pause:** [offen]
- **Einstellungen:** [offen]
- **Credits / Abspann:** waehrend der Fahrstuhlfahrt nach dem letzten Level
  (siehe 3.5).

### 2.6 Scheitern und Wiederaufnahme

Festgelegt: Am Anfang jedes Levels steht ein Checkpoint. Stirbt der
Professor, startet er wieder am Anfang des aktuellen Levels; der
Fortschritt bleibt erhalten.

- Story-Begruendung: Der Checkpoint ist eine **Klonstation**. Der Professor
  hat seine DNA entschluesselt und kann sich selbst aus Materie nachbilden,
  inklusive Gehirn und Gedanken. Bei jedem Tod stirbt er tatsaechlich, wird
  aber neu gebaut und macht weiter.
- Humor-Idee: beim Respawn ein trockener Kommentar wie "Nummer 47, auf ein
  Neues."
- Verworfen: Zeitanker-Station als Alternative.

### 2.7 Spielstand und Fortschritt

- **Was wird gespeichert:** der Spielfortschritt (erreichtes Level,
  freigeschaltete Upgrades); Details [offen].
- **Wo der Spieler nach dem Laden startet:** am Anfang des zuletzt
  erreichten Levels (Klonstation).
- **Anzahl Spielstaende:** einer (New Game ueberschreibt ihn).
- **Wann gespeichert wird:** automatisch zu Beginn jedes Levels, passend zum
  Checkpoint; im Browser [offen].
- **Technik:** [z. B. JSON-Datei in `user://`, genau eine Stelle im Code
  speichert und laedt, Versionsnummer im Spielstand, sauberer Rueckfall bei
  fehlender oder beschaedigter Datei].
- **Fortschrittsmarken (Story Flags):** benannte Ja-Nein-Marken fuer jede
  Teilhandlung; Benennung siehe 1.6.

### 2.8 Texte und Dialoge

- Festgelegt: Der Professor droppt immer wieder zufaellige lustige Sprueche,
  dargestellt als **Sprechblase ueber dem Professor**. Inhalt und Beispiele
  siehe 3.6.
- Respawn-Kommentar an der Klonstation (siehe 2.6).
- Intro und Abspann siehe 3.5.
- [Offen: Ausloeser der Sprueche (zufaellig, an bestimmten Stellen), ob das
  Spiel dabei weiterlaeuft, Datenformat der Textdateien.]

### 2.9 Leveldesign

- **Struktur:** Ein Bereich ist ein grosser Teil des Labors (z. B. die
  Teslakammer) und besteht aus mehreren separaten Leveln. Es geht Etage fuer
  Etage nach oben.
- **Startbereich:** die Werkstatt des Professors ganz unten im Labor, in der
  er den Time Shifter baut. Dort beginnt das Spiel; sie zaehlt nicht als
  eigentlicher Bereich.
- **Reihenfolge (festgelegt):** Werkstatt -> Selbstschussanlage ->
  Teslakammer.
  1. **Selbstschussanlage:** Einstiegsbereich mit Schwerpunkt Projektile,
     weil die Mechanik dort am klarsten ist. Sanft beginnen mit einzelnen,
     langsamen Projektilen; die Projektilwand eher spaeter.
  2. **Teslakammer:** Schwerpunkt Elektrizitaet und eventuell Magnetismus,
     z. B. Zeitschaltuhren; moegliches neues Objekt: Magnete (siehe 2.4).
- Jeder Bereich hat einen eigenen Look und eigene Mechaniken.
- Chemielabor vorerst gestrichen (keine ueberzeugende Idee). Weitere
  Bereichs-Ideen (nicht festgelegt): Uhrmacher-Raum (Zahnraeder, Timer),
  Botaniklabor (Ranken).
- **Umfang:** ca. 8 bis 12 Level realistisch; Empfehlung 3 bis 4
  Themenbereiche.
- **Wer baut die Level:** Level-Builder in Godot: Alle Spielelemente
  (Plattformen, Projektile, Pendel, Timer, Schalter usw.) sind fertige
  Bausteine, die sich per Drag-and-drop ins Level ziehen lassen.

| Level | Thema / Hintergrund | Song | Neue Elemente | Besonderheit |
| --- | --- | --- | --- | --- |
| [1] | [ ] | [ID] | [ ] | [ ] |

Offene Punkte:

- Konkrete Levelstruktur und Anzahl der Level.
- Auswahl weiterer Themenbereiche (bisher zwei plus Werkstatt).
- Fruehere Strukturidee "unten Grundlagen (Timer, Plattform, Pendel), Mitte
  Projektile und Formregler, oben Kombinationen mit Synchron-Raetsel und
  Projektilwand als Finale" passt nicht zur festgelegten Reihenfolge
  (Projektile zuerst) und muss angeglichen werden.

### 2.10 Zusammenspiel der Mechaniken

Die Zeitblase ist das einzige Werkzeug des Spielers; alle Objekte aus 2.4
reagieren darauf. Die Formregler (per Upgrade) erlauben, gezielt einzelne
Objekte zu erfassen, was Synchron-Raetsel und Projektilwand erst moeglich
macht. Luecke: Beschleunigen ist bisher selten der Hauptzweck (siehe 2.4).

---

## Kapitel 3: Story

> **Ausfuellhinweis:** Wird die Handlung lang (viele Szenen, Dialogablaeufe),
> kommt sie in eine eigene Datei (`story.md`), hier bleibt eine Kurzfassung
> mit Verweis.

### 3.1 Setting

Das unterirdische Labor eines verrueckten Erfinders, aufgeteilt in
Forschungsbereiche auf mehreren Etagen. Der Professor hat zu viele
Sicherheitsvorkehrungen und Fallen eingebaut; normalerweise schaltet er sie
mit seiner Keycard unscharf. Grundstimmung: durchgehend humorvoll.

### 3.2 Spielfigur(en)

| Figur | Name im Code | Rolle | Charakter / Ziel | Faehigkeit |
| --- | --- | --- | --- | --- |
| Der Professor (Erfinder) | `professor` | Spielfigur | Verpeilt und verballert; will nach oben zu seiner Pizzalieferung | Time Shifter (Zeitblase) |

Aussehen: bewusst verpeilt und verballert gestaltet; der Humor soll schon im
Sprite stecken.

### 3.3 Antagonist

Kein klassischer Gegenspieler: Der Professor ist Opfer seines eigenen
Labors und seiner eigenen Fallen. Ausloeser: Beim ersten Test des Time
Shifters zerstoert ein elektromagnetischer Impuls (EMP) den Chip seiner
Keycard, sodass er die Fallen nicht mehr abschalten kann.

### 3.4 Weitere Figuren und NPCs

[keine festgelegt]

### 3.5 Story-Bogen

Ziel und Motivation (festgelegt): Der Professor hat Pizza bestellt und muss
von ganz unten im Labor nach oben, um die Lieferung entgegenzunehmen. Die
zerstoerte Keycard ist das Hindernis, die Pizza der Antrieb.

1. **Intro-Sequenz** (so knapp wie moeglich, damit der Spieler sofort weiss,
   worum es geht): Der Professor arbeitet am Time Shifter, z. B. mit einem
   Schweissgeraet. Er ist Professor, hat den Time Shifter entwickelt und
   Pizza bestellt. Beim ersten Test zerstoert er aus Versehen per EMP die
   Keycard. Mission: von ganz unten nach oben zur Pizzalieferung.
2. **Werkstatt** (Start), dann **Selbstschussanlage**, dann
   **Teslakammer** (siehe 2.9).
3. **Ende und Abspann:** Nach dem letzten Level nimmt der Professor oben die
   Pizza entgegen und faehrt mit dem Fahrstuhl zurueck ins Labor. Die
   Fahrstuhlfahrt nach unten ist der Abspann (Credits laufen waehrend der
   Fahrt); dabei isst er genuesslich seine Pizza. Pointe: Eigentlich haette
   er die ganze Zeit den Fahrstuhl nehmen koennen, aber das waere nur halb
   so viel Spass gewesen.

Verworfene Alternativen: nur Keycard ohne Pizza-Motivation; Tier als
Spielfigur (Schildkroete, Hase, Faultier, Laborratte); Keycard zerfaellt
durch Alterung (unrealistisch bei Plastik).

### 3.6 Ton und Schreibstil

- Grundton der Texte: durchgehend humorvoll, selbstironisch.
- Stimme des Professors: droppt zufaellige lustige Sprueche, gern mit
  Verweis auf seine krassen Erfindungen (z. B. das Exoskelett), was
  nebenbei die Welt ausbaut; dazu selbstironische Kommentare zu den
  eigenen Fallen.
- Beispielsprueche (deutsche Entwuerfe; im Spiel frei auf Englisch, siehe
  1.6):
  - "Ohne Exoskelett haette ich den Sprung aber nicht ueberlebt."
  - "Gut, dass ich meine Knochen mit Titan verstaerkt habe."
  - "Die Klonstation war meine beste Idee. Na gut, die zweitbeste nach dem
    Pizza-Teleporter, der leider nie funktioniert hat."
  - "Notiz an mich: Selbstschussanlagen erkennen keine Gesichter. Nur
    Keycards."
  - "Meine Antigravitationsschuhe waeren jetzt praktisch. Liegen leider oben
    neben der Haustuer."
  - "Diese Brille mit Roentgenblick haette mir hier echt geholfen. Wo hab
    ich die nur hingelegt?"
  - "Mein Kaffee-Beschleuniger hat uebrigens auch mal so angefangen."
  - "Nummer 47, auf ein Neues." (Respawn)
- Spoiler: [offen; Vorschlag: die Fahrstuhl-Pointe nicht auf der
  Store-Seite verraten].
- Uebersetzung: Spieltexte nur auf Englisch; deutsche Entwuerfe frei statt
  woertlich uebertragen, Wortwitz und Ton erhalten.

---

## Kapitel 4: Aufgabenliste (Schritt fuer Schritt)

### 4.1 Umfang der ersten spielbaren Version (Vertical Slice)

Fest eingeplant (Reihenfolge und Schritte folgen in 4.4):

- Titelbildschirm mit New Game, Continue und Beenden (siehe 2.5).
- Speichern: automatisch zu Beginn jedes Levels (siehe 2.7).
- Level-Builder: alle Spielelemente als Drag-and-drop-Bausteine (siehe 2.9).
- F1-Entwicklermenue mit Teleport, Unsterblichkeit, Level-Direkteinstieg und
  allen Upgrades; im Release-Build deaktiviert (siehe 1.9).

Vertical Slice (Ziel: 17.11.2026): Titelbildschirm, Speichern, Werkstatt
und die ersten Level der Selbstschussanlage durchspielbar, mit allen
Grundsystemen (Bewegung, Zeitblase, Bedienfeld, Tod/Klonstation,
Projektile, Schalter, Upgrades). Grafik darf noch Platzhalter sein.

Bewusst spaeter:

- Endgueltige Grafik, Intro, Abspann, Ton und Musik (ab Meilenstein 3).
- Elemente aus dem Ideenpool Beschleunigung (2.4), nur wenn Zeit bleibt.
- Controller- und Touch-Steuerung (nicht geplant).

### 4.2 Festlegungen vor der Umsetzung

- Tod und Checkpoint: Klonstation am Levelanfang (2.6).
- Speichern: ein Spielstand, automatisch am Levelanfang (2.7).
- Freischalten der Regler ueber Schrotthaufen (2.3).
- Sprueche als Sprechblase ueber dem Professor (2.8).

### 4.3 Verbindliche Arbeitsweise beim Abarbeiten der Liste

**Standard: ein Schritt nach dem anderen**

- Die KI bearbeitet genau den Schritt, den der Nutzer freigibt.
- Danach stoppt sie und wartet. Der Nutzer testet, gibt Anmerkungen, und
  Anpassungen erfolgen noch am selben Schritt.
- Erst wenn der Nutzer zufrieden ist, wird committet (siehe 1.4).
- Der naechste Schritt beginnt erst nach einem ausdruecklichen **Go**.

**Block-Modus (auf Ansage des Nutzers)**

- Der Nutzer kann mehrere Schritte auf einmal freigeben ("Schritte 12 bis
  16", "fahre fort"). Die KI arbeitet sie dann selbststaendig ab, trifft
  noetige Entscheidungen nach bestem Wissen und listet am Ende jede Annahme
  einzeln zur Pruefung auf.
- Am Ende eines Blocks: eine gemeinsame Testliste fuer alle Schritte.

**Sammel-Rueckmeldungen**

- Rueckmeldungen des Nutzers kommen oft als nummerierte Liste. Die KI
  arbeitet alle Punkte ab und meldet je Punkt, was sie getan hat oder warum
  nicht.
- Sagt der Nutzer "teste ich spaeter", kommt der Punkt auf die Liste
  **Noch zu testen** in 5.1 und erscheint in der naechsten Testanleitung.

**Pflege der Liste**

- Erledigte Schritte werden abgehakt (`- [x]`).
- Nummern werden nie neu vergeben. Ein eingeschobener Schritt bekommt einen
  Buchstaben (`12a`); Nachbesserungen stehen in Klammern am Schritt.
- Aenderungen gegenueber dem Plan werden am Schritt vermerkt ("geaendert:
  ...").
- Neue Vorhaben nach dem Vertical Slice kommen als **Ausbaustufe** mit
  eigener Ueberschrift dazu.

### 4.4 Die Liste

Zeitplan mit Meilensteinen (Abgabeschluss 01.12.2026, 22:37). Die Daten
sind Zielmarken; liegt ein Meilenstein deutlich zurueck, wird der Umfang
gekuerzt, nicht der Puffer.

**Meilenstein 1: Fundament (Ziel 10.11.)**

- [ ] 1. Projekt anlegen, Projekteinstellungen setzen (1.3: Aufloesung,
  Skalierung, Texturfilter, Renderer, Physik-Interpolation) und die
  Ordnerstruktur aus 1.5 erstellen. (Ordnerstruktur bereits am 01.11.2026
  angelegt.)
- [ ] 2. Export-Voreinstellungen fuer Browser und Windows anlegen und einen
  ersten Test-Export im Browser pruefen (frueh, damit Probleme mit
  4.8-dev6 im Web sofort auffallen).
- [ ] 3. Testszene mit Boden (Platzhalter-Tiles) und Kamera.
- [ ] 4. Professor als Platzhalter: Laufen und Springen (variable
  Sprunghoehe, Coyote Time, Sprungpuffer; Werte in einer Datendatei).
- [ ] 5. Zeitblase, Grundsystem: sichtbare Blase um den Professor, drei
  Zeitstufen, Objekte in der Blase laufen langsamer oder schneller und
  werden markiert. Testobjekt: fliegende Plattform.
- [ ] 6. Bedienfeld des Time Shifters: Shift halten = Bedienfeld gross in
  der Mitte, Spiel pausiert; Zeitregler per Maus; kleines Symbol fuer die
  Zeitstufe im Spiel.
- [ ] 7. Tod und Klonstation: toedliche Objekte, Neustart am Levelanfang.
- [ ] 8. F1-Entwicklermenue (1.9): Unverwundbar, Teleport, Level-Auswahl,
  alle Upgrades.

**Meilenstein 2: Spielelemente und Vertical Slice (Ziel 17.11.)**

- [ ] 9. Projektil und Projektil-Werfer: toedlich bei seitlicher
  Beruehrung, man kann daraufstehen und mitfliegen.
- [ ] 10. Schalter bzw. Trefferflaeche und Tuer (Projektil loest Impuls
  aus).
- [ ] 11. Pendel bzw. rotierende Gefahr.
- [ ] 12. Timer bzw. Zeitschaltuhr (z. B. Tuer bleibt laenger offen).
- [ ] 13. Formregler: vertikal, horizontal, Radius, dazu die
  Oszilloskop-Anzeige.
- [ ] 14. Schrotthaufen und Upgrades: Regler werden schrittweise
  freigeschaltet.
- [ ] 15. Level-Builder und Levelfolge: Level-Vorlage (Klonstation,
  Ausgang), alle Elemente als Drag-and-drop-Bausteine, Levelreihenfolge in
  einer Datendatei, Wechsel zum naechsten Level.
- [ ] 16. Titelbildschirm (New Game, Continue, Beenden) und Speichern bzw.
  Laden (2.5, 2.7).
- [ ] 17. Werkstatt und erste Level der Selbstschussanlage bauen
  (Platzhalter-Grafik). Danach: kompletter Testdurchlauf = Vertical Slice.

**Meilenstein 3: Inhalt und Grafik (Ziel 24.11.)**

- [ ] 18. Sprechblasen-System fuer die Sprueche des Professors (Texte
  englisch in Datendatei) inkl. Respawn-Kommentar.
- [ ] 19. Grafik: Farbpalette festlegen, Professor-Sprite mit Animationen,
  Tileset und Objekte der Selbstschussanlage.
- [ ] 20. Restliche Level der Selbstschussanlage.
- [ ] 21. Teslakammer: Grafik, ggf. Magnet, Level.
- [ ] 22. Intro-Sequenz (3.5).
- [ ] 23. Ende und Abspann mit Fahrstuhlfahrt (3.5).

**Meilenstein 4: Ton, Feinschliff, Abgabe (Ziel 28.11., Puffer bis 01.12.)**

- [ ] 24. Soundeffekte und Musik (Werkzeuge noch offen, siehe 1.7).
- [ ] 25. Feinschliff: Spielgefuehl, Effekte, Schwierigkeitskurve, Lektorat
  der Texte.
- [ ] 26. Release: Exporte fuer Browser und Windows, Checklisten 6.1 bis 6.4,
  itch.io-Seite, Abgabe auf der Jam-Seite.

### 4.5 Ausbaustufe: [Name]

- [ ] [n]. [...]

---

## Kapitel 5: Aktueller Stand und Versionsprotokoll

### 5.1 Aktueller Stand

> **Ausfuellhinweis:** Dieser Abschnitt wird bei jedem Schritt
> **ueberschrieben**, nicht ergaenzt. Hoechstens etwa 20 Zeilen, keine
> Historie und keine Technikdetails (die stehen in den Kapiteln 1 bis 3,
> im Versionsprotokoll und in Git).

**Stand vom 04.11.2026, Version v0.5**

- **Phase:** Konzept (Thema: SHIFT).
- **Zuletzt erledigt:** Brainstorming eingepflegt; Arbeitstitel, Sprache,
  Aufloesung, Kenntnisstand und Commit-Ablauf festgelegt.
- **Naechster Schritt:** Entwurf der Aufgabenliste 4.4 freigeben; danach
  Schritt 1 (Projekt anlegen).
- **Spielbar:** noch nichts.
- **Noch zu testen (vom Nutzer):** nichts.
- **Bekannte Probleme:** keine.
- **Groesste offene Punkte:** Levelstruktur (2.9), Beschleunigungs-Elemente
  (2.4), Reihenfolge der Upgrades (2.3), Look, Sound und Musik (1.2).

### 5.2 Versionsprotokoll

Das Versionsprotokoll steht in einer eigenen Datei: **`versionsprotokoll.md`**
(im Projektordner, neben dieser Dokumentation). Nach jedem Schritt kommt dort
ein neuer Eintrag oben dazu; bestehende Eintraege werden nie ueberschrieben.

---

## Kapitel 6: Veroeffentlichung

> **Ausfuellhinweis:** Spaetestens zum Vertical Slice anlegen; die Punkte
> sind eine Checkliste und werden abgehakt.

### 6.1 Export

| Voreinstellung | Ziel | Besonderheiten |
| --- | --- | --- |
| [Windows] | [`build/windows/[name].exe`] | [z. B. PCK eingebettet, Icon] |
| [Web] | [`build/web/index.html`] | [z. B. ohne Thread-Support fuer itch.io] |

- [ ] Export-Vorlagen genau zur Editor-Version installiert.
- [ ] "Mit Debug exportieren" aus (sonst sind die Entwickler-Werkzeuge
  aktiv).
- [ ] Spielsymbol (Icon) fuer Fenster, Exe und Browser-Tab.
- [ ] Ordner `build/` von Engine und Git ausgenommen (Git: erledigt per
  `.gitignore`; Engine: `.gdignore` beim Anlegen des Ordners).

### 6.2 Plattform-Abweichungen

Ein Projekt fuer alle Exporte; das Spiel erkennt die Plattform selbst und
weicht nur dort ab.

> **Ausfuellhinweis:** Erfahrungen aus dem Browser-Export (Godot): Ein
> Browserspiel kann sich nicht selbst beenden (Beenden-Knopf ausblenden);
> Vollbild nur nach einer Eingabe des Spielers; ohne Threads spielt der
> Browser Toene im "Sample"-Modus ab, der keine zur Laufzeit angelegten
> Kanaele, geschichtete Musik oder Tonhoehenaenderung kann (dann
> Wiedergabe-Typ "Stream" fuer Web einstellen); gespeichert wird zusaetzlich
> beim Verlassen des Tabs, weil es kein Schliessen-Signal gibt. Touch:
> eigene Bedienelemente, nur aktiv auf Handy/Tablet, Tastenhinweise als
> Symbole.

- [Plattform]: [Abweichung]

### 6.3 Vor dem Release

- [ ] Lektorat aller Texte (siehe Regel 13: erst Funde melden, dann
  aendern).
- [ ] Kompletter Durchlauf von Anfang bis Ende ohne Entwickler-Werkzeuge.
- [ ] Erklaerungen fuer neue Spieler (Steuerung, nicht selbsterklaerende
  Mechaniken) von jemand Fremdem testen lassen.
- [ ] Erster Start ohne vorhandenen Spielstand geprueft.
- [ ] [Uebersetzung vollstaendig]
- [ ] Repo und Dateien auf persoenliche Daten geprueft (siehe 1.12).
- [ ] `README.md` aktuell: Credits und Lizenzen aller fremden Assets,
  KI-Hinweis, Link zur itch.io-Seite.
- [ ] Letzter Stand vor dem Abgabeschluss (01.12.2026, 22:37) gepusht.
- [ ] Spiel auf der Jam-Seite eingereicht, Link zum Repo angegeben, Frage zur
  KI-Nutzung wahrheitsgemaess beantwortet.

### 6.4 Store-Seite ([Plattform, z. B. itch.io])

Unterlagen im Ordner `[itch/]` (von der Engine ausgenommen), Texte in
`[itch/store_page.md]`.

- [ ] Cover-Bild ([Groesse, z. B. 630 x 500 px])
- [ ] Kurzbeschreibung / Tagline
- [ ] Beschreibung (ohne Spoiler, siehe 3.6)
- [ ] Tags
- [ ] Screenshots
- [ ] Banner, Seitenhintergrund, Hintergrund fuer das eingebettete Spiel
- [ ] Hinweis zu Download und Installation
- [ ] Einstellungen fuer das eingebettete Spiel (Groesse, Vollbild-Knopf,
  "Mobile friendly", Ausrichtung)
