enum AppEnvironment { prod, test, mock }

class ApiConfig {
  ApiConfig._();

  static AppEnvironment environment = AppEnvironment.mock;

  static bool get useMock => environment == AppEnvironment.mock;

  static String get baseUrl => environment == AppEnvironment.prod
      ? 'https://api.edium.online/'
      : 'https://test.edium.online/';

  static String get telegramBotUsername =>
      environment == AppEnvironment.prod ? 'edium_bot' : 'edium_test_bot';
}
