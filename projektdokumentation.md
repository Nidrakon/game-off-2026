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
| Standardschrift | vorerst Godot-Standardschrift ohne Kantenglaettung (`gui/theme/default_font_antialiasing` aus, damit keine Mischfarben entstehen); eigene Pixelschrift offen |
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
17. **Zeiten jedes Bausteins einstellbar (festgelegt am 10.11.2026):** Jeder
    Baustein mit Takt, Tempo oder Dauer bekommt dafuer Parameter im
    Inspector, damit der Nutzer beim Levelbau steuern kann, wie schnell er
    laeuft. Wo mehrere Exemplare gegeneinander versetzt laufen sollen, kommt
    ein Startversatz dazu. Alle diese Zeiten laufen in der Zeitblase mit.

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
  addons/        # Editor-Plugins (eigener Code, z. B. Aseprite-Sync, siehe 1.8)
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
| `Upgrades` | `scripts/autoload/upgrades.gd` (Klasse `TimeShifterUpgrades`) | Freigeschaltete Upgrades des Time Shifters (2.3); bleiben beim Neustart des Levels erhalten |
| `LevelFlow` | `scripts/autoload/level_flow.gd` | Levelfolge aus `data/level_order.tres`, Wechsel zum naechsten Level mit Abblenden (2.9) |
| `SaveGame` | `scripts/autoload/save_game.gd` | Spielstand speichern und laden, Fortschrittsmarken, Testmodus (2.7) |
| `DevMenu` | `scripts/autoload/dev_menu.gd` | Entwickler-Menue (F1), Teleport, Schalter "Unverwundbar" (1.9); nur im Debug-Build aktiv |

**Kollisionsebenen:**

| Ebene | Name | Wer liegt darauf |
| --- | --- | --- |
| 1 | `world` | Terrain (Tiles), feste Hindernisse, fliegende Plattformen, Werfer, Trefferflaechen, Tueren |
| 2 | `player` | Professor (prueft Kollision mit Ebenen 1 und 3); Lichtschranken und Gefahren erkennen diese Ebene |
| 3 | `projectile` | Projektile (Professor kann darauf stehen; prueft Ebene 1 fuer den Aufprall); Lichtschranken erkennen diese Ebene |

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
  Palette. Umsetzung voraussichtlich als Shader. Das gilt auch fuer die
  Farben, die die chromatische Aberration des geplanten Blasen-Shaders
  erzeugt (siehe 2.3, Darstellung der Zeitblase, 10.11.2026).
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
`object_light_barrier_emitter_placeholder` (16 x 16, Linse zeigt nach rechts,
seit Schritt 12a blau), `object_deadly_laser_emitter_placeholder` (16 x 16,
dunkles Gehaeuse mit gelben Warnstreifen, grosse rote Linse rechts),
`object_scrap_heap_placeholder` (32 x 48: oben der Haufen 32 x 24 mit
Zahnrad, Rohr, Spule, Feder und Glasroehre, unten die Reste),
`object_level_exit_placeholder` (64 x 64: links geschlossene Schiebetuer
32 x 64 mit Lampenfeld und Warnstreifen, rechts offen),
`object_elevator_placeholder` (64 x 80: Fahrstuhltuer mit Etagenanzeige,
rechts Keycard-Leser),
`object_electric_floor_placeholder` (16 x 32, zwei Bilder uebereinander),
`object_clone_station_placeholder` (48 x 80),
`object_projectile_placeholder` (64 x 32, Spitze rechts),
`object_projectile_launcher_placeholder` (32 x 48, Muendung rechts),
`ui_time_stage_icons` und `ui_dither_dark` dienen nur zum Testen und
werden mit der echten Grafik (Schritt 19) ersetzt.

**Professor-Sprite (vom Nutzer, 05.11.2026, aktualisiert 09.11.2026;
wird ueber den Aseprite-Sync automatisch exportiert, siehe 1.8):**
`graphics/source/professor.aseprite` (Rahmen 64 x 64, Figur ca. 30 x 57 px,
also gut 3,5 Tiles hoch; 17 Frames: Tag `Idle` = Frames 1-4, Tag `Run` =
Frames 5-12, Tag `Jump` = Frames 13-17, Stand 11.11.2026). Die Ebenen ausser
`charakter` sind Hilfsebenen des Nutzers; der Export nimmt, was beim
Speichern sichtbar ist (siehe 1.8). Exportiert als
Streifen `professor_sheet.png` (`Aseprite -b graphics/source/professor.aseprite
--sheet graphics/sprites/professor/professor_sheet.png --sheet-type
horizontal`), eingebunden ueber `professor_sprite_frames.tres` (Animationen
`idle`, `run`, `jump`, Bilddauern wie in Aseprite). Laufanimation am Boden
ab 10 px/s, sonst Idle.

**Sprunganimation geschwindigkeitsgesteuert (Wunsch des Nutzers,
11.11.2026):** Die 5 Bilder von `jump` werden nicht nach Zeit abgespielt,
sondern vom Animator (`scripts/player/professor_animator.gd`, Kind-Node
`Animator` im Professor) gewaehlt:

| Bild (im Tag, ab 0) | Wann | Steuerung |
| --- | --- | --- |
| 0 Absprung | direkt nach dem Absprung, `takeoff_time` lang (0,1 s); der Sprung selbst startet sofort beim Druecken | Zeit |
| 1 Steigen | steigt schneller als `apex_speed` | Geschwindigkeit |
| 2 Hoehepunkt | langsamer als `apex_speed` (120 px/s), kurz vor und nach dem hoechsten Punkt | Geschwindigkeit |
| 3 Fallen | faellt schneller als `apex_speed` | Geschwindigkeit |
| 4 Landung | nach dem Aufsetzen, `landing_time` lang (0,1 s), dann Idle bzw. Laufen | Zeit |

Faellt er ohne Sprung von einer Kante, gibt es kein Absprungbild (er beginnt
mit dem Hoehepunkt-Bild).

**Verworfen (11.11.2026):** Ein verzoegerter Absprung (erst das
Absprung-Bild am Boden, dann der Sprung) wurde ausprobiert und vom Nutzer
wieder verworfen, weil sich die Steuerung dadurch indirekt anfuehlt. Der
Sprung startet sofort beim Druecken; das Absprung-Bild erscheint direkt
nach dem Abheben.

**Entwurf der Sprung-Bilder (11.11.2026):** Auf Wunsch hat die KI in einer
Kopie der Arbeitsdatei des Nutzers (`character_mad_inventor_jump_entwurf.aseprite`,
im Aseprite-Ordner des Nutzers, nicht im Repo) die 5 Sprung-Bilder entworfen:
aus dem aufrechten Laufbild zusammengesetzt (Ducken, Strecken mit Arm nach
vorn oben, Beine angezogen mit Arm nach vorn, Fallen mit Arm hoch, Ducken),
Hilfsebenen (Kopf, Hand, Fuss) passend ausgefuellt. Der Nutzer uebernimmt bzw.
ueberarbeitet daraus, was ihm gefaellt. Alle Werte und die Bildnummern stehen in
`data/professor_animation.tres` (Skript
`scripts/player/professor_animation_settings.gd`), dazu `run_min_speed`.
Bei einem vollen Sprung (Start ca. 550 px/s) steht das Hoehepunkt-Bild mit
120 px/s etwa 0,13 s. Die
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

**Aseprite-Sync (09.11.2026, Wunsch des Nutzers)**

Der Nutzer zeichnet direkt in der Aseprite-Datei und sieht das Ergebnis
sofort im Spiel, ohne dass jemand von Hand exportiert.

- **Editor-Plugin** `addons/aseprite_sync/` (eigener Code, keine fremde
  Erweiterung). Einschalten unter Projekt > Projekteinstellungen > Plugins
  ("Aseprite Sync", Haken bei Aktiviert). Es prueft jede Sekunde, ob eine der
  Aseprite-Dateien aus `data/aseprite_sync.cfg` gespeichert wurde, und dann:
  Export als Sheet-PNG plus JSON (Bildpositionen, Dauern, Tags) ueber die
  Aseprite-Kommandozeile, neu einlesen, SpriteFrames neu aufbauen. Jeder Tag
  wird eine Animation (Name klein geschrieben), Bilddauern wie in Aseprite,
  Richtung vorwaerts / rueckwaerts / hin und zurueck. Ausgeblendete Ebenen
  (Hilfsebenen) kommen nicht ins Bild. Von Hand: Projekt > Werkzeuge >
  "Aseprite: Sync now".
- **Pfad zu Aseprite:** Editor-Einstellung `aseprite_sync/aseprite_path`
  (lokal, nicht im Repo). Ist sie leer, sucht das Plugin an den ueblichen
  Installationsorten (Programme-Ordner, Steam).
- **Live im laufenden Spiel:** Beim Debug-Start aus dem Editor legt das
  DevMenu `scripts/dev/sprite_hot_reload.gd` an. Er bemerkt einen neuen
  Export (JSON geaendert), liest Sheet und Daten direkt von der Festplatte und
  tauscht die Animationen aller betroffenen Figuren aus, auch nach einem
  Level-Neustart. Im Export-Build ist das aus.
- Gemeinsamer Code: `scripts/tools/aseprite_sync.gd` (`AsepriteSync`).
- Weitere Figuren: Abschnitt in `data/aseprite_sync.cfg` ergaenzen
  (`source`, `sheet`, `frames`, optional `play_once`).
- `play_once`: Animationen, die einmal laufen und auf dem letzten Bild stehen
  bleiben; ebenso Tags, bei denen in Aseprite "Repeat" gesetzt ist. Alle
  anderen laufen in Schleife. Beim Professor derzeit leer (der Sprung wird
  vom Animator Bild fuer Bild gesetzt).
- `layers` (optional): nur diese Ebenen exportieren, egal ob sie beim
  Speichern sichtbar sind. **Beim Professor bewusst nicht gesetzt**
  (Wunsch des Nutzers, 11.11.2026): Exportiert wird, was beim Speichern
  sichtbar ist, auch eingeblendete Hilfsebenen, damit der Nutzer sie zum
  Testen im Spiel sieht. Folge: Mit eingeblendeten Hilfsebenen meldet
  `check_palette.gd` halbtransparente Pixel im Sheet. Vor einem Release
  die Datei mit ausgeblendeten Hilfsebenen speichern.
- **Eigene Arbeitsdatei ausserhalb des Projekts:** In
  `data/aseprite_sync.local.cfg` (in `.gitignore`, nur auf dem Rechner)
  im selben Abschnitt `source` mit dem vollen Pfad setzen. Das Plugin
  beobachtet dann diese Datei und kopiert sie bei jedem Export nach
  `graphics/source/...` ins Projekt, damit das Repo den aktuellen Stand hat.
  Beim Nutzer eingerichtet (09.11.2026): seine Datei
  `character_mad_inventor.aseprite` im eigenen Aseprite-Ordner.
- Animationen, die das Spiel benutzt, muessen als Tag existieren: `Idle`,
  `Run`, `Jump` (Professor). Neue Tags sind sofort als Animation vorhanden, werden
  aber erst abgespielt, wenn der Code sie benutzt.

### 1.9 Entwickler-Werkzeuge (Testen ohne Durchspielen)

> **Ausfuellhinweis:** Frueh einplanen, spaetestens wenn das Spiel mehr als
> ein paar Minuten lang ist. Sonst muss man fuer jeden Test von vorn
> spielen.

Nur beim Start aus dem Editor (Debug-Build) aktiv, im exportierten Spiel
nicht vorhanden.

**Stand (Schritt 8, 07.11.2026):** Autoload `DevMenu`
(`scripts/autoload/dev_menu.gd`). Vorhanden: F1-Menue mit "Invulnerable:
ON/OFF" (bleibt auch nach Neustart des Levels an), "Restart level" und der
Level-Auswahl (listet automatisch alle Szenen aus `scenes/levels/` und
`scenes/test/`, scrollt); Teleport per Strg + Linksklick (auch bei
geschlossenem Menue). Exportierte Builds sind Release-Builds, dort ist alles
abgeschaltet. Seit Schritt 14: "Unlock all upgrades" und "Reset upgrades"
(wirken sofort, Schrotthaufen im Level passen sich an). Seit Schritt 16:
"Main menu" (Titelbildschirm), Liste der Test-Szenarien (Klick laedt
Spielstand und Level, danach Testmodus; die Titelzeile zeigt dann
"TEST MODE") und "Save state as scenario" (legt aus dem aktuellen Stand
`data/dev_scenarios/saved_<datum_zeit>.json` an, mit Level, Position des
Professors und Spielstand; Datei danach gern sinnvoll umbenennen). Das
Menue hat zwei Spalten (links Schalter und Aktionen, rechts Szenarien und
Level), nutzt nur Palettenfarben; Texte englisch direkt im Code (kein Teil
des Spiels).

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
- **Teleport:** Strg + Linksklick setzt die Figur an die Mausposition.
- **Unverwundbar** (Schalter).
- **Time markers** (Schalter, Standard aus, 09.11.2026): Objekte in der
  Zeitblase farbig umranden. Nur zum Testen; im fertigen Spiel gibt es keine
  Umrandung (das Menue ist im Export aus).
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
	"position": [x, y],
	"save": { "upgrades": [], "flags": [] }
}
```

`based_on` baut auf einem anderen Szenario auf (Ketten wie "Anfang ->
Mitte -> vor dem Boss"); `marker` ist der Name eines Knotens im Level und
uebersteht Umbauten besser als feste Koordinaten. `position` (optional,
Weltkoordinaten) gilt, wenn kein `marker` gesetzt ist; ohne beides startet
der Professor an der Klonstation. Beim Zusammenfuehren mit `based_on`
werden Listen im Spielstand (Upgrades, Marken) vereinigt, alles andere
nimmt den Wert des Szenarios selbst.

| Kennung | Name | Stand |
| --- | --- | --- |
| `new_game` | New game | frischer Spielstand, erstes Beispiel-Level |
| `example_2_all_upgrades` | Example 2, all upgrades | Beispiel-Level 2 mit Radius und Form (baut auf `new_game` auf) |

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
| Trefferflaeche, Schalter | Wird von einem Projektil ausgeloest und sendet ein Signal (`impact_switch`, siehe 2.4) |
| Zeitschaltuhr | Countdown zwischen Ausloeser und Zielen (`time_switch`, siehe 2.4) |
| Toedlicher Laser | Strahl zwischen zwei Sendern im Takt an und aus, toetet bei Beruehrung (`deadly_laser`, Schritt 12a, siehe 2.4) |
| Wandhinweis | Aufgemalte Taste(n) mit Wort an der Hintergrundwand, Baustein fuer das Tutorial (`wall_hint`, Schritt 16a, siehe 2.9) |
| Rohre | Tileset mit Rohren und Dampf, automatisch verbindend, Vorder- und Hintergrund (geplant, `tileset_pipes`, siehe 2.9) |
| Fahrstuhl | Steht in der Werkstatt; zu Beginn nicht nutzbar (Keycard "geroestet"), am Ende faehrt der Professor damit nach unten (`elevator`, siehe 3.5) |
| E-Anzeige | Tastenkappe "E" ueber einem Objekt, mit dem der Professor gerade interagieren kann (`Interactable`, siehe 2.9) |
| Werkstatt | Startbereich ganz unten, zaehlt nicht als eigentlicher Bereich |
| Bereich | Grosser Teil des Labors (z. B. Teslakammer), besteht aus mehreren Leveln |
| Level | Einzelner, abgeschlossener Abschnitt innerhalb eines Bereichs |
| Ausgang | Schiebetuer am Ende eines Levels, fuehrt zum naechsten Level der Reihenfolge (`level_exit`, siehe 2.9) |
| Level-Vorlage | Szene `level_base`, von der jedes Level erbt (siehe 2.9) |
| Testlevel | Testszene zum Ausprobieren der Grundsysteme (`scenes/test/test_level.tscn`), ueber F1 oder F6 erreichbar; heller Testhintergrund (Node `TestBackground`, Farbe `b2ba90`, im Inspector aenderbar; nur im Testlevel, 09.11.2026) |

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
  Geplant (10.11.2026) als Shader mit Wobble und chromatischer Aberration,
  siehe 2.3, Darstellung der Zeitblase.

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
| Interagieren (seit Schritt 16a) | `interact` | E (physische Taste) | [ ] | [ ] |
| Bedienfeld des Time Shifters ("Kupplung") | `time_shifter_panel` | Shift gedrueckt halten | [ ] | [ ] |
| Regler im Bedienfeld bedienen | (Maus-Eingabe auf die Regler) | Maus | [ ] | [ ] |
| Zeitstufe per Mausrad (Wunsch des Nutzers, 09.11.2026) | (Mausrad bei offenem Bedienfeld) | Shift + Rad hoch = schneller, Shift + Rad runter = langsamer | [ ] | [ ] |
| [Pause] | `pause` | [offen, z. B. Esc] | [ ] | [ ] |

- **Shift als "Kupplung":** Solange Shift gehalten wird, erscheint das
  Bedienfeld gross in der Bildschirmmitte, und das Spiel im Hintergrund ist
  pausiert. Ohne Shift ist das Bedienfeld ausgeblendet.
- Im normalen Spiel zeigt ein kleines Symbol oben links die aktuelle
  Zeitstufe (umgesetzt in Schritt 6). Die Blase selbst ist in der Spielwelt
  immer sichtbar.
- **Interagieren (E):** z. B. am Fahrstuhl in der Werkstatt; dann erscheint
  eine Sprechblase des Professors (siehe 2.9 Tutorial, 3.5). Steht der
  Professor bei einem solchen Objekt, schwebt darueber eine Tastenkappe "E".
- Offen: Belegung von W und S (bisher nur "WASD" genannt).
- Die vorlaeufigen Tasten 1 / 2 / 3 aus Schritt 5 sind mit Schritt 6
  entfallen.

Tasten werden als physische Tasten belegt (gleiche Position auf deutscher
und englischer Tastatur).

Werte der Bewegung (Datendatei `data/professor_movement.tres`, im Inspector
aenderbar; Skript `scripts/player/movement_settings.gd`):

| Gruppe | Wert | Standard |
| --- | --- | --- |
| Laufen | Hoechstgeschwindigkeit | 200 px/s (12,5 Tiles/s), vom Nutzer auf die Laufanimation abgestimmt (09.11.2026) |
| Laufen | Beschleunigung am Boden / Abbremsen / in der Luft | 1500 / 2000 / 1100 px/s² |
| Springen | Sprunghoehe (gehalten) | 96 px (6 Tiles); tatsaechlich ca. 100 px durch die Berechnung in Physik-Schritten |
| Springen | Zeit bis zum hoechsten Punkt | 0,35 s |
| Springen | Fallen schneller als Steigen | Faktor 1,6; hoechste Fallgeschwindigkeit 1000 px/s |
| Springen | Kleiner Sprung (Taste beim Steigen losgelassen) | Steiggeschwindigkeit x 0,6 (ca. 59 px hoch) |
| Sprunghilfen | Coyote Time / Sprungpuffer | 0,10 s / 0,12 s |

Die Werte vom 09.11.2026 (Lauftempo, Steigzeit, Fallgeschwindigkeit,
kleiner Sprung) hat der Nutzer selbst eingestellt; sie sind auch die
Standardwerte im Skript.

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
- **Cursor auf dem Oszilloskop (ersetzt seit 11.11.2026 die beiden
  Schieberegler):** in x und y beweglich; streckt die Sphaere zum Ei in
  Richtung des Cursors (jede Richtung, auch schraeg). So kann die Blase vom
  Professor weg in eine Richtung zeigen.
- **Drehregler:** Radius der Sphaere.
- **Oszilloskop-Anzeige:** zeigt im XY-Modus als Lissajous-Figur die
  aktuelle Form der Sphaere (Kreis bzw. Ei). Die Figur pulsiert oder
  rotiert je nach Zeitstufe langsamer oder schneller.

**Freischalten (festgelegt):** Vier Stellgroessen koennen fummelig werden,
deshalb werden die Regler schrittweise freigeschaltet. Der Professor findet
Schrotthaufen, mit denen er den Time Shifter verbessert und eine neue
Funktion erhaelt. Sie liegen frei platziert, jeweils kurz bevor ein Level die
neue Funktion braucht (nicht an Bereichsgrenzen gebunden). Zu Beginn fehlen
der Cursor zur Formung der Sphaere noch.

**Upgrades (umgesetzt in Schritt 14, 12.11.2026):**

- Von Anfang an da: Zeitregler (langsam, normal, schnell) und die Anzeige des
  Oszilloskops. Freischaltbar: **Radius** (Drehregler) und **Form** (Cursor
  auf dem Oszilloskop). Die Reihenfolge legt das Leveldesign fest: Jeder
  Schrotthaufen hat im Inspector `upgrade` (Radius oder Form).
- Gesperrte Regler: Statt des Drehreglers sitzt eine Abdeckplatte mit vier
  Schrauben und leerem Einbauschlitz im Gehaeuse; auf dem Oszilloskop fehlt
  der Cursor (die Form wird trotzdem angezeigt). Beide reagieren dann nicht
  auf die Maus; die Blase bleibt beim Startradius bzw. Kreis.
- **Schrotthaufen** (`scenes/objects/scrap_heap.tscn`, Skript
  `scripts/objects/scrap_heap.gd`): Node unten in der Mitte (auf den Boden
  stellen), 32 x 24 px, funkelt (gelb-weisses Kreuz an wechselnden Stellen).
  Beruehrt der Professor ihn, wird das Upgrade sofort eingebaut (keine
  Taste noetig), Funken fliegen, vom Haufen bleiben Reste. Signal
  `collected(upgrade)`. Ist das Upgrade schon da, liegen von Anfang an nur
  die Reste.
- **Einblendung** (`scripts/ui/upgrade_message.gd`): Kasten oben in der
  Mitte, Ueberschrift "TIME SHIFTER UPGRADE", Name und Bedienhinweis, 5 s
  lang (Spielzeit), dann weg. Texte in `dialogues/upgrades.json` (englisch,
  Kennungen `upgrade_radius`, `upgrade_shape`). Damit die Datei im Export
  landet, steht `dialogues/*.json` im Include-Filter beider Export-Vorlagen.
- Globales System `Upgrades` (Autoload): `has()`, `unlock()`,
  `unlock_all()`, `reset()`; fuer den Spielstand (Schritt 16) `get_ids()` und
  `set_ids()` mit festen Kennungen. Die Upgrades bleiben beim Neustart des
  Levels (Tod) erhalten.
- Im Testlevel: Schrotthaufen "Radius" auf der Stufe (x = 224), "Form" auf
  Block 1 (x = 352), dazwischen der Laser.

**Regeln der Zeitblase:**

- Die Blase ist dauerhaft aktiv; auf Stufe "normal" ist sie faktisch aus.
- Keine Begrenzung durch Energie, Abklingzeit o. Ae. Die Level werden so
  gestaltet, dass sie trotzdem anspruchsvoll sind.
- Ein Objekt wird beeinflusst, sobald es die Blase beruehrt (es muss nicht
  vollstaendig drin sein).
- Zusammenhaengende Objekte (z. B. ein Pendel) werden als Ganzes
  beeinflusst.
- Empfehlung: beeinflusste Objekte sichtbar markieren (z. B. farbiger
  Schimmer). Festgelegt am 09.11.2026: keine farbige Umrandung im fertigen
  Spiel (nur als Test-Option, siehe 2.3 Umsetzung). Sichtbar wird die
  Wirkung kuenftig ueber den Blasen-Shader (siehe unten).

**Darstellung der Zeitblase als Shader (geplant, festgelegt am 10.11.2026):**

Die Blase wird spaeter nicht mehr als farbiger Kreis gezeichnet, sondern als
Shader, der das Bild innerhalb ihres Bereichs leicht verzerrt.

- **Effekt:** kleiner Wobble, als wuerde man durch Wasser oder eine
  gekruemmte Glasscheibe schauen.
- **Bereich:** nur innerhalb von Radius bzw. Form der Blase (auch bei der
  Eiform durch den Formregler).
- **Farben:** zusaetzlich eine leichte chromatische Aberration (Rot-Gruen-
  bzw. Rot-Blau-Verschiebung der Farbkanaele wie bei alten 3D-Brillen). Die
  dabei entstehenden Farben ausserhalb von Resurrect 64 sind erlaubt
  (Ausnahme Zeitblase, 1.7). Passt zur Themen-Option "Farb- bzw.
  Pixelverschiebung" (1.11).
- **Stellschrauben:** Staerke von Verzerrung und Farbverschiebung als
  Parameter, um zu experimentieren.
- **Tempo (festgelegt):** Der Wobble passt zur Zeitstufe: langsam = traege,
  schnell = hektisch, auf "normal" kaum sichtbar.
- Ersetzt den bisherigen farbigen Kreis (siehe Umsetzung unten). Die Farben
  langsam / normal / schnell bleiben fuer Bedienfeld und Symbol.

**Werte** (Datendatei `data/time_bubble_settings.tres`, im Inspector
aenderbar; Skript `scripts/time_bubble/time_bubble_settings.gd`):

| Wert | Standard |
| --- | --- |
| Tempo auf Stufe langsam / schnell | x 0,3 / x 2,0 |
| Radius beim Start / kleinster / groesster | 80 / 32 / 80 px (groesster bis 12.11.2026: 128) |
| Groesste Streckung (Laenge des Eis) | 2-mal der Durchmesser (`stretch_max`; bis 12.11.2026: 2,5) |
| Einrasten des Cursors an den Mittellinien | 8 % des Wegs (`stretch_snap`) |
| Farbe langsam / normal / schnell | `4d9be6` (Blau) / `c7dcd0` (Hellgrau) / `fb6b1d` (Orange) |
| Deckkraft Flaeche / Rand / Rand auf "normal" | 0,12 / 0,7 / 0,25 |

**Formregler (umgesetzt in Schritt 13, 11.11.2026):**

- **Verhalten (festgelegt am 11.11.2026):** einseitig strecken, als Ei in
  Richtung des Cursors. Cursor in der Mitte = Kreis. Cursor rechts: Das Ei
  streckt sich nach rechts vom Professor weg, die linke Kante bleibt beim
  Radius. Cursor in der Ecke (z. B. x = y = 1): Ei schraeg nach rechts
  unten. Verformen und Verschieben stecken damit im Cursor.
- **Eiform (Wunsch des Nutzers, 11.11.2026):** Der breite Teil liegt um den
  Professor, der schmale zeigt nach aussen. Hinten ein Halbkreis mit dem
  Radius um den Professor, vorn eine halbe Ellipse bis zur Spitze (gleiche
  Breite am Uebergang, also ohne Knick).
- **Cursor statt Schieberegler (Wunsch des Nutzers, 11.11.2026):** Die
  beiden Schieberegler sind entfallen. Auf dem Oszilloskop sitzt ein
  Fadenkreuz-Cursor (offenes Quadrat in `fbb954` mit gestrichelten Linien in
  `9e4539` quer ueber den Bildschirm). Klicken oder Ziehen auf dem
  Bildschirm setzt ihn; der Rand des Cursor-Bereichs (6 px innerhalb des
  Bildschirms) ist volle Streckung. Nahe den Mittellinien rastet jede Achse
  einzeln ein.
- Rechnung: Staerke a = Laenge des Cursor-Vektors (hoechstens 1, die Ecken
  zaehlen also wie die Seitenmitten), Richtung = Richtung des Vektors.
  Abstand der Spitze vom Professor = Radius x (1 + 2a x (stretch_max - 1)).
  Beruehrung: Umriss als Polygon (64 Punkte) gegen das Rechteck des Objekts.
- **Drehregler:** Radius, 32 bis 80 px (12.11.2026 auf die untere Haelfte
  des alten Bereichs begrenzt, groesser war zu gross; die Skala umfasst den
  neuen Bereich, der Startradius 80 steht damit am rechten Anschlag).
  Bedienung "magnetisch": Klicken bzw. Maustaste halten, der Zeiger dreht
  sich zur Maus (links unten = kleinster, oben = Mitte, rechts unten =
  groesster Radius). Zeigt die Maus in die Luecke unten, bleibt er am
  naeheren Anschlag. Die Maus darf beim Ziehen den Regler verlassen.
- Rechtsklick setzt zurueck (auf dem Oszilloskop: Cursor in die Mitte;
  auf dem Drehregler: Startradius).
- **Oszilloskop:** gruene Leuchtspur auf dunklem Raster zeigt die Form der
  Blase relativ zum Professor (kleines Kreuz, immer in der Bildschirmmitte).
  Fester Massstab (12.11.2026): Die Spitze des groesstmoeglichen Eis
  (groesster Radius, volle Streckung) reicht vom Kreuz gerade bis an den
  Rand, jede Form ist also immer vollstaendig zu sehen. Der Kreis mit
  Startradius hat etwa 23 px Radius. Der Leuchtpunkt laeuft je nach Zeitstufe langsamer oder schneller um
  (0,25 / 0,7 / 2 Umlaeufe pro Sekunde), auch bei pausiertem Spiel.
- Die Blase im Spiel zeichnet sich als Ei; Objekte werden erfasst, sobald
  sie das Ei beruehren.
- Beim Neustart des Levels ist die Blase wieder ein Kreis mit Startradius
  (wie die Zeitstufe, die auf "normal" zurueckgeht).
- Drehregler und Cursor werden seit Schritt 14 ueber Schrotthaufen
  freigeschaltet (siehe Upgrades oben).

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
  Blase beruehrt (Rechteck gegen Kreis bzw. seit Schritt 13 Ei, rein
  rechnerisch, ohne Physik-Ebene), und stellt `time_scale` bereit. Das
  Objekt rechnet mit `delta * time_scale`.
- Markierung: Beeinflusste Objekte bekommen einen 1-px-Rahmen in der Farbe
  der Stufe (Palettenfarbe, nicht halbtransparent). **Nur zum Testen**
  (festgelegt am 09.11.2026): Standard aus, einschaltbar im F1-Menue
  ("Time markers"); im fertigen Spiel nie sichtbar.
- Zeitstufe umschalten (Schritt 6): Shift halten oeffnet das Bedienfeld
  (`scenes/ui/time_shifter_panel.tscn`), das Spiel pausiert. Der
  **Zeitregler** sieht aus wie eine Tankanzeige: Bogen aus drei Stuecken
  (links blau = langsam, oben grau = normal, rechts orange = schnell), aussen
  je ein Symbol (1, 2, 3 Pfeile), rote Nadel. Mit der Maus auf einen Bereich
  klicken oder die Nadel ziehen; die gewaehlte Stufe leuchtet, die anderen
  sind abgedunkelt, die Nadel schwenkt hin. Shift loslassen: Bedienfeld
  weg, Spiel laeuft mit der neuen Stufe weiter.
- Alternativ (09.11.2026): Shift + Mausrad hoch = eine Stufe schneller,
  Shift + Mausrad runter = eine Stufe langsamer; an den Enden bleibt die
  Stufe stehen (kein Umlauf). Wirkt ueberall im Fenster, die Maus muss nicht
  ueber dem Regler sein.
- Das Bedienfeld wird 2-fach gezeichnet (448 x 288 px) und im Code mit
  Palettenfarben gemalt (`scripts/ui/time_gauge.gd`). Der Hintergrund wird
  mit einem Rastermuster (`ui_dither_dark.png`, jedes zweite Pixel dunkel)
  abgedunkelt statt mit Transparenz, damit keine Mischfarben entstehen.
- Aufbau seit Schritt 13: Node `Controls` (440 x 152, 2-fach gezeichnet,
  mittig) mit Zeitregler links, Oszilloskop mit Cursor (152 x 152) und
  Drehregler rechts. Skripte in `scripts/ui/`: `time_gauge.gd`,
  `oscilloscope.gd`, `radius_knob.gd`; gemeinsamer Look in
  `panel_style.gd`. Das Mausrad mit Shift bleibt fuer die Zeitstufe.
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
- Umgesetzt (Schritt 9, 08.11.2026): `scenes/objects/projectile.tscn`,
  64 x 32 px, fliegt nur waagrecht und verschwindet beim Aufprall auf Ebene 1
  (Tiles, Plattformen, Werfer) oder nach `max_distance`. Oberseite begehbar,
  man fliegt mit. Die Seiten sind toedlich (Kind-Node `SideHazard`, 4 px
  Abstand zu Ober- und Unterkante). Der Stoss von unten ist **nicht**
  toedlich. Wer gerade oben stand, hat 0,15 s Schonzeit, damit das
  Herunterlaufen an der Kante nicht sofort toetet.
- Wichtig beim Erzeugen per Code (Fehler behoben am 09.11.2026): Die Position
  eines AnimatableBody2D **vor** `add_child()` setzen. Im Baum uebernimmt er
  eine neue Position erst im naechsten Physik-Schritt; vorher stand das
  Projektil fuer ein Bild bei (0, 0) (links oben im Level).
- **Projektil-Werfer:** `scenes/objects/projectile_launcher.tscn` (32 x 48,
  fest, Ebene 1). Im Inspector je Werfer: `direction` (rechts/links),
  `fire_interval` (Standard 4 s), `first_shot_delay` (Standard 1 s, zum
  Versetzen mehrerer Werfer), `projectile_speed` (Standard 120 px/s, langsamer
  als der Professor), `max_distance`, `active`, `projectiles_block_laser`
  (Standard aus; an = seine Projektile halten toedliche Laser auf, 12a).
  Sein Takt laeuft in der
  Zeitblase mit. Er ist Signal-Empfaenger (Lichtschranke kann ihn schalten).
- Ladebalken (09.11.2026, Wunsch des Nutzers): Im Gehaeuse fuellt sich ein
  senkrechter gelber Balken (6 x 22 px) bis zum naechsten Schuss; ist er voll,
  feuert der Werfer. Er laeuft mit dem Takt, also auch langsamer oder
  schneller in der Zeitblase, und bleibt stehen, solange der Werfer aus ist.

**Pendel / rotierende Gefahr**

- Toedliches Objekt an einem Seil, pendelt oder rotiert zu schnell zum
  Passieren; durch Verlangsamen ueberwindbar.
- Ideen fuer Beschleunigung: Ein schneller schwingendes Pendel trifft einen
  Schalter oder zerschlaegt eine Wand; zwei gegenlaeufige Pendel
  synchronisieren, um eine Luecke zu erzeugen.
- Umgesetzt (Schritt 11, 09.11.2026): `scenes/objects/pendulum.tscn`, eine
  Szene fuer beide Varianten. Der Node ist der Aufhaengepunkt; daran haengt an
  einer Stange eine Stachelkugel (32 x 32, toedlicher Kreis mit Radius 13,
  etwas nachsichtig). Nur die Kugel ist toedlich, die Stange nicht. Im
  Inspector: `mode` (schwingen / drehen), `length` (Standard 96 px),
  `amplitude` (nur schwingen, Grad zu jeder Seite, Standard 45), `period`
  (ganze Schwingung bzw. Drehung, Standard 1,6 s), `start_phase` (zum
  Versetzen mehrerer Pendel), `clockwise` (nur drehen). Im Editor sofort an
  der Startstellung sichtbar. Die Zeitblase wirkt, sobald sie die Kugel
  beruehrt. Das Bild der Kugel dreht sich nicht mit (sonst passen Licht und
  Schatten nicht), nur die Stange schwenkt.
- Noch nicht gebaut: Pendel trifft Schalter bzw. zerschlaegt eine Wand
  (Ideen oben); Pendel als Signal-Empfaenger. Folgt, wenn ein Level es
  braucht.

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
- Von unten durchspringbar (09.11.2026, Wunsch des Nutzers): Einweg-Kollision,
  man stoesst nicht mit dem Kopf an und landet oben drauf.

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
- Aussehen (seit Schritt 12a blau, damit Rot dem toedlichen Laser
  vorbehalten ist): Strahl 3 px (`4d9be6`, Kern `8fd3ff`), verbraucht
  `484a77`, Blitz weiss. Linse des Senders ebenfalls blau.
- Auch Projektile loesen sie aus (festgelegt am 09.11.2026). Ausgeloest wird
  nur, wenn der Strahl vorher frei war: Wer auf einem Projektil mitfliegt,
  durchquert den Strahl zusammen mit ihm, das zaehlt als ein Durchqueren.
- Offen: Ob die Zeitblase auf die Lichtschranke wirkt (bisher nicht).

**Toedlicher Laser (festgelegt am 10.11.2026, umgesetzt in Schritt 12a)**

- Laserstrahl zwischen zwei Sendern wie bei der Lichtschranke, aber
  toedlich: Beruehrt der Professor den Strahl, stirbt er. Er sendet kein
  Signal.
- Aufbau wie `light_barrier`: Node = Sender A, Sender B bei `beam_end`
  (relativ), im Editor sichtbar.
- Tod ueber den Baustein `Hazard` (Ebene 2 "player"); der Schalter
  "Unverwundbar" im F1-Menue gilt.
- **Takt (festgelegt):** Der Laser geht im Takt an und aus. Im Inspector:
  Dauer an, Dauer aus und Startversatz (zum Versetzen mehrerer Laser);
  optional dauerhaft an. Der Takt laeuft in der Zeitblase langsamer oder
  schneller mit.
- **Aussehen:** Rot, damit er sich klar von der (dann blauen) Lichtschranke
  unterscheidet; dickerer Strahl und leichtes Flackern. Kurz vor dem
  Einschalten erscheint als Warnung ein duenner, blasser Strahl
  (festgelegt). Alle Farben aus Resurrect 64.
- **Signal-Empfaenger (festgelegt am 12.11.2026):** `activate()` schaltet
  ein (der Takt beginnt mit dem Warnstrahl), `deactivate()` schaltet ganz
  aus (Takt steht), `toggle()` schaltet um.
- **Projektile (festgelegt am 12.11.2026):** Optional halten Projektile den
  Strahl auf; hinter dem Projektil ist er unterbrochen. Einstellbar am
  Werfer (`projectiles_block_laser`, Standard aus), weil die Projektile vom
  Werfer erzeugt werden.
- **Umsetzung (Schritt 12a, 12.11.2026):** Szene
  `scenes/objects/deadly_laser.tscn`, Skript `scripts/objects/deadly_laser.gd`
  (abgeleitet von `Hazard`). Im Inspector: `beam_end` (Standard 9 Tiles nach
  oben), Gruppe Takt: `on_time` und `off_time` (je 1,5 s, die Warnung zaehlt
  zur Aus-Zeit), `start_offset` (Versatz im Takt beim Levelstart, 0 =
  beginnt mit "an"), `warning_time` (0,4 s), `always_on`; Gruppe Steuerung:
  `active` (laeuft beim Start). Zustaende aus, Warnung, an; toedlich nur
  "an" (steht der Professor beim Einschalten im Strahl, stirbt er). Der Takt
  laeuft mit der Zeitblase, sobald sie irgendeinen Teil des Strahls
  beruehrt. Signal `switched(is_on)` beim An- und Ausgehen.
- **Aussehen (umgesetzt):** an = 5 px `ae2334` aussen, 3 px `e83b3b`, Kern
  1 px `f68181`, der flackernd weiss aufblitzt (aussen dann 4 px); Warnung =
  1 px `f68181` gestrichelt; aus = nur die Sender. Im Editor wird der
  Strahl immer "an" gezeigt.
- Im Testlevel steht ein Laser bei x = 304 (vor Block 1) im Standardtakt.

**Signal-Empfaenger (Schnittstelle, 07.11.2026)**

- Alles, was von Ausloesern (Lichtschranke, Trefferflaeche) gesteuert
  wird, hat die Funktionen `activate()`, `deactivate()` und `toggle()`.
  Bisher: fliegende Plattform, Projektil-Werfer, Tuer, Zeitschaltuhr (die
  selbst auch Ausloeser ist), toedlicher Laser. Spaetere Empfaenger
  bauen dieselben drei Funktionen ein; der Ausloeser muss dafuer nicht
  geaendert werden. Das Senden an die Ziele uebernimmt bei allen Ausloesern
  `scripts/objects/signal_sender.gd`.
- Idee: aus der Ferne mit gestreckter Blase abbremsen, um sie zu erreichen,
  dann beschleunigen (z. B. um vor einer sich schliessenden Tuer anzukommen).

**Timer / Zeitschaltuhr / Zeitbombe**

- Laeuft in der Blase langsamer oder schneller; zwei asynchrone Timer
  lassen sich synchronisieren.
- Gut zum Erlernen der Mechanik ohne Gefahr.
- Ideen: Tuer mit Zeitschaltuhr laenger offen halten; Bombe bremsen, um zu
  entkommen, oder beschleunigen, um eine Wand zu sprengen.
- Umgesetzt (Schritt 12, 09.11.2026): Zeitschaltuhr
  `scenes/objects/time_switch.tscn` (32 x 32, Node in der Mitte, keine
  Kollision). Sie sitzt zwischen Ausloeser und Zielen: Ein Signal startet den
  Countdown und sendet sofort `start_action` (Standard einschalten, z. B. Tuer
  auf); nach Ablauf sendet sie `end_action` (Standard ausschalten, Tuer zu).
  Im Inspector: `duration` (Standard 3 s), `targets`, `start_action`,
  `end_action`, `restart_on_trigger` (neues Signal startet die Zeit von vorn,
  Standard an), `autostart`, `repeat` (Taktgeber, startet nach Ablauf neu).
- Signal-Empfaenger: `activate()` = starten bzw. neu starten,
  `deactivate()` = sofort beenden, `toggle()` = starten bzw. beenden. Ein
  Neustart waehrend des Laufens sendet kein zweites Startsignal (wichtig bei
  "umschalten").
- Ziffernblatt: Die Restzeit schrumpft als gelbes Tortenstueck im
  Uhrzeigersinn, im letzten Viertel rot; der Zeiger steht an der Kante.
  In der Zeitblase laeuft sie langsamer oder schneller.
- Noch nicht gebaut: Zeitbombe (Idee oben).

**Toedliche Objekte: Baustein Hazard (07.11.2026)**

- Alles Toedliche nutzt den Baustein `Hazard` (Area2D, erkennt Ebene 2
  "player"): Beruehrt der Professor die Flaeche, ruft er dessen `die()` auf.
  Geprueft wird jeden Physik-Schritt; abgeleitete Skripte koennen ueber
  `_is_safe_for()` Ausnahmen festlegen (z. B. Schonzeit beim Projektil).
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
- Umgesetzt (Schritt 10, 08.11.2026): `scenes/objects/impact_switch.tscn`
  (16 x 48, fest, Ebene 1, Node in der Mitte). Im Inspector: `targets` und
  `action` (umschalten / einschalten / ausschalten) wie bei der
  Lichtschranke. Nur Projektile loesen aus, der Professor nicht; er kann aber
  darauf stehen. Beim Treffer verschwindet das Projektil und es spruehen kurz
  Funken. Beliebig viele Treffer, je Treffer ein Signal.
- Technik: Das Projektil ruft beim Aufprall `on_projectile_hit()` am
  getroffenen Objekt auf, falls es die Funktion hat. Spaetere Objekte, die auf
  Treffer reagieren, bauen dieselbe Funktion ein.
- Offen: Synchron-Raetsel (zwei Treffer innerhalb von ca. 0,5 s, siehe
  Projektil). Noch nicht gebaut, Umsetzung folgt, wenn das erste Level es
  braucht.

**Tuer (Schritt 10, 08.11.2026)**

- `scenes/objects/door.tscn` (16 x 80, Ebene 1, Node in der Mitte der
  geschlossenen Tuer). Im Inspector: `travel` (Weg von zu nach auf, Standard
  80 px nach oben), `move_time` (Standard 0,4 s), `start_open`.
- Signal-Empfaenger: `activate()` = oeffnen, `deactivate()` = schliessen,
  `toggle()` = umschalten. Oeffnen und Schliessen laufen in der Zeitblase
  langsamer oder schneller.
- Haelt den Professor und Projektile auf. Steht beim Schliessen jemand im Weg
  (Ebene 2 oder 3), wartet sie und schliesst danach weiter; es gibt also kein
  Einklemmen und keinen Tod durch die Tuer.
- Liegt hinter den Tiles (`z_index` -1). Beim Levelbau einen Sturz aus Tiles
  ueber die Tuer setzen, der mindestens so hoch ist wie der Weg `travel` und
  unten weniger als die Sprunghoehe (ca. 100 px) Luecke laesst: Dann
  verschwindet die offene Tuer darin und man kann sie nicht ueberspringen.

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
    6.2); dort wird Beenden ausgeblendet.
  - **Umgesetzt (Schritt 16, 12.11.2026):** `scenes/ui/title_screen.tscn`
    (Skript `scripts/ui/title_screen.gd`) ist die Hauptszene. Schriftzug
    "TIME SHIFTER", Knoepfe New Game, Continue, Quit; bedienbar mit Maus
    und Tastatur (Pfeiltasten, Enter; Fokus startet auf Continue, ohne
    Spielstand auf New Game). Sicherheitsabfrage als Kasten mit Yes/No
    (Fokus auf No, Esc = No). Texte in `dialogues/menu.json`. Platzhalter-
    Look in Palettenfarben, echte Gestaltung mit Schritt 19.
  - Bis das Intro (3.5) gebaut ist, startet New Game direkt im ersten Level
    der Reihenfolge.
- **Intro-Sequenz** nach New Game: Comic zum Durchklicken (siehe 3.5),
  danach startet das Spiel direkt in der Werkstatt.
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

- **Was wird gespeichert:** der Spielfortschritt: erreichtes Level
  (Kennung = Dateiname), freigeschaltete Upgrades (Kennungen) und
  Fortschrittsmarken. Nicht gespeichert: Zustand innerhalb eines Levels
  (Neustart am Levelanfang).
- **Wo der Spieler nach dem Laden startet:** am Anfang des zuletzt
  erreichten Levels (Klonstation).
- **Anzahl Spielstaende:** einer (New Game ueberschreibt ihn).
- **Wann gespeichert wird:** automatisch zu Beginn jedes Levels aus der
  Levelreihenfolge (auch beim Neustart nach dem Tod; so bleiben Upgrades aus
  dem Level erhalten). Das Testlevel speichert nicht. Im Browser genauso:
  Godot legt `user://` dort dauerhaft im Browser-Speicher (IndexedDB) ab.
- **Technik (umgesetzt in Schritt 16):** globales System `SaveGame`
  (`scripts/autoload/save_game.gd`), die einzige Stelle, die speichert und
  laedt. JSON-Datei `user://savegame.json` mit `version` (derzeit 1),
  `level`, `upgrades`, `flags`. Geschrieben wird erst in eine Zwischendatei,
  dann umbenannt (bricht das Schreiben ab, bleibt der alte Stand heil).
  Fehlt die Datei, gibt es keinen Spielstand; ist sie beschaedigt oder
  stammt aus einer neueren Version, wird sie als `.bak` beiseite gelegt.
  Aeltere Versionen wandelt `_upgrade_data()` um, sobald sich das Format
  aendert. Continue laedt den Stand und startet am Anfang des gespeicherten
  Levels (unbekannte Kennung = erstes Level). New Game setzt alles zurueck;
  der alte Stand wird beim ersten Level ueberschrieben.
- **Testmodus:** Nach dem Laden eines Test-Szenarios (F1) wird in
  `user://savegame_test.json` gespeichert; der echte Spielstand bleibt
  unberuehrt. New Game oder Continue beenden den Testmodus.
- **Fortschrittsmarken (Story Flags):** benannte Ja-Nein-Marken fuer jede
  Teilhandlung; Benennung siehe 1.6.

### 2.8 Texte und Dialoge

- Festgelegt: Der Professor droppt immer wieder zufaellige lustige Sprueche,
  dargestellt als **Sprechblase ueber dem Professor**. Inhalt und Beispiele
  siehe 3.6.
- Respawn-Kommentar an der Klonstation (siehe 2.6).
- Intro und Abspann siehe 3.5. Das Intro kommt ohne Text aus (nur Bilder
  und vereinzelte Emoji-Sprechblasen).
- Fahrstuhl in der Werkstatt: Mit E erscheint eine Sprechblase des
  Professors (Keycard geroestet, Fahrstuhl nicht nutzbar). Text englisch in
  `dialogues/speech.json` (Kennung `speech_elevator_keycard`). Vorschlag der
  KI (12.11.2026, aenderbar): "My keycard is toast. Literally. Guess I'm
  taking the scenic route... through my own traps." (Entwurf: "Meine
  Keycard ist Toast. Woertlich. Dann nehme ich wohl die Panoramaroute ...
  durch meine eigenen Fallen.")
- **Sprechblase, einfache Fassung (Schritt 16a):** `scripts/ui/speech_bubble.gd`
  (`SpeechBubble.say(figur, text_id)`): weisser Kasten mit dunklem Rand und
  Spitze nach unten ueber dem Kopf, folgt der Figur, bricht nach 220 px um,
  steht 2 s plus 0,05 s pro Zeichen, das Spiel laeuft weiter. Eine neue
  Blase ersetzt die alte. Das richtige System folgt mit Schritt 18.
- Spieltexte liest `scripts/ui/game_texts.gd` (`GameTexts.get_text(datei,
  kennung)`) aus `dialogues/<datei>.json`; fehlt eine Kennung, erscheint die
  Kennung selbst.
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
  **Festgelegt am 10.11.2026:** Die Level baut der Nutzer selbst; die KI
  liefert die Bausteine.

**Level-Builder (umgesetzt in Schritt 15, 12.11.2026)**

So entsteht ein neues Level:

1. Im Godot-Editor: Szene > Neue geerbte Szene, `scenes/levels/level_base.tscn`
   waehlen, als `scenes/levels/<name>.tscn` speichern (englisch,
   `snake_case`; der Dateiname ist die Kennung des Levels und wird danach
   nicht mehr geaendert).
2. Den Node `Ground` waehlen und mit dem Tileset malen (die Vorlage bringt
   einen Raum von 60 x 34 Tiles mit Boden, Decke und Waenden mit, der
   beliebig umgemalt und vergroessert werden darf). Die Kameragrenzen
   folgen automatisch der bemalten Flaeche (Skript `scripts/levels/level.gd`,
   Schalter `auto_camera_limits`).
3. `CloneStation` (Start) und `LevelExit` (Ziel) an ihre Plaetze ziehen.
4. Bausteine aus `scenes/objects/` per Drag-and-drop aus dem Dateisystem
   ins Level ziehen und im Inspector einstellen (Tabelle unten). Signale:
   beim Ausloeser die Ziele in `targets` eintragen.
5. Das Level in `data/level_order.tres` an der gewuenschten Stelle der
   Liste `levels` eintragen.

Die Vorlage enthaelt: Hintergrund (`Background`), `Ground`, `CloneStation`,
`LevelExit`, `Professor`, `Camera` (folgt dem Professor), Zeitsymbol
(`TimeStageIndicator`) und Bedienfeld (`TimeShifterPanel`). Aendert sich die
Vorlage (z. B. neues UI-Element), haben es sofort alle Level. Geerbte Nodes
lassen sich im Level verschieben und einstellen, aber nicht loeschen.

**Bausteine** (alle in `scenes/objects/`, Node-Ursprung jeweils wie
angegeben; Details in 2.4):

| Baustein | Szene | Ursprung | Wichtige Einstellungen |
| --- | --- | --- | --- |
| Klonstation | `clone_station` | Boden, Mitte | `spawn_time`, `restart_delay` |
| Ausgang | `level_exit` | Boden, Mitte | `target_level` (leer = Reihenfolge) |
| Fliegende Plattform | `flying_platform` | Mitte | `travel`, `travel_time`, `start_offset`, `wait_time`, `active` |
| Lichtschranke | `light_barrier` | Sender A | `beam_end`, `targets`, `action`, `one_shot` |
| Toedlicher Laser | `deadly_laser` | Sender A | `beam_end`, Takt, `start_offset`, `always_on`, `active` |
| Starkstrom-Boden | `electric_floor` | links oben | `width_tiles` |
| Projektil-Werfer | `projectile_launcher` | Mitte | Richtung, Takt, Tempo, `projectiles_block_laser` |
| Trefferflaeche | `impact_switch` | Mitte | `targets`, `action` |
| Tuer | `door` | Mitte | `travel`, `move_time`, `start_open` (Signal-Empfaenger) |
| Zeitschaltuhr | `time_switch` | Mitte | `duration`, `targets`, Aktionen, `repeat` |
| Pendel / Stachelkugel | `pendulum` | Aufhaengung bzw. Achse | `mode`, `length`, `amplitude`, `period`, `start_phase`, `clockwise` |
| Schrotthaufen | `scrap_heap` | Boden, Mitte | `upgrade` |
| Fahrstuhl | `elevator` | Boden, Mitte der Tuer | `text_id`, `prompt_offset` |
| Wandhinweis | `wall_hint` | Mitte oben | `keys`, `text_id`, `paint` |

**Levelfolge:** `data/level_order.tres` (Skript `scripts/levels/level_order.gd`)
listet die Level in Spielreihenfolge. Das globale System `LevelFlow` laedt
bei New Game das erste Level (Hauptszene ist seit Schritt 16 der
Titelbildschirm). Der Ausgang fuehrt zum naechsten Eintrag; nach dem
letzten erscheint ein vorlaeufiger Endbildschirm ("To be continued...",
Taste = Titelbildschirm). Liegt ein Level nicht in der Liste (z. B.
das Testlevel), fuehrt sein Ausgang zum ersten Level.

**Ausgang:** Schiebetuer 32 x 64 mit blinkendem gruenen Pfeil nach oben (das
naechste Level liegt eine Etage hoeher). Laeuft der Professor hinein, geht
die Tuer auf, er verschwindet (Steuerung gesperrt, Gefahren wirken nicht
mehr), der Bildschirm blendet ueber das Rastermuster ab, das naechste Level
laedt und blendet wieder auf (je Stufe 0,12 s, nur Palettenfarben).

**Beispiel-Level (Platzhalter):** `level_example_1` (Bloecke zum Springen,
seit 16a mit Fahrstuhl und drei Wandhinweisen "A D Move", "E Interact",
"SPACE Jump")
und `level_example_2` (toedlicher Laser bis zur Decke) zeigen Vorlage und
Levelfolge. Sie werden durch die echten Level des Nutzers ersetzt.

**Erstes Level: Tutorial in der Werkstatt (festgelegt am 10.11.2026)**

Ein gefuehrtes Tutorial mit langsam steigender Schwierigkeit:

1. **Laufen:** An der Wand im Hintergrund sind die Tasten A und D
   aufgemalt, darunter "Move".
2. **Interagieren:** Am Fahrstuhl steht der Hinweis E zum Interagieren. Mit
   E erscheint die Sprechblase zur geroesteten Keycard.
3. **Springen:** Vor der ersten Sprungstelle steht an der Wand Leertaste mit
   "Jump".
4. **Time Shifter:** Hinweis Shift halten fuer das Bedienfeld, dann Mausrad
   bzw. Maus zum Einstellen der Zeit.
5. **Erstes Pflichtraetsel:** ein einfaches Raetsel, das nur mit dem Time
   Shifter loesbar ist. Der Nutzer entwirft es selbst.

**Baustein Wandhinweis (umgesetzt in Schritt 16a):** Objekt, das der
Nutzer per Drag-and-drop ins Level zieht (`scenes/objects/wall_hint.tscn`,
Node = Mitte oben). Im Inspector: `keys` (Beschriftungen der Tasten, z. B.
"A", "D" oder "SPACE", "SHIFT"), `text_id` (Wort aus `dialogues/hints.json`:
`hint_move`, `hint_jump`, `hint_interact`, `hint_time_shifter`,
`hint_time_wheel`; leer = kein Wort) und `paint` (Wandfarbe: dunkel, hell,
gelb, rot, blau, alle aus der Palette). Aufgemalt wirken die Tasten durch
Umriss und Schrift in Wandfarbe. Liegt hinter allem (z_index -10), keine
Kollision, im Editor sofort sichtbar.

**Baustein Fahrstuhl (umgesetzt in Schritt 16a):** `scenes/objects/elevator.tscn`
(Node = Boden, Mitte der Tuer; 64 x 80 mit Keycard-Leser rechts, dessen
Lampe rot blinkt). Steht der Professor davor, erscheint die E-Anzeige; E
laesst ihn den Text `text_id` sagen (Standard `speech_elevator_keycard`).

**Grundbaustein Interagieren (Schritt 16a):** `scripts/objects/interactable.gd`
(Klasse `Interactable`, Area2D, erkennt Ebene 2). Steht der lebende
Professor im Bereich, schwebt bei `prompt_offset` eine weisse Tastenkappe
"E" leicht auf und ab; E ruft `_on_interact()` auf und sendet
`interacted`. Kuenftige Objekte zum Interagieren erben davon. Tastenkappen
zeichnet `scripts/ui/key_cap.gd` (Breite passt sich der Beschriftung an).

**Baustein Rohre, Tileset (geplant):** Rohre mit Dampf als Bau- und
Dekoelement, kein eigenes Jump-and-Run-Element. Das Tileset erstellt die
KI, der Nutzer malt damit im Level.

- Groesse: 16 x 16 px pro Tile, das Rohr fuellt etwa ein Tile.
- Automatisches Verbinden als Terrain im Tileset von Godot (Autotiling):
  Beim Malen werden Geraden, Ecken, T-Stuecke, Kreuzungen und Enden
  automatisch passend gewaehlt.
- Zwei Varianten: **Vordergrund** mit Kollision (Ebene 1 "world"), nutzbar
  als Wand oder Plattform; **Hintergrund** ohne Kollision, reine Deko hinter
  der Spielebene.
- Grafik: Palette Resurrect 64, Pixel Art, Quelle als `.aseprite`. Dampf
  optional leicht animiert.
- Name: `tileset_pipes`.

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

1. **Intro-Sequenz** (Konzept festgelegt am 10.11.2026; ersetzt den
   frueheren Entwurf):
   - **Form:** Comic zum Durchklicken, **kein Text**. Nur Bilder und
     vereinzelte Emoji-Sprechblasen (z. B. Pizza-Symbol).
   - Geteilte Szenen bauen sich Klick fuer Klick auf: Erst erscheint das
     linke Panel, beim naechsten Klick das rechte. Das linke Panel bleibt
     stehen, bis zur naechsten Szene weitergeklickt wird.
   - Jedes Panel ist leicht animiert (kleine Schleife aus etwa 2 bis 3
     Frames, z. B. Schweissfunken, wackelndes Telefon), kein richtiges
     Video.
   - Danach startet direkt das Spiel in der Werkstatt.
   - **Szenen:**
     1. *Pizza-Bestellung* (geteilt, Trennwand in der Mitte): Links
        telefoniert der Erfinder, Sprechblase mit Pizza-Emoji. Rechts nimmt
        der Lieferdienst die Bestellung entgegen.
     2. *Schweissen:* Der Erfinder schweisst am Time Shifter. Der Spieler
        soll verstehen, dass er an einer Zeitmaschine baut.
     3. *Keycard und Lieferwagen* (geteilt): Links zerstoert ein
        elektrischer Impuls des Time Shifters die Keycard. Rechts faehrt ein
        Transporter mit Pizza-Symbol zum Labor.
     4. *Ankunft* (geteilt): Rechts klingelt der Lieferdienst am Eingang zum
        unterirdischen Labor. Links erschrickt der Professor: Ohne Keycard
        kommt er nicht hoch und muss durch seinen eigenen Einbrecherschutz,
        also das Testareal mit den Fallen.
   - **Im Spiel danach:** Die Werkstatt hat einen Fahrstuhl. Interagiert der
     Spieler damit (E), erscheint eine Sprechblase des Professors: Keycard
     geroestet, Fahrstuhl nicht nutzbar. So wird ohne Text im Intro klar,
     warum der Fahrstuhl nicht geht.
   - Offen: Klick bzw. Taste zum Weiterschalten, Ueberspringen des Intros;
     Bildgroesse und Aufteilung der Panels; Text der Fahrstuhl-Sprechblase
     (englisch, Datendatei).
2. **Werkstatt** (Start), dann **Selbstschussanlage**, dann
   **Teslakammer** (siehe 2.9).
3. **Ende und Abspann:** Nach dem letzten Level nimmt der Professor oben die
   Pizza entgegen und faehrt mit dem Fahrstuhl zurueck ins Labor. Die
   Fahrstuhlfahrt nach unten ist der Abspann (Credits laufen waehrend der
   Fahrt); dabei isst er genuesslich seine Pizza. **Pointe (neu, festgelegt
   am 10.11.2026):** Nachdem er oben die Pizza abgeholt hat, haelt er die
   Keycard an den Fahrstuhl, und sie funktioniert doch: Sie war nie kaputt.
   Er faehrt mit der Pizza nach unten, waehrend der Abspann laeuft.
   (Ersetzt die alte Pointe "Eigentlich haette er die ganze Zeit den
   Fahrstuhl nehmen koennen".)

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
- Spoiler: [offen; Vorschlag: die Keycard-Pointe am Fahrstuhl nicht auf der
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
- [x] 8. F1-Entwicklermenue (1.9): Unverwundbar, Teleport, Level-Auswahl,
  alle Upgrades. (Umgesetzt: Unverwundbar, Teleport, Level-Auswahl, Level
  neu starten, alle Upgrades (Schritt 14). Test-Szenarien und Testmodus
  folgen mit Schritt 16.)

**Meilenstein 2: Spielelemente und Vertical Slice (Ziel 17.11.)**

- [x] 9. Projektil und Projektil-Werfer: toedlich bei seitlicher
  Beruehrung, man kann daraufstehen und mitfliegen.
- [x] 10. Schalter bzw. Trefferflaeche und Tuer (Projektil loest Impuls
  aus).
- [x] 11. Pendel bzw. rotierende Gefahr.
- [x] 12. Timer bzw. Zeitschaltuhr (z. B. Tuer bleibt laenger offen).
- [x] 12a. Toedlicher Laser im Takt (an, aus, Startversatz, Warnstrahl),
  dazu Lichtschranke auf Blau umstellen (eingeschoben am 10.11.2026, 2.4).
- [x] 13. Formregler: Cursor auf dem Oszilloskop (x und y), Radius, dazu
  die Oszilloskop-Anzeige.
- [x] 14. Schrotthaufen und Upgrades: Regler werden schrittweise
  freigeschaltet.
- [x] 15. Level-Builder und Levelfolge: Level-Vorlage (Klonstation,
  Ausgang), alle Elemente als Drag-and-drop-Bausteine, Levelreihenfolge in
  einer Datendatei, Wechsel zum naechsten Level.
- [x] 16. Titelbildschirm (New Game, Continue, Beenden) und Speichern bzw.
  Laden (2.5, 2.7).
- [x] 16a. Bausteine fuer Werkstatt und Tutorial (eingeschoben am
  10.11.2026, 2.9): Interaktionstaste E (`interact`), Fahrstuhl mit
  Sprechblase (geroestete Keycard), Wandhinweis (Taste(n) und Wort per
  Text-ID). Die Sprechblase nutzt das System aus Schritt 18; bis dahin eine
  einfache Fassung.
- [ ] 17. Werkstatt (Tutorial) und erste Level der Selbstschussanlage
  bauen (Platzhalter-Grafik). **Die Level baut der Nutzer**, die KI liefert
  die Bausteine und hilft. Danach: kompletter Testdurchlauf = Vertical
  Slice.

**Meilenstein 3: Inhalt und Grafik (Ziel 24.11.)**

- [ ] 18. Sprechblasen-System fuer die Sprueche des Professors (Texte
  englisch in Datendatei) inkl. Respawn-Kommentar.
- [ ] 19. Grafik: Farbpalette festlegen, Professor-Sprite mit Animationen,
  Tileset und Objekte der Selbstschussanlage.
- [ ] 19a. Tileset Rohre mit Autotiling, Vorder- und Hintergrund, Dampf
  optional animiert (eingeschoben am 10.11.2026, 2.9).
- [ ] 19b. Zeitblase als Shader: Wobble und chromatische Aberration im
  Bereich der Blase, Tempo je Zeitstufe, Staerke einstellbar (eingeschoben am
  10.11.2026, 2.3).
- [ ] 20. Restliche Level der Selbstschussanlage.
- [ ] 21. Teslakammer: Grafik, ggf. Magnet, Level.
- [ ] 22. Intro-Sequenz: Comic zum Durchklicken ohne Text, vier Szenen,
  Panels mit kleinen Animationsschleifen (3.5).
- [ ] 23. Ende und Abspann: Keycard funktioniert doch, Fahrstuhlfahrt nach
  unten mit Pizza, Credits waehrend der Fahrt (3.5).

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

**Stand vom 13.11.2026, Version v0.39**

- **Phase:** Meilenstein 2, Spielelemente und Vertical Slice (Ziel 17.11.).
- **Zuletzt erledigt:** Schritt 16a (Taste E, Fahrstuhl mit Sprechblase, Wandhinweis).
- **Naechster Schritt:** 17 (Werkstatt und erste Level bauen; die Level baut der Nutzer).
- **Spielbar:** Start (F5) mit Titelbildschirm (New Game, Continue, Quit), zwei
  Beispiel-Level ueber den Ausgang verbunden (Beispiel 1 mit Fahrstuhl, E = Sprechblase,
  und Wandhinweisen), automatisches Speichern am Levelanfang,
  danach vorlaeufiger Endbildschirm. Testlevel (ueber F1 oder F6) mit dem Professor (Idle-, Lauf- und Sprunganimation): laufen,
  springen, Kamera folgt; Shift + Maus stellt Zeitstufe ein, Radius und Form nach dem
  Fund der Schrotthaufen (Stufe, Block 1); fliegende
  Plattformen reagieren auf die Blase; Lichtschranke schaltet eine
  Plattform an und aus; Start in der Klonstation, Starkstrom-Luecke ist
  toedlich, danach Neustart; zwei Werfer feuern Projektile (Mitfliegen
  moeglich, seitlich toedlich); das Boden-Projektil trifft eine
  Trefferflaeche, die startet eine Zeitschaltuhr, die die Tuer 2,5 s oeffnet; ein Pendel unter
  Block 2 und eine rotierende Stachelkugel am Boden; ein toedlicher Laser im
  Takt vor Block 1; F1-Entwicklermenue.
- **Noch zu testen (vom Nutzer):** nichts offen.
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
