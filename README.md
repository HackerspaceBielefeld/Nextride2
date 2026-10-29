# nextride2

Abfahrtsmonitor / Info-Display (Flutter, laeuft per `flutter-pi` auf einem Raspberry Pi).
Zeigt Abfahrten (EFA von Westfalenfahrplan), Kalender, Wetter, Raketenstarts sowie Home-Assistant-Werte
(Displaytext, Bestelltimer, WC-Status, Leistungsaufnahme).

## Setup

Voraussetzung ist ein Dart-SDK >= 3.5 (Flutter >= 3.24).

```bash
flutter pub get
flutter analyze
```

## Konfiguration

Konfiguration und Zugangsdaten stehen nicht im Code, sondern werden zur
Laufzeit aus Umgebungsvariablen gelesen (`lib/config.dart`). Vorlage mit allen
Variablen: `nextride2.env.example`.

| Variable | Bedeutung |
|---|---|
| `DEPARTURE_SOURCE` | `efa` (Standard), `vrr` oder `stadtbahnlive` |
| `DEPARTURE_STATIONS` | Haltestellen `id=Name;id=Name`, ohne keine Abfahrten |
| `OPENWEATHER_API_KEY`, `WEATHER_CITY` | Wetter, ohne Key nur ein Hinweis |
| `HASSIO_BASE_URI`, `HASSIO_TOKEN` | Home Assistant, ohne ist die Anbindung aus (kein UDP-Socket, keine Timer) |
| `HASSIO_TIMER_ENTITY`, `HASSIO_TEXT_ENTITY`, `HASSIO_WCBUSY_ENTITY`, `HASSIO_LEISTUNG_ENTITY` | Entities, leere werden uebersprungen |
| `DEPARTURE_ENDPOINT`, `LINE_COLORS_ENDPOINT`, `ROCKET_LAUNCH_ENDPOINT` | optional, oeffentliche Standard-Endpunkte ueberschreiben |

Auf dem Pi gehoert die Datei nach `/etc/nextride2.env` (`chmod 600`);
`nextride2.service` und `nextride2.sh` laden sie.

### Abfahrtsquellen

| Quelle | Haltestellen-ID | Hinweis |
|---|---|---|
| `efa` (Standard) | DHID (`de:05711:5614`) | EFA `XML_DM_REQUEST` von Westfalenfahrplan |
| `vrr` | VRR-ID (`23005614`) | VRR-Haltestellenmonitor |
| `stadtbahnlive` | DHID | experimentell: Anzeigetafeln von stadtbahn.live, nur Haltestellen mit Tafel, Ziele fehlen oft |

Weitere Quellen implementieren `DepartureSource` (`lib/service/departure_source.dart`).

Linienfarben (Hintergrund und Text) werden beim Start von stadtbahn.live
geladen und je nach Quelle ueber die globale Linien-ID (EFA), den
EFA-Liniencode (VRR) oder die stadtbahn.live-Linie zugeordnet; unbekannte
Linien erscheinen navy mit weisser Schrift.

**Umstieg:** `lib/constants.dart` gibt es nicht mehr. Die Werte daraus gehoeren
in `/etc/nextride2.env` (Haltestellen, Wetter-Key und -Stadt).

## Lokal debuggen (macOS)

```bash
flutter run -d macos
```

In VS Code gibt es dafuer die Launch-Konfiguration `nextride2 (macOS)`.
Die Konfiguration wird aus der Umgebung des startenden Prozesses
uebernommen. Lokal gehoert sie in die (ignorierten) Dateien
`.env.local` fuer das Terminal und `.vscode/settings.json` (`"dart.env"`)
fuer VS Code:

```bash
cp nextride2.env.example .env.local   # einmalig, dann ausfuellen
set -a; . ./.env.local; set +a
flutter run -d macos
```

Die App laeuft in der macOS-Sandbox; ausgehende Verbindungen und die
UDP-Ports sind ueber `com.apple.security.network.client`/`.server` in
`macos/Runner/*.entitlements` freigegeben.

## Build & Deploy

```bash
flutter build bundle
rsync -a build/flutter_assets/ pi@display:/opt/nextride/flutter_assets/
```

Auf dem Pi wird die App entweder ueber `nextride2.service` (systemd) oder
ueber `nextride2.sh` (SysV-Init + screen) gestartet.

## Push per UDP

* Port **31337**: Bild-Overlay. Payload: `[0] = Anzeigedauer in Sekunden`,
  `[1] = Laenge der URL`, danach die URL als ASCII (nur http/https).
* Port **31338**: beliebiges Paket triggert ein sofortiges Hassio-Update.
