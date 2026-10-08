import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather_model.dart';

class WeatherService {
  static const String _forecastHost = 'api.open-meteo.com';
  static const String _geoHost = 'geocoding-api.open-meteo.com';

  Future<List<CityResult>> searchCity(String query) async {
    final text = query.trim();
    if (text.length < 2) return [];

    final uri = Uri.https(_geoHost, '/v1/search', {
      'name': text,
      'count': '8',
      'language': 'en',
      'format': 'json',
    });

    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('City search failed (${res.statusCode})');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (body['results'] as List?) ?? [];
    return list
        .map((e) => CityResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WeatherData> fetchWeather(CityResult city) async {
    final uri = Uri.https(_forecastHost, '/v1/forecast', {
      'latitude': city.latitude.toString(),
      'longitude': city.longitude.toString(),
      'current': 'temperature_2m,apparent_temperature,weather_code,is_day',
      'hourly': 'temperature_2m,precipitation_probability,weather_code,is_day',
      'daily':
      'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,sunrise,sunset',
      'timezone': 'auto',
      'past_days': '1',
      'forecast_days': '7',
    });

    final res = await http.get(uri).timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) {
      throw Exception('Weather request failed (${res.statusCode})');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;

    final current = json['current'] as Map<String, dynamic>;
    final now = DateTime.parse(current['time'] as String);

    final h = json['hourly'] as Map<String, dynamic>;
    final hTimes = (h['time'] as List).cast<String>();
    final hTemp = h['temperature_2m'] as List;
    final hRain = h['precipitation_probability'] as List;
    final hCode = h['weather_code'] as List;
    final hDay = h['is_day'] as List;

    final allHourly = <HourlyWeather>[];
    for (var i = 0; i < hTimes.length; i++) {
      allHourly.add(HourlyWeather(
        time: DateTime.parse(hTimes[i]),
        temp: _num(hTemp[i]),
        rainChance: _num(hRain[i]).round(),
        code: _num(hCode[i]).round(),
        isDay: _num(hDay[i]) == 1,
      ));
    }

    final nowHour = DateTime(now.year, now.month, now.day, now.hour);
    var start = allHourly.indexWhere((e) => !e.time.isBefore(nowHour));
    if (start == -1) start = 0;
    final hourly = allHourly.skip(start).take(24).toList();

    final d = json['daily'] as Map<String, dynamic>;
    final dTimes = (d['time'] as List).cast<String>();
    final dMax = d['temperature_2m_max'] as List;
    final dMin = d['temperature_2m_min'] as List;
    final dRain = d['precipitation_probability_max'] as List;
    final dCode = d['weather_code'] as List;
    final dRise = (d['sunrise'] as List).cast<String>();
    final dSet = (d['sunset'] as List).cast<String>();

    final daily = <DailyWeather>[];
    for (var i = 0; i < dTimes.length; i++) {
      daily.add(DailyWeather(
        date: DateTime.parse(dTimes[i]),
        max: _num(dMax[i]),
        min: _num(dMin[i]),
        rainChance: _num(dRain[i]).round(),
        code: _num(dCode[i]).round(),
        sunrise: DateTime.parse(dRise[i]),
        sunset: DateTime.parse(dSet[i]),
      ));
    }

    var todayIndex = daily.indexWhere((e) =>
    e.date.year == now.year &&
        e.date.month == now.month &&
        e.date.day == now.day);
    if (todayIndex == -1) todayIndex = 0;

    return WeatherData(
      city: city,
      now: now,
      temp: _num(current['temperature_2m']),
      feelsLike: _num(current['apparent_temperature']),
      code: _num(current['weather_code']).round(),
      isDay: _num(current['is_day']) == 1,
      hourly: hourly,
      daily: daily,
      today: daily[todayIndex],
    );
  }

  double _num(dynamic value) {
    if (value is num) return value.toDouble();
    return 0.0;
  }
}