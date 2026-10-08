import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import '../services/weather_service.dart';
import 'search_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final WeatherService _service = WeatherService();

  CityResult _city = const CityResult(
    name: 'Pune',
    admin1: 'Maharashtra',
    country: 'India',
    latitude: 18.5204,
    longitude: 73.8567,
  );

  WeatherData? _weather;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool showLoader = true}) async {
    if (showLoader) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final data = await _service.fetchWeather(_city);
      if (!mounted) return;
      setState(() {
        _weather = data;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load weather.\nCheck your internet connection.';
      });
    }
  }

  Future<void> _openSearch() async {
    final picked = await Navigator.push<CityResult>(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );

    if (picked != null) {
      _city = picked;
      _weather = null;
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'asset/image/mainimg.jpeg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF5BB0F0), Color(0xFF3A86E0)],
                ),
              ),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.12)),
          SafeArea(
            child: DefaultTextStyle.merge(
              style: const TextStyle(color: Colors.white),
              child: Column(
                children: [
                  Expanded(child: _buildBody()),
                  _buildBottomBar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_weather == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _load,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return _buildContent(_weather!);
  }

  Widget _buildContent(WeatherData w) {
    return RefreshIndicator(
      onRefresh: () => _load(showLoader: false),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    color: Colors.white, size: 22),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    w.city.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(8, 24, 8, 0),
            child: Text(
              '${w.temp.round()}°',
              style: const TextStyle(
                fontSize: 120,
                fontWeight: FontWeight.w200,
                height: 1.1,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              WeatherCodes.describe(w.code),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
            child: Text(
              '↑${w.today.max.round()}° / ↓${w.today.min.round()}°',
              style: const TextStyle(fontSize: 20, color: Colors.white70),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 40),
            child: Text(
              'Feels like ${w.feelsLike.round()}°',
              style: const TextStyle(fontSize: 20),
            ),
          ),

          _buildHourlyCard(w),
          _buildSunCard(w),
          _buildDailyCard(w),
        ],
      ),
    );
  }

  Widget _buildHourlyCard(WeatherData w) {
    final items = w.hourly;
    if (items.isEmpty) return const SizedBox.shrink();

    const double colWidth = 72;
    final temps = items.map((e) => e.temp).toList();

    Widget cell(Widget child) {
      return SizedBox(width: colWidth, child: Center(child: child));
    }

    return _GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${WeatherCodes.describe(w.code)}. Low ${w.today.min.round()}°C.',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              width: colWidth * items.length,
              child: Column(
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < items.length; i++)
                        cell(Text(
                          i == 0 ? 'Now' : _formatHour(items[i].time),
                          style: const TextStyle(fontSize: 13),
                        )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (final item in items)
                        cell(Icon(
                          WeatherCodes.icon(item.code, item.isDay),
                          color: Colors.white,
                          size: 26,
                        )),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (final item in items)
                        cell(Text(
                          '${item.temp.round()}°',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        )),
                    ],
                  ),
                  SizedBox(
                    width: colWidth * items.length,
                    height: 80,
                    child: CustomPaint(painter: _TempLinePainter(temps)),
                  ),
                  Row(
                    children: [
                      for (final item in items)
                        cell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.water_drop,
                                size: 14, color: Colors.white70),
                            const SizedBox(width: 2),
                            Text(
                              '${item.rainChance}%',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunCard(WeatherData w) {
    final sunsetPassed = w.now.isAfter(w.today.sunset);
    final timeText = _formatClock(w.today.sunset);

    return _GlassCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.wb_sunny_outlined,
                        size: 18, color: Colors.white),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        "Don't miss the sunset",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  sunsetPassed
                      ? 'Sunset was at $timeText'
                      : 'Sunset will be at $timeText',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              SizedBox(
                width: 140,
                height: 70,
                child: CustomPaint(
                  painter: _SunArcPainter(w.sunProgress),
                ),
              ),
              const SizedBox(height: 4),
              Text(timeText, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyCard(WeatherData w) {
    return _GlassCard(
      child: Column(
        children: [
          for (final day in w.daily) _buildDailyRow(day, w.now),
        ],
      ),
    );
  }

  Widget _buildDailyRow(DailyWeather day, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(day.date.year, day.date.month, day.date.day);
    final diff = date.difference(today).inDays;

    String label;
    if (diff == -1) {
      label = 'Yesterday';
    } else if (diff == 0) {
      label = 'Today';
    } else {
      const names = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      label = names[date.weekday - 1];
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(Icons.water_drop, size: 14, color: Colors.white70),
                const SizedBox(width: 2),
                Text('${day.rainChance}%',
                    style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
          Icon(WeatherCodes.icon(day.code, true), color: Colors.white),
          Expanded(
            flex: 3,
            child: Text(
              '${day.max.round()}° ${day.min.round()}°',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
          ),
          IconButton(
            onPressed: _openSearch,
            icon: const Icon(Icons.search, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  String _formatHour(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final period = t.hour >= 12 ? 'pm' : 'am';
    return '$h $period';
  }

  String _formatClock(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.hour >= 12 ? 'pm' : 'am';
    return '$h:$m $period';
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: double.infinity,
            padding: padding,
            color: Colors.white.withValues(alpha: 0.18),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _TempLinePainter extends CustomPainter {
  final List<double> values;

  _TempLinePainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final range = (maxV - minV) == 0 ? 1.0 : (maxV - minV);

    final slot = size.width / values.length;
    const pad = 14.0;

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = slot * i + slot / 2;
      final y = pad + (maxV - values[i]) / range * (size.height - pad * 2);
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final midX = (prev.dx + curr.dx) / 2;
      path.cubicTo(midX, prev.dy, midX, curr.dy, curr.dx, curr.dy);
    }

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = Colors.white;
    for (final p in points) {
      canvas.drawCircle(p, 4.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TempLinePainter oldDelegate) {
    return oldDelegate.values != values;
  }
}

class _SunArcPainter extends CustomPainter {
  final double progress;

  _SunArcPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final baseY = size.height - 2;
    final centerX = size.width / 2;
    final radius = math.min(size.width / 2 - 8, baseY - 8);

    final linePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, baseY), Offset(size.width, baseY), linePaint);

    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, baseY), radius: radius),
      math.pi,
      math.pi,
      false,
      linePaint,
    );

    final angle = math.pi + math.pi * progress;
    final sun = Offset(
      centerX + radius * math.cos(angle),
      baseY + radius * math.sin(angle),
    );

    canvas.drawCircle(
      sun,
      11,
      Paint()..color = const Color(0xFFFFD54F).withValues(alpha: 0.35),
    );
    canvas.drawCircle(sun, 6, Paint()..color = const Color(0xFFFFD54F));
  }

  @override
  bool shouldRepaint(covariant _SunArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}