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
| Tile-Groesse | 16 x 16 px; Professor ca. 30 x 57 px (gut 3,5 Tiles hoch, siehe 1.7) |
| Basisaufloesung | 960 x 540 px (16:9; ganzzahlig skalierbar: x2 = 1920 x 1080, x4 = 3840 x 2160) |
| Skalierung | Stretch-Modus `canvas_items`, Seitenverhaeltnis `keep` (schwarze Raender statt Verzerrung) |
| Texturfilter | Nearest (scharfe Pixel) |
| Renderer | Compatibility (laeuft am zuverlaessigsten im Browser) |
| Fenstermodus | Entwicklung: Fenster 1440 x 810 (x1,5). Fertiges Spiel: Windows Vollbild (auf Full HD genau x2); Browser eingebettet in 960 x 540 (x1) mit Vollbild-Knopf |
| Standardschrift | [Datei, Groesse, Lizenz] |
| Versionsverwaltung | Git, oeffentliches Repo auf GitHub (`Nidrakon/game-off-2026`), Branch `main`, Autor "Nidrakon" mit GitHub-noreply-Adresse (nie eine private E-Mail, siehe 1.12). Die KI fuehrt Pull, Commit, Push, Merge und Pull Requests aus |
| Export | Voreinstellungen "Web" und "Windows" nach `build/` (siehe 6.1) |

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

Begruendung Aufloesung und Tiles: Urspruenglich 480 x 270 (04.11.2026).
Am 07.11.2026 erst auf 640 x 360, dann auf Wunsch des Nutzers auf
**960 x 540** erhoeht (festgelegt am 07.11.2026), weil das echte
Professor-Sprite gut 3,5 Tiles hoch ist und bei 480 x 270 ein Fuenftel der
Bildhoehe einnahm. 960 x 540 mit 16er-Tiles zeigt 60 x 33,75 Tiles; die
Figur ist etwa ein Zehntel der Bildhoehe, und Raetsel mit Blase,
Projektilen und Schaltern haben viel Platz. 960 x 540 ist genau halbes Full
HD (Vollbild x2, scharf) und eine uebliche Einbettungsgroesse auf itch.io
(x1). Das Entwicklungsfenster 1440 x 810 ist x1,5; dort koennen einzelne
Pixelreihen ungleich breit wirken, im Vollbild nicht.

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
| 1 | `world` | Terrain (Tiles), feste Hindernisse, fliegende Plattformen |
| 2 | `player` | Professor (prueft Kollision mit Ebene 1); Lichtschranken erkennen diese Ebene |

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

- **Farbpalette (strikt, festgelegt am 04.11.2026): Resurrect 64**
  (https://lospec.com/palette-list/resurrect-64), 64 Farben. Dateien:
  `graphics/palettes/resurrect_64.hex` (Liste) und `resurrect_64.gpl`
  (zum Laden in Aseprite). **Im Spiel gibt es keine anderen Farben.** Das
  gilt fuer alle Sprites und Grafiken, die die KI erstellt, und fuer jede
  Farbe, die im Code oder in Szenen gesetzt wird (Hintergrund, UI, Schrift,
  Effekte, Zeitblase). Pruefung: `tools/check_palette.gd` (siehe 1.8)
  meldet jedes Pixel in `graphics/` ausserhalb der Palette; die KI fuehrt es
  nach jeder neuen oder geaenderten Grafik aus.
- Ausnahme (festgelegt am 04.11.2026): Die **Zeitblase** darf
  halbtransparent sein; die dabei auf dem Bildschirm entstehenden
  Mischfarben sind erlaubt. Die Ausgangsfarben kommen trotzdem aus der
  Palette. Umsetzung voraussichtlich als Shader.
- Feste Grundfarben: [Hintergrund, Schrift, Umriss, Hervorhebung].
- Stilregeln: [Lichtrichtung, Umrissfarbe, Abstufungen je Material,
  Verlaeufe ja/nein].
- Bewegung: [z. B. Stauchen und Dehnen beim Springen und Landen].

**Quelldateien (verbindlich):** Die Quelle ist die Datei des
Grafikprogramms (z. B. `.aseprite` in `graphics/source/`), das PNG wird
daraus erzeugt und nie direkt bearbeitet. Export mit Aseprite ohne Fenster:
`Aseprite -b graphics/source/<name>.aseprite --save-as <zielordner>/<name>.png`.
Ablauf fuer den Nutzer: Quelle oeffnen, aendern, speichern, der KI Bescheid
geben. Neue `.aseprite`-Dateien der KI enthalten die Palette Resurrect 64
bereits als Sprite-Palette.

Platzhalter-Grafiken: `tileset_placeholder` (drei Tiles: Boden-Oberseite,
Boden-Fuellung, Block), `professor_placeholder` (16 x 32, ein Bild ohne
Animation, schaut nach rechts, nicht mehr verwendet) und
`object_flying_platform_placeholder` (64 x 16) und
`object_light_barrier_emitter_placeholder` (16 x 16, Linse zeigt nach rechts),
`object_electric_floor_placeholder` (16 x 32, zwei Bilder uebereinander),
`object_clone_station_placeholder` (48 x 80), `ui_time_stage_icons` und
`ui_dither_dark` dienen nur zum Testen und
werden mit der echten Grafik (Schritt 19) ersetzt.

**Professor-Sprite (vom Nutzer, 05.11.2026):** `professor_idle.aseprite`
(Rahmen 64 x 64, Figur ca. 30 x 57 px, also gut 3,5 Tiles hoch; 4 Frames
Idle), exportiert als Streifen `professor_idle_sheet.png`
(`Aseprite -b graphics/source/professor_idle.aseprite --sheet
graphics/sprites/professor/professor_idle_sheet.png --sheet-type horizontal`),
eingebunden ueber `professor_sprite_frames.tres` (Animation `idle`). Die
Fuesse stehen in Zeile 62 des Rahmens. **Festgelegt am 07.11.2026:** Die
Figur bleibt in dieser Groesse; Kollision, Bewegung, Zeitblase und Level
sind darauf abgestimmt (siehe 2.2, 2.9). Neue Figuren-Sprites sollten im
selben Massstab entstehen.

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
| `check_palette.gd` | Prueft alle PNGs in `graphics/` auf Farben ausserhalb von Resurrect 64 (Rueckgabe 0 = OK) | `godot --headless --path . --script tools/check_palette.gd` (Konsolenfassung von Godot) |

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
| Testlevel | Testszene zum Ausprobieren der Grundsysteme (`scenes/test/test_level.tscn`), derzeit Startszene des Projekts |

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
- Im normalen Spiel zeigt ein kleines Symbol oben links die aktuelle
  Zeitstufe (umgesetzt in Schritt 6). Die Blase selbst ist in der Spielwelt
  immer sichtbar.
- Offen: Belegung von W und S (bisher nur "WASD" genannt).
- Die vorlaeufigen Tasten 1 / 2 / 3 aus Schritt 5 sind mit Schritt 6
  entfallen.

Tasten werden als physische Tasten belegt (gleiche Position auf deutscher
und englischer Tastatur).

Werte der Bewegung (Datendatei `data/professor_movement.tres`, im Inspector
aenderbar; Skript `scripts/player/movement_settings.gd`):

| Gruppe | Wert | Standard |
| --- | --- | --- |
| Laufen | Hoechstgeschwindigkeit | 160 px/s (10 Tiles/s) |
| Laufen | Beschleunigung am Boden / Abbremsen / in der Luft | 1500 / 2000 / 1100 px/s² |
| Springen | Sprunghoehe (gehalten) | 96 px (6 Tiles); tatsaechlich ca. 100 px durch die Berechnung in Physik-Schritten |
| Springen | Zeit bis zum hoechsten Punkt | 0,44 s |
| Springen | Fallen schneller als Steigen | Faktor 1,6; hoechste Fallgeschwindigkeit 520 px/s |
| Springen | Kleiner Sprung (Taste beim Steigen losgelassen) | Steiggeschwindigkeit x 0,45 (ca. 43 px hoch) |
| Sprunghilfen | Coyote Time / Sprungpuffer | 0,10 s / 0,12 s |

Die Schwerkraft wird aus Sprunghoehe und Steigzeit berechnet. Fuer das
Leveldesign: Vom Boden erreichbar sind Kanten bis 5 Tiles (80 px) Hoehe;
4 Tiles Hoehenunterschied werden im Test sicher geschafft.

Koerper (Kollision) des Professors: 18 x 50 px, Unterkante an den Fuessen
(Figur 30 x 57; Haare und Arme ragen etwas ueber die Kollision hinaus, das
ist gewollt nachsichtig). Die Werte wurden am 07.11.2026 an die Groesse des
echten Sprites angepasst (vorher Platzhalter 16 x 32 mit 56 px Sprung und
100 px/s).
Offen: Laufanimation so abstimmen, dass der aufgesetzte Fuss nicht rutscht
(mit dem echten Sprite, Schritt 19).

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

**Werte** (Datendatei `data/time_bubble_settings.tres`, im Inspector
aenderbar; Skript `scripts/time_bubble/time_bubble_settings.gd`):

| Wert | Standard |
| --- | --- |
| Tempo auf Stufe langsam / schnell | x 0,3 / x 2,0 |
| Radius | 80 px (5 Tiles) |
| Farbe langsam / normal / schnell | `4d9be6` (Blau) / `c7dcd0` (Hellgrau) / `fb6b1d` (Orange) |
| Deckkraft Flaeche / Rand / Rand auf "normal" | 0,12 / 0,7 / 0,25 |

Radius-Grenzen und Verformungs-Grenzen folgen mit den Formreglern
(Schritt 13).

**Zusammenspiel:** Jedes Objekt aus 2.4 reagiert auf die Blase; die
Formregler erlauben, gezielt nur einzelne Objekte zu erfassen.

**Umsetzung (Schritt 5, 05.11.2026):**

- Die Blase ist ein Node `TimeBubble` im Professor (Mitte des Professors).
  Sie zeichnet sich selbst: auf "normal" nur ein schwacher Rand, sonst
  halbtransparente Flaeche und Rand in der Farbe der Stufe. Sie liegt vor
  den Levelobjekten, aber hinter dem Professor.
- Alles, was auf die Blase reagiert, bekommt den Baustein `TimeAffected`
  (Kind-Node, `scripts/time_bubble/time_affected.gd`) mit der Flaeche des
  Objekts (`bounds`). Er prueft jeden Physik-Schritt, ob diese Flaeche die
  Blase beruehrt (Rechteck gegen Kreis bzw. spaeter Ellipse, rein
  rechnerisch, ohne Physik-Ebene), und stellt `time_scale` bereit. Das
  Objekt rechnet mit `delta * time_scale`.
- Markierung: Beeinflusste Objekte bekommen einen 1-px-Rahmen in der Farbe
  der Stufe (Palettenfarbe, nicht halbtransparent).
- Zeitstufe umschalten (Schritt 6): Shift halten oeffnet das Bedienfeld
  (`scenes/ui/time_shifter_panel.tscn`), das Spiel pausiert. Der
  **Zeitregler** sieht aus wie eine Tankanzeige: Bogen aus drei Stuecken
  (links blau = langsam, oben grau = normal, rechts orange = schnell), aussen
  je ein Symbol (1, 2, 3 Pfeile), rote Nadel. Mit der Maus auf einen Bereich
  klicken oder die Nadel ziehen; die gewaehlte Stufe leuchtet, die anderen
  sind abgedunkelt, die Nadel schwenkt hin. Shift loslassen: Bedienfeld
  weg, Spiel laeuft mit der neuen Stufe weiter.
- Das Bedienfeld wird 2-fach gezeichnet (448 x 288 px) und im Code mit
  Palettenfarben gemalt (`scripts/ui/time_gauge.gd`). Der Hintergrund wird
  mit einem Rastermuster (`ui_dither_dark.png`, jedes zweite Pixel dunkel)
  abgedunkelt statt mit Transparenz, damit keine Mischfarben entstehen.
  Platz fuer die spaeteren Formregler und das Oszilloskop (Schritt 13)
  wird dann geschaffen.
- **Symbol im Spiel** (`scenes/ui/time_stage_indicator.tscn`): kleines Feld
  oben links mit dem Symbol der Stufe in ihrer Farbe.
- Symbole: `graphics/ui/ui_time_stage_icons.png` (48 x 16, drei weisse
  Symbole); sie werden im Code mit Palettenfarben eingefaerbt (weiss x Farbe
  = genau diese Farbe).
- Jedes Level braucht beide UI-Szenen (spaeter Teil der Level-Vorlage,
  Schritt 15).

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
- Umgesetzt (Schritt 5): Szene `scenes/objects/flying_platform.tscn`
  (64 x 16, begehbare Oberseite 10 px hoch, Kollisionsebene 1). Je Plattform
  im Inspector: Strecke `travel` (vom Startpunkt zum Wendepunkt), Fahrzeit
  `travel_time` fuer eine Richtung (Standard 1,5 s) und Startposition auf der
  Strecke. Faehrt hin und her, an den Enden weich abgebremst. Der Professor
  faehrt darauf mit.
- Weitere Einstellungen (07.11.2026): `active` (faehrt beim Start; aus = sie
  wartet auf ein Signal) und `wait_time` (Pause an jedem Ende in Sekunden,
  laeuft in der Zeitblase mit; Standard 0). Die Plattform ist
  Signal-Empfaenger (siehe unten).

**Lichtschranke (neu, 07.11.2026, Wunsch des Nutzers)**

- Laserstrahl zwischen zwei Sendern. Laeuft der Professor hindurch, sendet
  sie ein Signal an ihre Ziele, z. B. faehrt eine Plattform los oder bleibt
  stehen. Darueberspringen geht nur, wenn der Strahl niedrig genug ist.
- Szene `scenes/objects/light_barrier.tscn`. Der Node ist Sender A, Sender B
  liegt bei `beam_end` (relativ, Standard 9 Tiles nach oben). Im Inspector:
  `targets` (Liste der Ziele), `action` (umschalten / einschalten /
  ausschalten), `one_shot` (nur einmal, danach erlischt der Strahl). Strahl
  und Sender sind schon im Editor sichtbar.
- Loest einmal pro Durchqueren aus; wer im Strahl stehen bleibt, loest nicht
  erneut aus. Beim Ausloesen blitzt der Strahl kurz weiss.
- Aussehen: Strahl 3 px (`e83b3b`, Kern `f68181`), verbraucht `6e2727`.
- Offen: Ob die Zeitblase auf die Lichtschranke wirkt (bisher nicht) und ob
  auch Projektile sie ausloesen (dann deren Ebene in die Maske aufnehmen).

**Signal-Empfaenger (Schnittstelle, 07.11.2026)**

- Alles, was von Ausloesern (Lichtschranke, spaeter Schalter) gesteuert
  wird, hat die Funktionen `activate()`, `deactivate()` und `toggle()`.
  Bisher: fliegende Plattform. Spaetere Empfaenger (z. B. Tuer) bauen
  dieselben drei Funktionen ein; der Ausloeser muss dafuer nicht geaendert
  werden.
- Idee: aus der Ferne mit gestreckter Blase abbremsen, um sie zu erreichen,
  dann beschleunigen (z. B. um vor einer sich schliessenden Tuer anzukommen).

**Timer / Zeitschaltuhr / Zeitbombe**

- Laeuft in der Blase langsamer oder schneller; zwei asynchrone Timer
  lassen sich synchronisieren.
- Gut zum Erlernen der Mechanik ohne Gefahr.
- Ideen: Tuer mit Zeitschaltuhr laenger offen halten; Bombe bremsen, um zu
  entkommen, oder beschleunigen, um eine Wand zu sprengen.

**Toedliche Objekte: Baustein Hazard (07.11.2026)**

- Alles Toedliche nutzt den Baustein `Hazard` (Area2D, erkennt Ebene 2
  "player"): Beruehrt der Professor die Flaeche, ruft er dessen `die()` auf.
  Spaetere Gefahren (Projektil, Pendel) bauen darauf auf. Fuer eine
  unsichtbare Todeszone (z. B. Abgrund) genuegt eine Area2D mit
  `hazard.gd` und einer Form.

**Starkstrom-Bodenplatte (07.11.2026, Testobjekt fuer Schritt 7)**

- Reihe knisternder Platten mit Warnstreifen; toedlich bei Beruehrung.
  Wird anstelle von Boden-Tiles in eine Luecke gesetzt (Node an der linken
  oberen Ecke der ersten Platte, Breite `width_tiles`, im Editor sichtbar).
- Szene `scenes/objects/electric_floor.tscn`. Passt zur Teslakammer.
- Offen: ob die Zeitblase auf sie wirkt (z. B. Funken verlangsamen).

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

**Umsetzung (Schritt 7, 07.11.2026):**

- Klonstation: `scenes/objects/clone_station.tscn` (Kapsel 48 x 80, der
  Node liegt am Boden in der Mitte; dort erscheint der Professor). Sie
  ersetzt den bisherigen Startpunkt; jedes Level braucht genau eine.
- Erscheinen: flackernder Klon-Strahl in der Kapsel, der Professor flackert
  auf; 0,5 s lang ist die Steuerung gesperrt (`spawn_time`). Die Kamera
  springt sofort auf ihn.
- Tod: Der Professor bleibt stehen, flackert 0,5 s und verschwindet. Nach
  0,7 s (`restart_delay`) wird das Level neu geladen. Dabei wird alles im
  Level zurueckgesetzt (Plattformen, Lichtschranken, Zeitstufe = normal;
  festgelegt am 07.11.2026: Zeitstufe startet nach dem Tod wieder auf
  normal).
- Wer toedlich ist, entscheidet der Baustein `Hazard`
  (`scripts/objects/hazard.gd`, siehe 2.4).
- Spaeter: Klon-Nummer und Respawn-Spruch (Schritt 18).

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
- **Masse (festgelegt am 07.11.2026, passend zur Figur):** Durchgaenge
  mindestens 4 Tiles (64 px) hoch, damit der Professor (50 px) durchpasst;
  ein 3 Tiles hohes Hindernis ist nur per Sprung zu ueberwinden; Kanten bis
  5 Tiles Hoehe sind erreichbar (2.2). Der Bildschirm zeigt 60 x 33,75 Tiles
  (960 x 540), die Figur ist davon gut 3,5 Tiles hoch. Level sind
  mindestens 34 Tiles (544 px) hoch, damit die Kamera nicht ueber den Rand
  schaut.
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

- [x] 1. Projekt anlegen, Projekteinstellungen setzen (1.3: Aufloesung,
  Skalierung, Texturfilter, Renderer, Physik-Interpolation) und die
  Ordnerstruktur aus 1.5 erstellen. (Ordnerstruktur bereits am 01.11.2026
  angelegt.)
- [x] 2. Export-Voreinstellungen fuer Browser und Windows anlegen und einen
  ersten Test-Export im Browser pruefen (frueh, damit Probleme mit
  4.8-dev6 im Web sofort auffallen).
- [x] 3. Testszene mit Boden (Platzhalter-Tiles) und Kamera.
- [x] 4. Professor als Platzhalter: Laufen und Springen (variable
  Sprunghoehe, Coyote Time, Sprungpuffer; Werte in einer Datendatei).
- [x] 5. Zeitblase, Grundsystem: sichtbare Blase um den Professor, drei
  Zeitstufen, Objekte in der Blase laufen langsamer oder schneller und
  werden markiert. Testobjekt: fliegende Plattform.
- [x] 5a. Lichtschranke (eingeschoben am 07.11.2026): Strahl zwischen zwei
  Sendern, Durchlaufen sendet ein Signal an Ziele (Plattform an/aus);
  Schnittstelle Signal-Empfaenger. Dabei: Aufloesung 960 x 540, Plattform
  mit Wartezeit an den Enden.
- [x] 6. Bedienfeld des Time Shifters: Shift halten = Bedienfeld gross in
  der Mitte, Spiel pausiert; Zeitregler per Maus; kleines Symbol fuer die
  Zeitstufe im Spiel.
- [x] 7. Tod und Klonstation: toedliche Objekte, Neustart am Levelanfang.
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

**Stand vom 07.11.2026, Version v0.13**

- **Phase:** Meilenstein 1, Fundament (Ziel 10.11.).
- **Zuletzt erledigt:** Schritt 7 (Tod und Klonstation).
- **Naechster Schritt:** 8 (F1-Entwicklermenue).
- **Spielbar:** Testlevel mit dem Professor (Idle-Sprite): laufen,
  springen, Kamera folgt; Shift + Maus stellt die Zeitstufe ein, fliegende
  Plattformen reagieren auf die Blase; Lichtschranke schaltet eine
  Plattform an und aus; Start in der Klonstation, Starkstrom-Luecke ist
  toedlich, danach Neustart.
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
| Windows | `build/windows/time_shifter.exe` | 64 Bit, Spieldaten (PCK) in die Exe eingebettet; Icon [offen] |
| Web | `build/web/index.html` | ohne Thread-Support (laeuft auf itch.io ohne Sonderkonfiguration), Canvas passt sich dem Fenster an |

Export per Kommandozeile (die KI nutzt die Konsolenfassung von Godot):
`--headless --path . --export-release "Web" build/web/index.html` bzw.
`"Windows" build/windows/time_shifter.exe`. Lokaler Browser-Test:
`python -m http.server 8060 --bind 127.0.0.1 --directory build/web`, dann
http://localhost:8060 oeffnen.

Startbildschirm (Boot Splash): ohne Godot-Logo, Hintergrund `#2e222f` aus
der Palette.

- [x] Export-Vorlagen genau zur Editor-Version installiert (4.8-dev6).
- [ ] "Mit Debug exportieren" aus (sonst sind die Entwickler-Werkzeuge
  aktiv). Hinweis: Die KI exportiert mit `--export-release`.
- [ ] Spielsymbol (Icon) fuer Fenster, Exe und Browser-Tab.
- [x] Ordner `build/` von Engine und Git ausgenommen (`build/.gdignore`,
  `.gitignore`).

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
