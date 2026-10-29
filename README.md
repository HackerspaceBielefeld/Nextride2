# nextride2

Abfahrtsmonitor / Info-Display (Flutter, laeuft per `flutter-pi` auf einem Raspberry Pi).
Zeigt Abfahrten (EFA von Westfalenfahrplan), Kalender, Wetter, Raketenstarts sowie Home-Assistant-Werte
(Displaytext, Bestelltimer, WC-Status, Leistungsaufnahme).

## Setup

Die Konfiguration liegt in `lib/constants.dart` und ist bewusst nicht eingecheckt
(siehe `.gitignore`). Ohne diese Datei laesst sich das Projekt nicht bauen:

Voraussetzung ist ein Dart-SDK >= 3.5 (Flutter >= 3.24).

```bash
cp lib/constants.example.dart lib/constants.dart
$EDITOR lib/constants.dart   # API-Keys, Haltestellen-IDs eintragen
flutter pub get
flutter analyze
```

Abfahrten kommen aus dem EFA `XML_DM_REQUEST` von Westfalenfahrplan
(`efaEndpoint`), die Haltestellen stehen in `requestStations`
(EFA-ID, z.B. `de:05711:5614`). Linienfarben (Hintergrund und Text) werden
beim Start von stadtbahn.live geladen (`lineColorsEndpoint`) und ueber die
globale Linien-ID (`global_id` bzw. EFA `globalId`) zugeordnet; unbekannte
Linien erscheinen navy mit weisser Schrift.

**Umstieg von VRR:** Eine bestehende `lib/constants.dart` muss angepasst
werden, sonst baut das Projekt nicht: `endpoint` wird zu `efaEndpoint`,
`requestStations` ist jetzt `Map<String, String>`, `mobielLineColors`
entfaellt und `lineColorsEndpoint` kommt hinzu (siehe
`lib/constants.example.dart`).

Home-Assistant-Endpunkt, Token und Entity-Namen werden zur Laufzeit aus der
Umgebung gelesen:

```bash
export HASSIO_BASE_URI=http://1.2.3.4:8123
export HASSIO_TOKEN=xxxxxxxxxxxxxxxx
export HASSIO_TIMER_ENTITY=timer.bestelltimer
export HASSIO_TEXT_ENTITY=input_text.displaytext
export HASSIO_WCBUSY_ENTITY=input_boolean.wc_busy
export HASSIO_LEISTUNG_ENTITY=sensor.leistung_total
```

Nicht gesetzte Entities werden uebersprungen (keine Anfrage, keine Anzeige).
Auf dem Pi gehoeren die Zeilen (ohne `export`) nach `/etc/nextride2.env`
(`chmod 600`); `nextride2.service` und `nextride2.sh` laden die Datei.

`withHassio = false` oder eine fehlende Variable schaltet die komplette
Home-Assistant-Anbindung ab (kein UDP-Socket, keine Update-Timer).

## Lokal debuggen (macOS)

```bash
flutter run -d macos
```

In VS Code gibt es dafuer die Launch-Konfiguration `nextride2 (macOS)`.
Die `HASSIO_*`-Variablen werden aus der Umgebung des startenden Prozesses
uebernommen. Lokale Zugangsdaten gehoeren in die (ignorierten) Dateien
`.env.local` fuer das Terminal und `.vscode/settings.json` (`"dart.env"`)
fuer VS Code:

```bash
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
