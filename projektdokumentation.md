# Projektdokumentation: [ARBEITSTITEL]

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

**[ARBEITSTITEL]**

Der Titel ist ausdruecklich als Arbeitstitel zu verstehen und kann sich im
Lauf der Entwicklung noch aendern.

### 1.2 Leitvision

[Ein Satz: Was fuer ein Spiel ist das?]

Kern der Idee:

- [Was macht das Spiel besonders?]
- [Grundton, z. B. humorvoll, duester, entspannt]
- [Wichtigstes Spielelement]

Offene Punkte:

- [...]

### 1.3 Technische Basis

| Bereich | Festlegung |
| --- | --- |
| Engine | Godot **4.8-dev6** (bewusst diese Entwicklungsversion, festgelegt am 01.11.2026; kein Wechsel ohne Absprache). Export-Templates dafuer sind installiert |
| Programmiersprache | GDScript |
| Zielplattformen | Browser (Web-Export, auf itch.io direkt spielbar) und Windows-PC (Download), festgelegt am 01.11.2026 |
| Veroeffentlichung | itch.io, als Beitrag zur Game Off 2026 (siehe 1.11) |
| Eingabegeraete | [Tastatur, Maus, Controller, Touch: was wird unterstuetzt?] |
| Sprachen im Spiel | [z. B. Deutsch und Englisch; Standardsprache] |
| Grafikstil | [z. B. Pixel Art] |
| Perspektive | [z. B. 2D seitlich, Top-Down, 3D] |
| Tile-Groesse | [z. B. 16 x 16 px] |
| Basisaufloesung | [z. B. 480 x 270 px] |
| Skalierung | [Stretch-Modus, ganzzahlig ja/nein] |
| Texturfilter | [z. B. Nearest fuer scharfe Pixel] |
| Renderer | [z. B. Compatibility] |
| Fenstermodus | Entwicklung: [z. B. Fenster 3x]. Fertiges Spiel: [z. B. randloses Vollbild] |
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

**Kenntnisstand des Nutzers:** [z. B. Anfaenger: erste Erfahrungen mit Vibe
Coding, der Sprache und dem Editor]. Daraus folgt:

- [z. B. Erklaerungen in einfacher Sprache, Fachbegriffe beim ersten
  Auftreten kurz erklaeren.]
- [z. B. Code-Kommentare erklaeren, *was* ein Abschnitt tut und *warum*.]
- [z. B. Schritte im Editor (wo klicken, welche Einstellung) konkret
  beschreiben.]

**Antwortform nach einem Schritt:**

- Kurz, was gebaut bzw. geaendert wurde.
- **Neu zu testen:** nur das, was neu ist. Grundbedienung (Editor oeffnen,
  Spiel starten) wird nicht jedes Mal erklaert.
- **Annahmen:** wenn die KI selbst entschieden hat (z. B. im Block-Modus,
  siehe 4.3), jede Annahme einzeln, damit der Nutzer sie pruefen kann.
- Am Ende eine **Kurzinfo zum naechsten Schritt** (Nummer und Titel).

**Ablaeufe rund um jeden Schritt:**

- **Commit:** [z. B. erst, wenn der Nutzer zufrieden ist / automatisch nach
  jedem Schritt]. Commit-Nachricht: [Sprache, Muster, z. B. "Schritt 12:
  Titel"].
- **Editor:** [z. B. Nach jedem Schritt oeffnet die KI den Editor mit dem
  Projekt, falls er nicht laeuft.]
- **Projektdatei:** [z. B. Bevor die KI die Projekteinstellungen
  (`project.godot`) aendert, bittet sie, den Editor zu schliessen, weil der
  Editor die Datei sonst beim Speichern ueberschreibt.]
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
`.gdignore`, damit die Engine sie ignoriert. Unterordner fuer 3D-Modelle
und Sprachen (`dialogues/<sprache>/`) kommen dazu, wenn Stil und Sprachen
feststehen.

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

- **[Englisch]** ist alles, was im Projekt einen Namen bekommt: Ordner,
  Dateien, Szenen, Nodes, Skripte, Klassen, Variablen, Funktionen,
  Konstanten, Signale und Daten-Schluessel (IDs).
- **[Deutsch]** bleiben die Projektdokumentation, Code-Kommentare und
  [die Texte im Spiel in der Ausgangssprache].
- Namen der Figuren im Code: [deutscher Name = `code_name`].

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

- **[Taste, z. B. F1]** oeffnet das Entwickler-Menue (Spiel pausiert).
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
| [z. B. "Song 1"] | [Name, Datei] |
| [z. B. Figur "Held"] | [`hero`] |
| [z. B. "Level 3"] | [`level_03`, frueher "Level 4"] |

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

**Thema:** [wird am 01.11.2026 bekanntgegeben]

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

[Kernschleife in wenigen Schritten, z. B.:]

1. [...]
2. [...]
3. [...]

Wichtige Eigenschaften des Loops:

- [z. B. linear / nicht-linear, Rueckkehr in fruehere Bereiche]

### 2.2 Steuerung

| Aktion | Eingabe-Aktion im Projekt | Tastatur | [Controller] | [Touch] |
| --- | --- | --- | --- | --- |
| [Nach links laufen] | `move_left` | [A, Pfeil links] | [ ] | [ ] |
| [Springen] | `jump` | [Leertaste] | [ ] | [ ] |
| [Benutzen] | `interact` | [E] | [ ] | [ ] |
| [Pause] | `pause` | [Esc] | [ ] | [ ] |

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

### 2.3 [Kernmechanik]

> **Ausfuellhinweis:** Fuer jede Kernmechanik ein eigenes Unterkapitel mit
> diesem Aufbau. Die folgenden Unterkapitel 2.4 bis 2.8 braucht fast jedes
> Spiel; nicht benoetigte streichen.

[Kurzbeschreibung: Was tut der Spieler, was passiert?]

**Regeln:**

- [...]

**Werte:** [Datendatei bzw. einstellbare Werte]

**Zusammenspiel:** [mit welchen anderen Mechaniken, wie zahlt es in den
Loop ein?]

**Umsetzung:** [Szenen, Skripte, Klassen; wird beim Bauen ergaenzt]

Offene Punkte:

- [...]

### 2.4 Menues und Einstieg ins Spiel

- **Titelbildschirm:** [Knoepfe, z. B. Fortfahren, Neuer Spielstand (mit
  Sicherheitsabfrage), Einstellungen, Beenden].
- **Hauptmenue / Levelauswahl:** [...]
- **Pause:** [Taste, was passiert, Fortsetzen ohne Neuladen].
- **Einstellungen:** [Lautstaerke, Vollbild, Sprache, ...].
- **Credits / Abspann:** [...]

### 2.5 Scheitern und Wiederaufnahme

[Tod, Schaden oder Fehlschlag: was loest es aus, was passiert danach
(Game-Over-Bildschirm, Neustart wo), was bleibt erhalten (geloeste Raetsel,
Fortschritt), Kontrollpunkte ja/nein.]

### 2.6 Spielstand und Fortschritt

- **Was wird gespeichert:** [z. B. nur erreichte Zustaende (Marken,
  Levelzustaende, Figuren, Inventar), keine Position].
- **Wo der Spieler nach dem Laden startet:** [...]
- **Anzahl Spielstaende:** [z. B. genau einer].
- **Wann gespeichert wird:** [z. B. Levelende, Rueckkehr ins Menue,
  Beenden, im Browser beim Verlassen des Tabs].
- **Technik:** [z. B. JSON-Datei in `user://`, genau eine Stelle im Code
  speichert und laedt, Versionsnummer im Spielstand, sauberer Rueckfall bei
  fehlender oder beschaedigter Datei].
- **Fortschrittsmarken (Story Flags):** benannte Ja-Nein-Marken fuer jede
  Teilhandlung; Benennung siehe 1.6.

### 2.7 Texte und Dialoge

[Wie Figuren sprechen (Sprechblasen, Dialogfenster, Antwortauswahl ja/nein),
welche Arten es gibt (wichtig / beilaeufig), wie man weiterklickt, ob das
Spiel dabei pausiert, Datenformat der Textdateien (ID -> Text, Varianten,
"nur einmal").]

### 2.8 Leveldesign

[Aufbau und Reihenfolge der Level, Schwierigkeitskurve, wer baut die Level
(KI, Nutzer im Editor mit fertigen Bausteinen), Werkzeuge dafuer.]

| Level | Thema / Hintergrund | Song | Neue Elemente | Besonderheit |
| --- | --- | --- | --- | --- |
| [1] | [ ] | [ID] | [ ] | [ ] |

### 2.9 Zusammenspiel der Mechaniken

[Wie die Mechaniken gemeinsam den Gameplay Loop tragen; Luecken und
Ueberschneidungen.]

---

## Kapitel 3: Story

> **Ausfuellhinweis:** Wird die Handlung lang (viele Szenen, Dialogablaeufe),
> kommt sie in eine eigene Datei (`story.md`), hier bleibt eine Kurzfassung
> mit Verweis.

### 3.1 Setting

[Welt, Zeit, Grundstimmung, Rahmenbedingungen.]

### 3.2 Spielfigur(en)

| Figur | Name im Code | Rolle | Charakter / Ziel | Faehigkeit |
| --- | --- | --- | --- | --- |
| [ ] | [ ] | [ ] | [ ] | [ ] |

### 3.3 Antagonist

[Wer oder was, Motiv, wie er sich zeigt.]

### 3.4 Weitere Figuren und NPCs

[Rolle, Charakter, Bedeutung fuer die Story.]

### 3.5 Story-Bogen

[Grober Verlauf, in Abschnitte gegliedert; je Abschnitt: was passiert, wo
(Level), welche Fortschrittsmarke.]

1. [...]

### 3.6 Ton und Schreibstil

- Grundton der Texte: [z. B. humorvoll, Wortwitz erlaubt].
- Stimme je Figur: [z. B. Figur A muerrisch und knapp, Figur B
  altertuemlich].
- Spoiler: [Was darf in Texten, Store-Seite usw. nicht verraten werden?]
- Uebersetzung: [z. B. frei statt woertlich, Wortwitz und Ton erhalten].

---

## Kapitel 4: Aufgabenliste (Schritt fuer Schritt)

### 4.1 Umfang der ersten spielbaren Version (Vertical Slice)

Enthalten:

- [...]

Bewusst spaeter:

- [...]

### 4.2 Festlegungen vor der Umsetzung

> **Ausfuellhinweis:** Grundsatzentscheidungen, die mehrere Schritte
> betreffen (z. B. Dialogsystem, Tod, Speichern), hier kurz festhalten oder
> auf das Kapitel verweisen, in dem sie stehen.

- [...]

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

- [ ] 1. Projekt anlegen, Projekteinstellungen setzen und die Ordnerstruktur
  aus 1.5 erstellen. (Ordnerstruktur bereits am 01.11.2026 angelegt.)
- [ ] 2. [...]

> **Ausfuellhinweis:** Jeder Eintrag ist ein kleiner, in sich testbarer
> Schritt in sinnvoller Reihenfolge (Grundsysteme vor darauf aufbauenden
> Systemen). Bewaehrte Reihenfolge fuer ein 2D-Spiel: Projekt und Ordner ->
> Testszene mit Boden und Kamera -> Spielfigur -> Bewegung -> Springen ->
> Feinschliff Bewegung (Datendatei) -> Tileset und Testparcours -> Kamera ->
> Texte/Dialoge -> Interaktion -> Inventar -> Szenenwechsel -> Titel und
> Menues -> Fortschrittsmarken -> Speichern und Laden -> Gegner -> Tod ->
> Durchlauf testen. Entwickler-Werkzeuge (1.9) frueh einschieben.

### 4.5 Ausbaustufe: [Name]

- [ ] [n]. [...]

---

## Kapitel 5: Aktueller Stand und Versionsprotokoll

### 5.1 Aktueller Stand

> **Ausfuellhinweis:** Dieser Abschnitt wird bei jedem Schritt
> **ueberschrieben**, nicht ergaenzt. Hoechstens etwa 20 Zeilen, keine
> Historie und keine Technikdetails (die stehen in den Kapiteln 1 bis 3,
> im Versionsprotokoll und in Git).

**Stand vom 01.11.2026, Version v0.3**

- **Phase:** Vorbereitung (Jam startet am 01.11.2026 um 22:37).
- **Zuletzt erledigt:** Repo, Git, GitHub CLI und Jam-Teilnahme eingerichtet;
  Grundlagen in die Doku eingetragen; Ordnerstruktur angelegt.
- **Naechster Schritt:** Thema abwarten, dann Doku gemeinsam ausfuellen
  (Leitvision, Mechaniken, Aufgabenliste); danach Schritt 1.
- **Spielbar:** noch nichts.
- **Noch zu testen (vom Nutzer):** nichts.
- **Bekannte Probleme:** keine.
- **Groesste offene Punkte:** Thema und Spielidee.

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
