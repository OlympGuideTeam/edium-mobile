class ApiConfig {
  ApiConfig._();

  /// Переключатель: true = мок-данные, false = реальный бэкенд
  static bool useMock = true;

  static const String baseUrl = 'https://edium.ru/';
}
