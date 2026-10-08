import 'package:flutter/material.dart';

class CityResult {
  final String name;
  final String? admin1;
  final String country;
  final double latitude;
  final double longitude;

  const CityResult({
    required this.name,
    this.admin1,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory CityResult.fromJson(Map<String, dynamic> json) {
    return CityResult(
      name: (json['name'] ?? '') as String,
      admin1: json['admin1'] as String?,
      country: (json['country'] ?? '') as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  String get subtitle {
    final parts = <String>[
      if (admin1 != null && admin1!.isNotEmpty) admin1!,
      if (country.isNotEmpty) country,
    ];
    return parts.join(', ');
  }
}

class HourlyWeather {
  final DateTime time;
  final double temp;
  final int rainChance;
  final int code;
  final bool isDay;

  const HourlyWeather({
    required this.time,
    required this.temp,
    required this.rainChance,
    required this.code,
    required this.isDay,
  });
}

class DailyWeather {
  final DateTime date;
  final double max;
  final double min;
  final int rainChance;
  final int code;
  final DateTime sunrise;
  final DateTime sunset;

  const DailyWeather({
    required this.date,
    required this.max,
    required this.min,
    required this.rainChance,
    required this.code,
    required this.sunrise,
    required this.sunset,
  });
}

class WeatherData {
  final CityResult city;
  final DateTime now;
  final double temp;
  final double feelsLike;
  final int code;
  final bool isDay;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;
  final DailyWeather today;

  const WeatherData({
    required this.city,
    required this.now,
    required this.temp,
    required this.feelsLike,
    required this.code,
    required this.isDay,
    required this.hourly,
    required this.daily,
    required this.today,
  });

  double get sunProgress {
    final total = today.sunset.difference(today.sunrise).inMinutes;
    if (total <= 0) return 0;
    final passed = now.difference(today.sunrise).inMinutes;
    return (passed / total).clamp(0.0, 1.0);
  }
}

class WeatherCodes {
  static String describe(int code) {
    if (code == 0) return 'Clear';
    if (code == 1) return 'Mostly Clear';
    if (code == 2) return 'Partly Cloudy';
    if (code == 3) return 'Cloudy';
    if (code == 45 || code == 48) return 'Foggy';
    if (code >= 51 && code <= 57) return 'Drizzle';
    if (code >= 61 && code <= 67) return 'Rainy';
    if (code >= 71 && code <= 77) return 'Snowy';
    if (code >= 80 && code <= 82) return 'Rain Showers';
    if (code == 85 || code == 86) return 'Snow Showers';
    if (code >= 95) return 'Thunderstorm';
    return 'Cloudy';
  }

  static IconData icon(int code, bool isDay) {
    if (code == 0) return isDay ? Icons.wb_sunny : Icons.nightlight_round;
    if (code == 1 || code == 2) {
      return isDay ? Icons.wb_cloudy : Icons.nights_stay;
    }
    if (code == 3) return Icons.cloud;
    if (code == 45 || code == 48) return Icons.foggy;
    if (code >= 51 && code <= 57) return Icons.grain;
    if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82)) {
      return Icons.umbrella;
    }
    if ((code >= 71 && code <= 77) || code == 85 || code == 86) {
      return Icons.ac_unit;
    }
    if (code >= 95) return Icons.thunderstorm;
    return Icons.cloud;
  }
}