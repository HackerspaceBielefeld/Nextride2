String buildInfo = "Nextride v2.0.0";

// EFA von Westfalenfahrplan (NWL), liefert die Abfahrten.
String efaEndpoint = "https://www.westfalenfahrplan.de/nwl-efa";

// Linienfarben (Hintergrund + Text), werden beim Start geladen.
String lineColorsEndpoint = 'https://stadtbahn.live/api/v1/lines';

// EFA-Haltestellen-ID (DHID oder numerisch) -> Bezeichnung.
Map<String, String> requestStations = {
  //'de:05711:5500': 'Bielefeld Hbf',
  //'de:05711:5001': 'Adenauerplatz',
  'de:05711:5614': 'Ziegelstraße',
};

String openWeatherAPIKey = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
String weatherCityName = 'Bielefeld';

// Home-Assistant-Anbindung komplett deaktivieren (wird in main.dart geprueft).
bool withHassio = true;

// Endpunkt, Token und Entity-Namen kommen zur Laufzeit aus der Umgebung,
// siehe README.md. Fehlt HASSIO_BASE_URI oder HASSIO_TOKEN, bleibt die
// Anbindung deaktiviert; nicht gesetzte Entities werden uebersprungen.

String rocketLaunchEndpoint = 'https://fdo.rocketlaunch.live/json/launches/next/5';
