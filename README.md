# nextride2

Abfahrtsmonitor / Info-Display (Flutter, laeuft per `flutter-pi` auf einem Raspberry Pi).
Zeigt VRR-Abfahrten, Kalender, Wetter, Raketenstarts sowie Home-Assistant-Werte
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
