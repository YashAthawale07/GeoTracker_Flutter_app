import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiHelper {
  static Future<dynamic> post(String url, Map body) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    // Try to decode JSON, if fails return plain string
    try {
      return jsonDecode(response.body);
    } catch (e) {
      return response.body; // plain string
    }
  }

  static Future<dynamic> get(String url) async {
    final response = await http.get(Uri.parse(url));

    try {
      return jsonDecode(response.body);
    } catch (e) {
      return response.body; // plain string
    }
  }
}
