import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Immutable, validated client-side configuration.
///
/// Keep only public configuration in this class. Flutter environment files are
/// packaged with the app and must never contain privileged server credentials.
class AppConfig {
  const AppConfig._({
    required this.environment,
    required this.supabaseUrl,
    required this.supabasePublishableKey,
    this.authRedirectUrl,
  });

  final String environment;
  final String supabaseUrl;
  final String supabasePublishableKey;
  final String? authRedirectUrl;

  factory AppConfig.fromEnvironment() {
    final url = _required('SUPABASE_URL');
    final publishableKey = _required('SUPABASE_PUBLISHABLE_KEY');
    final uri = Uri.tryParse(url);

    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw StateError('SUPABASE_URL must be a valid absolute URL.');
    }
    if (uri.scheme != 'https' && uri.host != 'localhost') {
      throw StateError('SUPABASE_URL must use HTTPS outside localhost.');
    }
    if (publishableKey.toLowerCase().contains('service_role')) {
      throw StateError(
        'SUPABASE_PUBLISHABLE_KEY must not contain a service-role key.',
      );
    }

    return AppConfig._(
      environment: dotenv.get('APP_ENV', fallback: 'development'),
      supabaseUrl: uri.toString().replaceFirst(RegExp(r'/$'), ''),
      supabasePublishableKey: publishableKey,
      authRedirectUrl: dotenv.maybeGet('SUPABASE_AUTH_REDIRECT_URL'),
    );
  }

  static String _required(String name) {
    final value = dotenv.maybeGet(name)?.trim();
    if (value == null || value.isEmpty || value.startsWith('YOUR_')) {
      throw StateError('Missing required environment value: $name.');
    }
    return value;
  }
}
