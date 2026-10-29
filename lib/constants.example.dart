import 'package:nextride2/service/departure_source.dart';

String buildInfo = "Nextride v2.0.0";

// Woher die Abfahrten kommen: efa, vrr oder stadtbahnLive (experimentell),
// siehe DepartureSourceType.
DepartureSourceType departureSource = DepartureSourceType.efa;

// EFA von Westfalenfahrplan (NWL).
String efaEndpoint = "https://www.westfalenfahrplan.de/nwl-efa";

// VRR-Haltestellenmonitor.
String vrrEndpoint = "https://haltestellenmonitor.vrr.de";

// stadtbahn.live, Anzeigetafeln an einigen Stadtbahn-Haltestellen.
String stadtbahnLiveEndpoint = "https://stadtbahn.live";

// Linienfarben (Hintergrund + Text), werden beim Start geladen.
String lineColorsEndpoint = 'https://stadtbahn.live/api/v1/lines';

// Haltestellen fuer efa und stadtbahnLive: DHID -> Bezeichnung.
// stadtbahnLive kennt nur Haltestellen mit Anzeigetafel (z.B. de:05711:5666 Universitaet).
Map<String, String> requestStations = {
  //'de:05711:5500': 'Bielefeld Hbf',
  //'de:05711:5001': 'Adenauerplatz',
  'de:05711:5614': 'Ziegelstraße',
};

// Haltestellen fuer vrr: VRR-ID -> Name (geht mit in die Anfrage).
Map<String, String> vrrStations = {
  '23005614': 'Bielefeld+Ziegelstraße',
};

String openWeatherAPIKey = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
String weatherCityName = 'Bielefeld';

// Home-Assistant-Anbindung komplett deaktivieren (wird in main.dart geprueft).
bool withHassio = true;

// Endpunkt, Token und Entity-Namen kommen zur Laufzeit aus der Umgebung,
// siehe README.md. Fehlt HASSIO_BASE_URI oder HASSIO_TOKEN, bleibt die
// Anbindung deaktiviert; nicht gesetzte Entities werden uebersprungen.

String rocketLaunchEndpoint = 'https://fdo.rocketlaunch.live/json/launches/next/5';
