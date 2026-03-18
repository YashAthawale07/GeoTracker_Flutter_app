import '../core/constants.dart';
import '../models/geofence.dart';
import 'api_helper.dart';

class GeofenceService {
  static const String _endpoint = '/admin/geofence';

  /// Fetch current geofence configuration. Returns null if not set or on 404.
  static Future<Geofence?> getGeofence() async {
    try {
      final response = await ApiHelper.get('${Constants.baseUrl}$_endpoint');
      if (response == null) return null;
      return Geofence.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      // If backend returns 404 or any error, treat as "not configured" for now.
      return null;
    }
  }

  /// Save / update geofence configuration.
  static Future<bool> setGeofence({
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    final body = {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
    };

    try {
      final response =
          await ApiHelper.post('${Constants.baseUrl}$_endpoint', body);

      if (response is Map<String, dynamic>) {
        // If backend returns a JSON with success/message flags, respect them if present.
        if (response['success'] is bool) {
          return response['success'] as bool;
        }
      }

      // For now, assume success if request didn't throw.
      return true;
    } catch (e) {
      return false;
    }
  }
}

