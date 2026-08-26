# T5: EXIF injection tool & tag mapping

Label: `wayfinder:research`
Status: open, unblocked, unclaimed
Blocks: T6

## Question

어떤 도구로 EXIF를 주입하며, 우리 모델의 각 필드가 어떤 EXIF 태그로 매핑되나?

- **exiftool** 이 사실상 표준. CLI wrapping이 안전한 선택. 단, 각 필드별 정확한 태그 이름/네임스페이스 확정 필요:
  - Aperture → FNumber
  - ShutterSpeed → ExposureTime (fractional 문자열 처리)
  - ISO → ISO (또는 ISOSpeedRatings)
  - FocalLength → FocalLength (mm)
  - Camera → Make + Model
  - Lens → LensModel (+ LensMake?)
  - Film → ??? (표준 태그 없음 — UserComment? XMP custom?)
  - Push/Pull → ??? (표준 없음 — UserComment or XMP)
  - Flash → Flash (Exif 정수 인코딩 확인 필요)
  - Artist → Artist
  - Date → DateTimeOriginal
  - Rating → Rating (XMP)
  - Note → ImageDescription or UserComment
- 파일 포맷별 지원 태그 차이 (JPEG vs TIFF vs DNG vs 스캐너 raw)

`/research` 서브에이전트에게 exiftool로 위 모든 필드 주입 시 정확한 태그 문법 조사 위임.

## Resolution

Tool: **exiftool** (Phil Harvey), CLI-wrapped from the desktop app. All tags below are exiftool's own tag names; namespace prefixes (`EXIF:`, `XMP:`, `XMP-dc:`, `XMP-xmp:`) are only needed to disambiguate.

### Tag mapping

| Field | Tag(s) | CLI syntax | Notes |
|---|---|---|---|
| Aperture (f-number) | `FNumber` | `-FNumber=2.8` | Accepts decimal. exiftool derives `ApertureValue` (APEX) automatically. |
| Shutter speed | `ExposureTime` | `-ExposureTime=1/125` or `-ExposureTime=2` | Accepts fraction string or seconds. exiftool derives `ShutterSpeedValue`. |
| ISO | `ISO` | `-ISO=400` | Writes EXIF tag 0x8827. exiftool also fills `ISOSpeedRatings` alias on older EXIF versions. Prefer `-ISO=`. |
| Focal length | `FocalLength` | `-FocalLength=50` | Millimeters. exiftool writes `"50 mm"` display form; store as bare number. |
| Camera make | `Make` | `-Make="Nikon"` | |
| Camera model | `Model` | `-Model="FM2"` | |
| Lens model | `LensModel` (EXIF 0xA434) + `XMP-aux:Lens` | `-LensModel="Nikkor 50mm f/1.4 AI-S" -XMP-aux:Lens="Nikkor 50mm f/1.4 AI-S"` | Write both; Lightroom/Bridge read XMP-aux. |
| Lens make | `LensMake` | `-LensMake="Nikon"` | EXIF 0xA433. |
| Film stock | *no standard tag* | `-XMP-crs:Film="Portra 400"` OR `-UserComment="Film: Portra 400; ..."` | Recommend a custom XMP namespace (e.g. `-XMP-rol:FilmStock=`) declared via a `.ExifTool_config`. Fallback: pack into `UserComment`. |
| Push/Pull | *no standard tag* | `-XMP-rol:PushPull=+1` | Same custom-XMP approach. Value in stops, signed integer or half-stop float. Do NOT overload `ISO` with the pushed value; keep box-speed ISO in `ISO` and push separately. |
| Flash fired | `Flash` | `-Flash=1` (fired) / `-Flash=0` (no flash) | Bitfield; `0x0`=no flash, `0x1`=fired. `0x20` = "no flash function" (no camera flash unit exists). For film SLR + external flash, `1`/`0` is correct. |
| Artist | `Artist` + `XMP-dc:Creator` | `-Artist="Jane Doe" -XMP-dc:Creator="Jane Doe"` | Copyright-block tag. |
| Date taken | `DateTimeOriginal` | `-DateTimeOriginal="2026:08:02 14:30:00"` | Format: `YYYY:MM:DD HH:MM:SS` (colons, not dashes, in date part). Also write `CreateDate` and `ModifyDate` for maximum compatibility. |
| Star rating | `XMP:Rating` | `-Rating=4` | Range **0–5** integer (Adobe XMP `xmp:Rating`). `-1` = rejected. |
| Note (free text) | `ImageDescription` + `XMP-dc:Description` | `-ImageDescription="..." -XMP-dc:Description="..."` | `UserComment` also valid but has a charset prefix quirk; exiftool handles it, but `ImageDescription` is simpler for plain text. |

### Format caveats

- **JPEG, TIFF, DNG**: exiftool writes EXIF, XMP, and IPTC to all three natively and equivalently. DNG is a TIFF variant — same tag support.
- **Custom XMP namespaces** (film stock, push/pull): stick fine in JPEG/TIFF/DNG XMP packets. For raw scanner formats not in exiftool's writable list, wrap in a sidecar `.xmp` instead.
- **UserComment** requires a character-code prefix in EXIF spec; exiftool prepends `ASCII\0\0\0` automatically — don't hand-craft it.
- Some tags exist in both EXIF and XMP (e.g. `Rating` is XMP-only; `FNumber` is EXIF-only). Writing without a namespace lets exiftool pick; be explicit if you need one specifically.

### Example (single invocation, PowerShell quoting)

```powershell
exiftool `
  -FNumber=2.8 -ExposureTime=1/125 -ISO=400 -FocalLength=50 `
  -Make="Nikon" -Model="FM2" `
  -LensModel="Nikkor 50mm f/1.4 AI-S" -LensMake="Nikon" `
  -Flash=1 `
  -Artist="Jane Doe" -XMP-dc:Creator="Jane Doe" `
  -DateTimeOriginal="2026:08:02 14:30:00" -CreateDate="2026:08:02 14:30:00" `
  -Rating=4 `
  -ImageDescription="Roll 12, frame 7. Overcast, metered for shadows." `
  -XMP-rol:FilmStock="Kodak Portra 400" -XMP-rol:PushPull=+1 `
  -overwrite_original_in_place `
  "C:\scans\roll12_frame07.tif"
```

On Windows CMD use `^` line continuation and double-quote values with spaces. Bash: single-quote or escape.

### Backup behavior

Default exiftool renames the source to `<file>_original` before writing. For a desktop injector operating on scans the user has already committed to keeping, that clutter is unwanted. Use **`-overwrite_original_in_place`** — it:

- writes no `_original` backup file,
- writes to a temp then copies bytes back into the original inode, preserving hard links, Finder tags/ADS, permissions, and (on Windows) the file's creation timestamp,
- is slightly slower than `-overwrite_original` (which also skips the backup but replaces the inode via rename).

Recommend `-overwrite_original_in_place` as the default flag. Provide a "keep backup" toggle in the UI that omits the flag (falling back to exiftool's default `_original` behavior) for users who want a safety net.

### Uncertain / worth verifying at implementation time

- Exact behavior of `-ISO=` vs `-ISOSpeedRatings=` on EXIF v2.3+ files (exiftool usually handles the alias, but confirm with `exiftool -G1 -a -s` on a written test file).
- Whether the desktop scanner output is real DNG or a TIFF-with-DNG-extension — affects whether MakerNotes preservation matters (for our use case: not injecting MakerNotes, so moot).
- Custom XMP namespace (`XMP-rol:*`) requires shipping a `.ExifTool_config` file alongside the binary; validate the path lookup on Windows.

