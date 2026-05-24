import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:moonchat/models/crypto_model.dart';
import 'package:moonchat/utils/constants.dart';

class CryptoService {
  static String get baseUrl => '${AppConstants.baseUrl}/api/crypto';

  // In-memory cache for crypto prices
  static List<CryptoModel>? _cachedTopCryptos;
  static DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 5);

  List<CryptoModel>? getCachedCryptos() {
    return _cachedTopCryptos;
  }

  Future<List<CryptoModel>> getTopCryptos({bool forceRefresh = false}) async {
    // Return cached data if available and fresh, unless forced
    if (!forceRefresh && _cachedTopCryptos != null && _lastFetchTime != null && 
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
      debugPrint('Error fetching cryptos: $e');
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
      debugPrint('Error searching cryptos: $e');
      return [];
    }
  }
}
