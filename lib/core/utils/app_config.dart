import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get mapboxToken =>
      dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';

  static String get mapboxTileUrl =>
      'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/{z}/{x}/{y}?access_token=$mapboxToken';
}
