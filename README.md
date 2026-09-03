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
$EDITOR lib/constants.dart   # API-Keys, Haltestellen-IDs, Hassio-Token eintragen
flutter pub get
flutter analyze
```

`withHassio = false` schaltet die komplette Home-Assistant-Anbindung ab
(kein UDP-Socket, keine Update-Timer).

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
