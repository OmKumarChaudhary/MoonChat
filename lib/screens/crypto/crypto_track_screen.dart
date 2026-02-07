import 'package:flutter/material.dart';
import 'package:moonchat/models/crypto_model.dart';
import 'package:moonchat/services/crypto_service.dart';
import 'package:intl/intl.dart';

class CryptoTrackScreen extends StatefulWidget {
  const CryptoTrackScreen({Key? key}) : super(key: key);

  @override
  State<CryptoTrackScreen> createState() => _CryptoTrackScreenState();
}

class _CryptoTrackScreenState extends State<CryptoTrackScreen> {
  final CryptoService _cryptoService = CryptoService();
  final TextEditingController _searchController = TextEditingController();
  List<CryptoModel> _cryptos = [];
  List<CryptoModel> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchCryptos();
  }

  Future<void> _fetchCryptos() async {
    setState(() {
      _isLoading = true;
    });
    final cryptos = await _cryptoService.getTopCryptos();
    setState(() {
      _cryptos = cryptos;
      _isLoading = false;
    });
  }

  void _onSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final results = await _cryptoService.searchCryptos(query);
    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Crypto Track',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Mulish',
            ),
          ),
          const SizedBox(height: 20),

          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF222232),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                hintText: 'Search Cryptos',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Content
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _searchController.text.isNotEmpty 
                    ? _buildSearchResults()
                    : _buildCryptoList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching && _searchResults.isEmpty) {
      // Small delay for search results to appear
      return const Center(child: CircularProgressIndicator());
    }
    if (_searchResults.isEmpty) {
      return const Center(child: Text("No cryptos found", style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final crypto = _searchResults[index];
        return _buildCryptoItem(crypto);
      },
    );
  }

  Widget _buildCryptoList() {
    if (_cryptos.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchCryptos,
        child: ListView(
          children: const [
            Center(child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("No data found. Pull to refresh.", style: TextStyle(color: Colors.grey)),
            )),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchCryptos,
      child: ListView.builder(
        itemCount: _cryptos.length,
        itemBuilder: (context, index) {
          final crypto = _cryptos[index];
          return _buildCryptoItem(crypto);
        },
      ),
    );
  }

  Widget _buildCryptoItem(CryptoModel crypto) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final isPositive = crypto.priceChangePercentage24h >= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF222232),
            backgroundImage: NetworkImage(crypto.image),
            onBackgroundImageError: (_, __) => const Icon(Icons.monetization_on, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        crypto.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currencyFormat.format(crypto.currentPrice),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        crypto.symbol,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${isPositive ? '+' : ''}${crypto.priceChangePercentage24h.toStringAsFixed(2)}%",
                      style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
