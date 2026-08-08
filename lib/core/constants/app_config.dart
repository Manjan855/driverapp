class AppConfig {
  // These values are injected at compile time via --dart-define
  // They default to empty string if not provided
  static const String maptilerApiKey = String.fromEnvironment(
    'MAPTILER_API_KEY',
    defaultValue: '',
  );

  static const String backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://10.0.2.2:5000', // emulator fallback
  );

  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'http://10.0.2.2:5000', // emulator fallback
  );

  static const String apiUrl = '$backendUrl/api';

  // Validate that required config is present
  static void validate() {
    assert(
      maptilerApiKey.isNotEmpty,
      'MAPTILER_API_KEY is not set. Run with --dart-define=MAPTILER_API_KEY=your_key',
    );
    assert(
      backendUrl.isNotEmpty,
      'BACKEND_URL is not set. Run with --dart-define=BACKEND_URL=your_url',
    );
  }
}
