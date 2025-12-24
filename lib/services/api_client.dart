import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // Base URL
  static String get _baseUrl {
    final url = dotenv.env["API_BASE_URL"];
    if (url == null || url.isEmpty) {
      throw Exception("API_BASE_URL not set");
    }
    return url;
  }

  // Read token
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  // Build headers
  static Future<Map<String, String>> _headers() async {
    final token = await _getToken();

    final headers = {"Content-Type": "application/json"};

    if (token != null) {
      headers["Authorization"] = "Bearer $token";
    }

    return headers;
  }

  // GET
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final url = Uri.parse("$_baseUrl/$endpoint");

    try {
      final response = await http.get(url, headers: await _headers());
      return _handleResponse(response);
    } on SocketException {
      throw Exception("No internet connection");
    }
  }

  // POST  ✅ (added)
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse("$_baseUrl/$endpoint");

    try {
      final response = await http.post(
        url,
        headers: await _headers(),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } on SocketException {
      throw Exception("No internet connection");
    }
  }

  // PUT
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse("$_baseUrl/$endpoint");

    try {
      final response = await http.put(
        url,
        headers: await _headers(),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } on SocketException {
      throw Exception("No internet connection");
    }
  }

  // DELETE  ✅ (added)
  static Future<Map<String, dynamic>> delete(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse("$_baseUrl/$endpoint");

    try {
      final response = await http.delete(
        url,
        headers: await _headers(),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } on SocketException {
      throw Exception("No internet connection");
    }
  }

  // Central response handling
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.body.isEmpty) {
      throw Exception("Empty response from server");
    }

    final data = jsonDecode(response.body);

    if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    }

    if (response.statusCode >= 400) {
      final message = data["message"] ?? "Request failed";
      throw Exception(message);
    }
    
    return data;
  }
}
