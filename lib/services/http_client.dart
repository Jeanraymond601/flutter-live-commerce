// lib/services/http_client.dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class CustomHttpClient {
  static final CustomHttpClient _instance = CustomHttpClient._internal();
  factory CustomHttpClient() => _instance;
  CustomHttpClient._internal();

  // GETTER pour les headers communs
  Future<Map<String, String>> get headers async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // HEADERS ESSENTIELS pour ngrok
      'ngrok-skip-browser-warning': 'true',
      'Access-Control-Allow-Origin': '*',
      'Origin': 'http://localhost',
    };

    // Ajoute le token si disponible
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // GET request
  Future<http.Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    final uri = Uri.parse('${Constants.apiBaseUrl}$endpoint').replace(
      queryParameters: queryParams?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );

    print('🌐 GET: $uri');

    final response = await http
        .get(uri, headers: await headers)
        .timeout(const Duration(seconds: 15));

    _logResponse(response);
    return response;
  }

  // POST request
  Future<http.Response> post(String endpoint, dynamic body) async {
    final uri = Uri.parse('${Constants.apiBaseUrl}$endpoint');

    print('🌐 POST: $uri');
    print('📦 Body: ${jsonEncode(body)}');

    final response = await http
        .post(uri, headers: await headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));

    _logResponse(response);
    return response;
  }

  // PUT request
  Future<http.Response> put(String endpoint, dynamic body) async {
    final uri = Uri.parse('${Constants.apiBaseUrl}$endpoint');

    final response = await http
        .put(uri, headers: await headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));

    _logResponse(response);
    return response;
  }

  // DELETE request
  Future<http.Response> delete(String endpoint) async {
    final uri = Uri.parse('${Constants.apiBaseUrl}$endpoint');

    final response = await http
        .delete(uri, headers: await headers)
        .timeout(const Duration(seconds: 15));

    _logResponse(response);
    return response;
  }

  void _logResponse(http.Response response) {
    print('📡 Status: ${response.statusCode}');
    print('📄 Headers: ${response.headers}');

    // Vérifie si c'est du HTML
    if (response.body.trim().startsWith('<!DOCTYPE') ||
        response.body.trim().startsWith('<html')) {
      print('❌ Ngrok bloque cette requête !');
      print('📄 Extrait: ${response.body.substring(0, 200)}');
    } else {
      print('✅ Réponse JSON reçue');
      print('📊 Taille: ${response.body.length} caractères');
    }
  }

  // Vérifie si la réponse est du HTML
  bool isHtmlResponse(String body) {
    return body.trim().startsWith('<!DOCTYPE') ||
        body.trim().startsWith('<html');
  }
}
