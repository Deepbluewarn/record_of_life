# T1: Data bridge format & transport

Label: `wayfinder:grilling`
Status: open, unblocked, unclaimed
Blocks: T2

## Question

모바일 앱의 촬영 메모가 데스크탑 앱까지 어떤 **포맷**으로 **어떤 경로**를 통해 전달되는가?

- 후보 포맷: JSON (단일 파일) / JSON + assets zip / SQLite dump / exiftool `-json` argfile 직결.
- 후보 전송: 사용자 수동 파일 이동 (AirDrop/이메일/클라우드 드라이브) / 로컬 네트워크 페어링 / 클라우드 동기화.
- Roll 단위 export인지 전체 export인지도 정할 것.
- 스키마 필드는 현 `Roll`/`Shot` 모델 기반 — 확장 여지 남길지, 버전 필드 넣을지.

## Resolution

**Transport:** v0에서는 **수동 파일 이동**. 사용자가 모바일 앱에서 export → 파일을 데스크탑으로 옮김 (AirDrop/클라우드 드라이브/USB/이메일 무관). v1에서 사용성 검증 후 WebRTC 페어링(P2P + signaling server)으로 업그레이드 가능성 열어둠. 스키마가 안정적이면 transport는 나중에 덧대기 쉬움.

**Format:** 단일 JSON 파일, 확장자 `.rol.json`. 사람이 읽을 수 있고, 데스크탑에서 파싱 간단. exiftool argfile 직결은 안 함 — argfile은 데스크탑 파이프라인 **끝**에서 매칭 확정 후 생성.

**Scope:** **Roll 단위 export**. 파일 하나 = 롤 하나. 사용자 정신 모델과 일치("이 롤 스캔했으니 이 파일 열자"), 데스크탑에서 롤 선택 UI 불필요.

**스키마 v1 스케치:**

```json
{
  "schema": 1,
  "exportedAt": "2026-08-02T14:30:00+09:00",
  "artist": "Jane Doe",
  "roll": {
    "id": "...",
    "name": "...",
    "film": { "name": "Portra 400", "iso": 400 },
    "camera": { "make": "Nikon", "model": "FM2", "title": "Nikon FM2" },
    "lenses": [
      { "id": "l1", "make": "Nikon", "model": "Nikkor 50mm f/1.4 AI-S" }
    ],
    "shots": [
      {
        "idx": 1,
        "aperture": 2.8,
        "shutterSpeed": "1/125",
        "iso": 400,
        "focalLength": 50,
        "exposureComp": 0,
        "pushPull": 0,
        "lensId": "l1",
        "flash": false,
        "date": "2026-07-15T14:00:00+09:00",
        "rating": 4,
        "note": "..."
      }
    ]
  }
}
```

**메모:**
- `artist`는 AppSettings에 있으므로 export 시점에 baked-in. 롤/shot에는 저장 안 함.
- Lens는 렌즈 카탈로그를 함께 export (shot이 lensId만 참조하므로 데스크탑에서 조회 가능해야 함).
- 필드 rename/추가 시 `schema` 버전 올리고 데스크탑에서 마이그레이션.
- v1 스키마는 T5 태그 매핑과 1:1 대응. 추가 EXIF 필드 필요해지면 스키마도 같이 확장.
