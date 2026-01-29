import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiHelper {
  // POST request
  static Future<dynamic> post(String url, Map body) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  // GET request
  static Future<dynamic> get(String url) async {
    final response = await http.get(Uri.parse(url));
    return _processResponse(response);
  }

  // PUT request
  static Future<dynamic> put(String url, {Map? body}) async {
    final response = await http.put(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: body != null ? jsonEncode(body) : null,
    );
    return _processResponse(response);
  }

  // DELETE request
  static Future<dynamic> delete(String url) async {
    final response = await http.delete(Uri.parse(url));
    return _processResponse(response);
  }

  // Decode JSON or throw error
  static dynamic _processResponse(http.Response response) {
    // Convert 200-299 as success
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body); // will be List or Map
      } catch (e) {
        return response.body; // plain string if not JSON
      }
    } else {
      // throw exception if not success
      throw Exception(
          "Request failed with status: ${response.statusCode}, body: ${response.body}");
    }
  }
}
