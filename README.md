# Weather

A clean, modern weather app built with Flutter. It shows the current conditions, a 24-hour forecast, sunset tracking and a 7-day outlook for any city in the world, using the free [Open-Meteo](https://open-meteo.com/) APIs. No API key is required.

## Features

- Current temperature, weather condition, "feels like" temperature and today's high and low
- Hourly forecast for the next 24 hours with weather icons, a smooth temperature curve and rain probability
- Sunset card with an animated sun arc showing how far the day has progressed
- Daily forecast with yesterday, today and the upcoming days, including rain chance and min/max temperatures
- City search with live suggestions and debounced requests
- Pull-to-refresh and a refresh button
- Frosted-glass card design over a full-screen background image
- Loading, error and retry states
- Defaults to Pune, Maharashtra, India on first launch

## Tech Stack

| Area | Details |
| --- | --- |
| Framework | Flutter (Material 3) |
| Language | Dart (SDK `^3.12.2`) |
| Networking | [`http`](https://pub.dev/packages/http) |
| Weather data | Open-Meteo Forecast API |
| City search | Open-Meteo Geocoding API |
| Custom drawing | `CustomPainter` for the temperature line and sun arc |

## Project Structure

```
lib/
├── main.dart
├── models/
│   └── weather_model.dart
├── screens/
│   ├── home_screen.dart
│   └── search_screen.dart
├── services/
│   └── weather_service.dart
├── utils/
│   └── constants.dart
└── widgets/
    └── search_bar_widget.dart
asset/
└── image/
    └── mainimg.jpeg
```

- `main.dart` starts the app and sets up the Material 3 theme.
- `weather_model.dart` contains the data models (`CityResult`, `HourlyWeather`, `DailyWeather`, `WeatherData`) and the weather code to description and icon mapping.
- `weather_service.dart` handles city search and weather requests, and parses the responses into models.
- `home_screen.dart` is the main weather screen with the hourly, sunset and daily cards.
- `search_screen.dart` is the city search screen.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) with Dart `^3.12.2`
- Android Studio, VS Code or any editor with Flutter support
- An emulator, a physical device, or Chrome for running on the web

### Installation

```bash
git clone <your-repository-url>
cd weather
flutter pub get
```

### Run

```bash
flutter run
```

To run on a specific platform:

```bash
flutter run -d chrome
flutter run -d windows
flutter run -d <device-id>
```

### Build

```bash
flutter build apk --release
```

## How It Works

1. On launch, the app loads the weather for the default city.
2. Tapping the search icon opens the search screen. After at least two characters are typed, matching cities are fetched from the Open-Meteo Geocoding API.
3. Selecting a city returns its coordinates to the home screen, which requests the forecast from the Open-Meteo Forecast API.
4. The response includes current conditions, hourly data and daily data for 7 days plus the previous day, with the timezone detected automatically from the coordinates.
5. The data is parsed into models and rendered as the hourly, sunset and daily cards.

## Data Source

Weather data and geocoding are provided by [Open-Meteo](https://open-meteo.com/), which is free for non-commercial use and does not require an API key.

## Supported Platforms

Android, iOS, Web, Windows, macOS and Linux.

## License

This project is for personal and learning use. Add a license of your choice if you plan to distribute it.
