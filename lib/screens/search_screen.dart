import 'dart:async';

import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import '../services/weather_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _cityController = TextEditingController();
  final WeatherService _service = WeatherService();
  Timer? _debounce;

  List<CityResult> _results = [];
  bool _loading = false;
  String? _message = 'Type a city name to search';

  @override
  void dispose() {
    _debounce?.cancel();
    _cityController.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();

    if (text.trim().length < 2) {
      setState(() {
        _results = [];
        _loading = false;
        _message = 'Type a city name to search';
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () => _search(text));
  }

  Future<void> _search(String text) async {
    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      final found = await _service.searchCity(text);
      if (!mounted) return;
      if (_cityController.text.trim() != text.trim()) return;

      setState(() {
        _results = found;
        _loading = false;
        _message = found.isEmpty ? 'No city found' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = 'Search failed. Check your internet connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5BB0F0), Color(0xFF3A86E0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _cityController,
                        autofocus: true,
                        onChanged: _onChanged,
                        textInputAction: TextInputAction.search,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          hintText: 'Search city',
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon:
                          const Icon(Icons.search, color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.2),
                          contentPadding:
                          const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildResults()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_message != null) {
      return Center(
        child: Text(
          _message!,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _results.length,
      separatorBuilder: (context, index) =>
      const Divider(color: Colors.white24, height: 1),
      itemBuilder: (context, index) {
        final city = _results[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading:
          const Icon(Icons.location_on_outlined, color: Colors.white),
          title: Text(
            city.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            city.subtitle,
            style: const TextStyle(color: Colors.white70),
          ),
          onTap: () => Navigator.pop(context, city),
        );
      },
    );
  }
}