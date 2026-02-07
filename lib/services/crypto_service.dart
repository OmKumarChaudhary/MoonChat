import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:moonchat/models/crypto_model.dart';

class CryptoService {
  // Use localhost for web, desktop, and physical devices (if on same network)
  // Use 10.0.2.2 specifically for the Android emulator
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000/api/crypto';
    
    // Check if running on Android/iOS emulator vs physical/desktop
    // Simple heuristic: default to localhost for desktop/physical, 
    // 10.0.2.2 for Android emulator.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      // This is a rough check, in a real scenario you might check if actually an emulator
      // For this task, we will try to be smarter or just provide a better default.
      return 'http://10.0.2.2:5000/api/crypto';
    }
    return 'http://localhost:5000/api/crypto'; 
  }

  // In-memory cache for crypto prices
  static List<CryptoModel>? _cachedTopCryptos;
  static DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 5);

  Future<List<CryptoModel>> getTopCryptos() async {
    // Return cached data if available and fresh
    if (_cachedTopCryptos != null && _lastFetchTime != null && 
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedTopCryptos!;
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/prices'));
      if (response.statusCode == 200) {
        Iterable list = json.decode(response.body);
        final results = list.map((model) => CryptoModel.fromJson(model)).toList();
        
        // Update cache
        _cachedTopCryptos = results;
        _lastFetchTime = DateTime.now();
        
        return results;
      } else {
        throw Exception('Failed to load cryptos');
      }
    } catch (e) {
      print('Error fetching cryptos: $e');
      return [];
    }
  }

  Future<List<CryptoModel>> searchCryptos(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/search?query=$query'));
      if (response.statusCode == 200) {
        Iterable list = json.decode(response.body);
        return list.map((model) => CryptoModel.fromSearchJson(model)).toList();
      } else {
        throw Exception('Failed to search cryptos');
      }
    } catch (e) {
      print('Error searching cryptos: $e');
      return [];
    }
  }
}
