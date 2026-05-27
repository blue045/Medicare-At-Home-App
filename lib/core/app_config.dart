class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://medicareathome.pages.dev',
  );

  static Uri websiteUri([String path = '/']) {
    final base = apiBaseUrl.endsWith('/')
        ? apiBaseUrl.substring(0, apiBaseUrl.length - 1)
        : apiBaseUrl;
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$normalized');
  }

  static String absoluteUrl(String value) {
    final raw = value.trim();
    if (raw.isEmpty || raw.startsWith('data:')) return raw;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    if (raw.startsWith('/')) return '${apiBaseUrl.replaceFirst(RegExp(r'/$'), '')}$raw';
    return raw;
  }
}
