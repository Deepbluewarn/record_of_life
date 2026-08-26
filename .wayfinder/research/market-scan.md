# Market scan: film-log → EXIF-injector desktop companion

Date: 2026-08-02. Scope: is a desktop matcher/injector for `record_of_life` a real gap or duplication?

## Section A — Mobile film-log apps and their exports

| App | Maintained | Export formats | Feeds exiftool directly? | Notes |
|---|---|---|---|---|
| Crown + Flint (iOS) | Yes (2024 update) | CSV, PDF contact sheet, **exiftool argfile** | **Yes** — dedicated exiftool export | JSON deprecated in favor of CSV + exiftool. [petapixel](https://petapixel.com/2024/02/01/crown-flint-analog-photography-app-gets-film-storage-update/) |
| Lightme Logbook (iOS) | Yes (2024+) | JSON, CSV | Not directly — but ships **Mac companion** ("Lightme Logbook JSON Importer") that embeds into TIFFs | [App Store](https://apps.apple.com/us/app/lightme-logbook/id1544518308), [importer thread](https://www.digitalmonochromeforum.co.uk/threads/lightme-logbook-json-importer.7847/) |
| Frames (withframes.com, iOS+Mac) | Yes (launched 2025, active 2026) | CSV, TXT, GPX, PDF, **XMP sidecar**, `.frames` | **Yes** — Mac app writes EXIF/XMP into JPEG/TIFF/DNG/JXL directly | Closest competitor to what user is proposing. [35mmc 2026](https://www.35mmc.com/21/05/2026/frames-one-year-later-building-a-film-photography-logbook-app-full-time/), [withframes.com](https://withframes.com/) |
| Pellica (iOS+Android) | Yes | CSV, JSON, PDF contact sheet, JPEG bundle | Not directly; user script needed | [pellica.app](https://pellica.app/film-roll-tracker/) |
| MetaLog (iOS) | Yes | CSV | Manual transform | [DPReview](https://www.dpreview.com/news/3883002316/metalog-ios-app-makes-it-easy-to-record-metadata-for-your-film-photography) |
| Film Logbook (iOS) | Yes | JSON (incl. image IDs) | Manual | [App Store](https://apps.apple.com/us/app/film-logbook-analog-tracker/id1520402017) |
| Analog Book (iOS) | **Unverified** — no search hits under that exact name; likely re-brand or misremembered | — | — | Possibly conflated with "Film Logbook" or "Analog Journal" |
| Reveni Labs Log (iOS) | **Unverified** — no search hits for logbook product | — | — | Reveni is known for light meters; a "Log" app didn't surface |
| Filmomat | Not a log app — it's SmartConvert (desktop scan conversion) | n/a | n/a | Misclassified in the brief. [filmomat.eu](https://www.filmomat.eu/smartconvert) |
| Filmtrack (Android) | **Unverified under that name**; closest is FilmTracker (iOS+Android+Desktop+Lightroom plugin) | Desktop + LR plugin sync | **Yes** — dedicated ecosystem | [filmtracker.app](https://filmtracker.app/) |
| Exif Notes (Android, FOSS) | Yes | CSV/XML; companion `scan-tagger` script exists | Via [scan-tagger](https://pypi.org/project/scan-tagger/) | [35mmc](https://www.35mmc.com/21/05/2020/bridging-analog-photography-and-digital-metadata-with-exif-notes-by-babak-farshchian/) |
| Exif4Film (Android) | Older | Applies to scanned images on-device | Partial | [alt.to](https://alternativeto.net/software/exif4film) |

## Section B — Does a dedicated desktop matcher/injector already exist?

**Yes — at least three, one of them a direct match for the proposed UX.**

1. **Frames for Mac** — drag scans in, pair to logged frames, writes EXIF/XMP straight into JPEG/TIFF/DNG/JXL. macOS only. $1.99/mo, $59.99 lifetime. This is functionally the exact app the user is proposing. [withframes.com](https://withframes.com/)
2. **Lightme Logbook JSON Importer** (Mac) — batch-embeds JSON log data into a folder of scans. Less polished UX (no visual match view confirmed) but same purpose. [thread](https://www.digitalmonochromeforum.co.uk/threads/lightme-logbook-json-importer.7847/)
3. **FilmTracker Desktop + Lightroom plugin** — cross-platform ecosystem, mobile logger + desktop importer + LR sync. [filmtracker.app](https://filmtracker.app/)
4. **AnalogExif** (Win/Mac/Linux, open source) — general-purpose scanned-negative metadata editor with equipment library, batch copy from previous frame. No mobile-log pairing. [sourceforge](https://analogexif.sourceforge.net/help/main-features.php)
5. **CLI/scripts**: `filmtagger` ([PyPI](https://pypi.org/project/filmtagger)), `scan-tagger` ([PyPI](https://pypi.org/project/scan-tagger/)), `filmrolls-rs` ([GitHub](https://github.com/urdh/filmrolls-rs)), `logbook-json-exif-merge` ([GitLab](https://gitlab.com/bastiman1/logbook-json-exif-merge)).

## Section C — Dominant current workflow and its pain points

**Workflow spectrum:**
- Frames / FilmTracker users: log on phone → drop scans in desktop companion → pair → export. Painless when you stay in-ecosystem.
- Lightme / Exif Notes users: log on phone → export JSON → run companion importer or `scan-tagger` script → done.
- Crown + Flint users: export exiftool argfile → run `exiftool -@ argfile scans/*.jpg` manually. [petapixel](https://petapixel.com/2024/02/01/crown-flint-analog-photography-app-gets-film-storage-update/)
- Everyone else (majority per r/AnalogCommunity anecdote): notebook or Google Doc → hand-type into Lightroom metadata preset per frame, or `exiftool -Model= -FNumber= …` per file. [phoblographer on Luce](https://www.thephoblographer.com/2020/03/09/luce-an-app-that-could-help-analog-photographers-log-exif-data/), [hedleywright workflow](https://hedleywrightphotography.com/frames-using-exif-data-with-film-scans-in-lightroom), [exiftool forum](https://exiftool.org/forum/index.php?topic=15424.0)

**Pain points that recur:**
- Manual entry is tedious; users abandon logging mid-roll.
- Frame-to-scan alignment is fragile: scans are often out of order, some frames blank, some double-exposed, so a naive positional zip fails.
- Non-standard EXIF fields (film stock, developer) require XMP schema decisions; some apps' CSV column names don't map to real EXIF tags. [exiftool forum](https://exiftool.org/forum/index.php?topic=15424.0)
- Windows users are underserved — Frames and Lightme companions are Mac-only.
- Lightroom plugins for this exist but users report brittleness.

## Section D — Recommendation (blunt)

**Building a general Mac/iOS desktop matcher/injector is duplication.** Frames already ships exactly the described product (drag scans, pair to logged frames, write EXIF/XMP into JPEG/TIFF/DNG/JXL) with active development and a lifetime price under $60. Lightme + Frames + FilmTracker cover the pipeline for the mainstream Mac/iOS user.

**Real gaps that would justify building:**
1. **Windows desktop.** Frames and Lightme companions are Mac-only. AnalogExif exists on Windows but doesn't pair to a mobile log. If `record_of_life`'s users are Windows-heavy, this is a real hole.
2. **Robust visual matcher UI for messy rolls** (blanks, misfires, reordered scans). Most companions assume 1:1 positional pairing. A grid that lets a user drag-reorder or skip is a genuine differentiator — confirmed pain point in the community.
3. **Deep integration with `record_of_life`'s own export format** (WheelSelector-driven ISO/aperture/shutter, artist, star rating). No third-party importer will know those columns; a first-party desktop is the only way to make the round-trip clean.

**Verdict:** don't build a generic desktop. If you build one, its reason for existing is (a) Windows support, (b) visual match UI for imperfect rolls, and (c) first-party fidelity to your own schema (star rating, artist, note). Otherwise ship a clean exiftool argfile export from the mobile app — that's one function and it puts you at parity with Crown + Flint for a fraction of the effort. Argfile export first, decide on desktop after users complain.

---

Unverified in this scan: Analog Book, Reveni Labs Log, Filmtrack — no matches under those exact names. Filmomat is a scan-conversion tool, not a log app.
