# CLAUDE.md — Edium Mobile

Мобильное приложение Edium — Flutter (iOS/Android). Образовательная платформа с квизами.

## Архитектура

Clean Architecture с 5 слоями. Зависимости только вниз: Presentation → Domain ← Data.

```
lib/
├── core/            # DI, роутер, тема, хранилище
│   ├── config/api_config.dart   # ApiConfig.useMock — главный переключатель
│   ├── di/injection.dart        # GetIt DI
│   ├── router/app_router.dart   # GoRouter + реактивный redirect
│   └── storage/                 # Hive-боксы
├── domain/          # Чистая бизнес-логика (нет Flutter, нет Dio)
│   ├── entities/    # Бизнес-объекты
│   ├── repositories/# Абстрактные интерфейсы
│   └── usecases/    # Один UseCase = одно действие
├── data/            # Реализации данных
│   ├── models/      # JSON-модели (fromJson/toJson)
│   ├── datasources/ # *Mock/Hive (без бэкенда) и *Impl (HTTP)
│   └── repositories/# Реализации интерфейсов
├── presentation/    # UI: Widgets + BLoC
│   └── shared/widgets/
├── services/        # Внешние сервисы
│   ├── doorman_api_service/
│   ├── network/     # DioHandler, BaseApiService
│   └── token_storage/
└── main.dart
```

## Мок-система (один флаг)

`lib/core/config/api_config.dart`:
```dart
class ApiConfig {
  static bool useMock = true;  // false → реальный бэкенд
}
```

При `useMock = true` — всё работает локально через Hive без HTTP.
Переключение происходит только в `injection.dart`.

**Мок-авторизация:** любой телефон + OTP-код `"1234"`

## BLoC

```dart
// Widget → Event → BLoC → State → rebuild
context.read<AuthBloc>().add(SendOtpEvent(phone));
```

**Основные BLoC:** AuthBloc, TakeQuizBloc, StudentQuizBloc, TeacherQuizLibraryBloc, CreateQuizBloc

## HTTP-слой

`BaseApiService.request<T>(path, {method, req, query, parser})` — базовый метод для всех datasource.

`DioHandler` — синглтон: Bearer-токен + автообновление при 401/403 + логирование (debug).

## Навигация

GoRouter реактивно слушает `AuthBloc.stream`. При смене AuthState → автоматический redirect.

Маршруты: `/splash` → `/welcome` → `/phone` → `/otp` → `/name-input` → `/role-selection` → `/teacher/home` или `/student/home`

## Команды

```bash
flutter run
flutter test
flutter analyze
dart format .
dart fix --apply

bundle exec fastlane ios beta
bundle exec fastlane android beta
```

## Паттерн: новый datasource

1. Интерфейс в `domain/repositories/`
2. Мок-реализация в `data/datasources/` (Hive, без сети)
3. Impl-реализация в `data/datasources/` (через BaseApiService)
4. Регистрация в `injection.dart` с проверкой `ApiConfig.useMock`

## Соглашения

- **Язык:** комментарии, git-сообщения — на русском
- Domain не импортирует Flutter, Dio, Hive — только чистый Dart
- BLoC не вызывает другой BLoC напрямую
- Нет `print()` в продовом коде — только `debugPrint`
- Цвета и стили только из `app_colors.dart` / `app_text_styles.dart`
