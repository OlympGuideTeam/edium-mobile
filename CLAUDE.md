# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# CLAUDE.md — Edium Mobile

Мобильное приложение Edium — Flutter (iOS/Android) + Swift для нативных iOS-модулей. Образовательная платформа с квизами.

> **Важно:** Flutter-проект находится в подпапке `edium/`. Все команды выполнять из `edium/`.

> **Продуктовые флоу:** карта экранов → сервисы → API-контракт (включая WebSocket-события) описана в
> `edium-claude/claude/shared/PRODUCT_FLOWS.md` — читай перед реализацией новых экранов.

## Архитектура

Clean Architecture с 5 слоями. Зависимости только вниз: Presentation → Domain ← Data.

```
edium/lib/
├── core/            # DI, роутер, тема, хранилище
│   ├── config/api_config.dart   # ApiConfig.useMock + baseUrl
│   ├── di/injection.dart        # GetIt DI — единственное место условной регистрации
│   ├── router/app_router.dart   # GoRouter + RouterNotifier слушает AuthBloc
│   ├── storage/                 # Hive-боксы (quizzes, profile, sessions)
│   └── theme/                   # app_colors.dart, app_text_styles.dart, app_theme.dart
├── domain/          # Чистая бизнес-логика — только Dart, без Flutter/Dio/Hive
│   ├── entities/    # User, Quiz, Question, QuizSession
│   ├── repositories/# Абстрактные интерфейсы (IAuthRepository, IUserRepository, ...)
│   └── usecases/    # Один UseCase = одно действие (13 UseCases)
├── data/            # Реализации данных
│   ├── models/      # JSON-модели с fromJson/toJson + toEntity()
│   ├── datasources/ # *Mock/Hive (без бэкенда) и *Impl (HTTP через DioHandler)
│   └── repositories/# Реализации интерфейсов
├── presentation/    # UI: Widgets + BLoC
│   ├── auth/        # SplashScreen, WelcomeScreen, PhoneInputScreen, OtpScreen, NameInputScreen, RoleSelectionScreen
│   ├── teacher/     # TeacherHome, CreateQuiz, AddQuestion, QuizResults, Classes, Courses
│   ├── student/     # StudentHome, QuizLibrary, QuizPreview, TakeQuiz, QuizResult
│   └── shared/widgets/ # QuizCard, EdiumTextField, EdiumButton, SearchBarWidget
├── services/        # Внешние сервисы (не зависят от domain)
│   ├── doorman_api_service/  # sendOtp, verifyOtp, register, refreshTokens, logout
│   ├── network/     # DioHandler (singleton), BaseApiService
│   └── token_storage/       # FlutterSecureStorage wrapper
└── main.dart        # Hive init → initializeDependencies() → AuthBloc(AppStarted) → MaterialApp
```

## Мок-система (один флаг)

`lib/core/config/api_config.dart`:
```dart
class ApiConfig {
  static bool useMock = true;   // false → реальный бэкенд
  static const String baseUrl = 'https://edium.ru/';
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

**AuthBloc — состояния:** AuthInitial → AuthLoading → AuthUnauthenticated / AuthOtpSent(phone) / AuthNameRequired(user) / AuthRoleRequired(user) / AuthAuthenticated(user) / AuthError(message)

**Основные BLoC:** AuthBloc, TeacherQuizLibraryBloc, StudentQuizBloc, TakeQuizBloc, CreateQuizBloc, QuizLobbyBloc, QuizMonitorBloc, ClassBloc, CourseBloc

## HTTP-слой

`DioHandler` — синглтон: Bearer-токен + автообновление при 401/403 + `PrettyDioLogger` в debug.

`BaseApiService.request<T>(path, {method, req, query, parser})` — базовый метод для всех datasource.

## Навигация

`RouterNotifier` подписывается на `AuthBloc.stream`. При смене `AuthState` → автоматический redirect в `_redirect()`.

**Auth-флоу:** `/splash` → `/welcome` → `/phone` → `/otp?phone=...` → `/name-input` → `/role-selection` → `/teacher/home` или `/student/home`

**Таб-бар учителя:** Home / Квизы / Классы / Профиль

**Таб-бар ученика:** Home / Квизы / Классы / Профиль

## Карта экранов

### Авторизация
| # | Экран | Описание |
|---|-------|----------|
| 1 | Welcome | Войти или присоединиться к квизу по коду (без авторизации) |
| 2 | PhoneInput | Ввод телефона + выбор канала подтверждения (Telegram, SMS) |
| 3 | OtpInput | Ввод 6-значного кода |
| 4 | NameInput | Ввод имени (только при первой регистрации) |
| 5 | RoleSelection | Выбор роли: учитель / ученик |

### Учитель — таб-бар
| # | Экран | Описание |
|---|-------|----------|
| 6 | TeacherHome | Активные/предстоящие квизы, активность классов, кнопка "Создать" |
| 7 | TeacherQuizLibrary | Мои квизы + глобальные, фильтры, поиск, избранное |
| 8 | TeacherClasses | Список классов: кол-во учеников, последняя активность |
| 9 | TeacherProfile | Профиль + настройки |

### Ученик — таб-бар
| # | Экран | Описание |
|---|-------|----------|
| 10 | StudentHome | Баннер активного квиза, предстоящие дедлайны, последние оценки |
| 11 | StudentQuizLibrary | Доступные квизы, пройденные, в процессе |
| 12 | StudentClasses | Мои классы (курсы вложены внутрь класса) |
| 13 | StudentProfile | Профиль + настройки |

### Управление
| # | Экран | Описание |
|---|-------|----------|
| 14 | ClassDetail | Список учеников, квизы класса, курсы класса, пригласить |
| 15 | CourseDetail | Модули курса, квизы, участники (доступ из ClassDetail) |
| 16 | CreateQuiz | Тип квиза (синхр/асинхр), вопросы, настройки (таймер, дедлайн, лимит, отложенный старт) |
| 17 | CreateClass | Название, описание, пригласить учеников |
| 18 | CreateCourse | Название, модули, привязка к классу |
| 19 | Gradebook | Ведомость: оценки учеников по квизам класса |

### Квиз — вход
| # | Экран | Роль | Описание |
|---|-------|------|----------|
| 20 | QrScanner | все | Сканирование QR-кода камерой для входа в квиз (авторизованные и нет) |

### Квиз — проведение (🔌 WebSocket)
> QuizLobby и QuizMonitor — только для **синхронного** режима (все ученики отвечают одновременно, как в Quizizz)

| # | Экран | Роль | Описание |
|---|-------|------|----------|
| 21 | QuizLobby | ученик | Ожидание старта: список вошедших, QR/код для входа `WS` |
| 22 | QuizMonitor | учитель | Real-time прогресс учеников, QR-код для входа, кнопка дисквалификации `WS` |
| 23 | QuizTakingSync | ученик | Вопрос → ответ → ожидание → статистика → след. вопрос `WS` |
| 24 | QuizTakingAsync | ученик | Вопросы в своём темпе `WS` |
| 25 | QuizResultsStudent | ученик | Итоговый счёт, разбор ошибок |
| 26 | QuizResultsTeacher | учитель | Агрегированная статистика по квизу, ответы по вопросам |

### Работы — v2
| # | Экран | Описание |
|---|-------|----------|
| 27 | CreateWork | Создание проверочной работы |
| 28 | SolveWork | Решение работы (текст или фото → Hawkeye OCR) |
| 29 | GradeWork | Оценивание работы учителем |
| 30 | WorkResult | Оценка и разбор работы для ученика |

## Swift (нативные iOS-модули)

Swift используется для функциональности, недоступной в чистом Flutter.

**Расположение:** `edium/ios/` — стандартная структура iOS-проекта Xcode.

**Интеграция с Flutter:** через [Platform Channels](https://docs.flutter.dev/platform-integration/platform-channels):
```dart
// Dart-сторона
final channel = MethodChannel('edium/имя_канала');
final result = await channel.invokeMethod('метод', аргументы);
```
```swift
// Swift-сторона (AppDelegate.swift или отдельный плагин)
let channel = FlutterMethodChannel(name: "edium/имя_канала", binaryMessenger: controller)
channel.setMethodCallHandler { call, result in
    // обработка вызова
}
```

**Когда писать Swift, а не Dart:**
- Нативные системные API (недоступны во Flutter)
- Нативные iOS-уведомления (сложные сценарии поверх Firebase)
- Нативный UI-компонент, встраиваемый через `UiKitView`

## Команды

```bash
# Из папки edium/
flutter run
flutter test
flutter test test/path/to/test_file.dart   # запустить один тест
flutter analyze
dart format .
dart fix --apply

# Кодогенерация (Freezed + json_serializable)
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs   # в режиме watch

# Открыть iOS-проект в Xcode (для Swift-разработки)
open ios/Runner.xcworkspace

bundle exec fastlane ios beta
bundle exec fastlane android beta
```

## Паттерн: новый datasource

1. Интерфейс в `domain/repositories/`
2. Мок-реализация в `data/datasources/` (Hive, без сети)
3. Impl-реализация в `data/datasources/` (через `BaseApiService`)
4. Регистрация в `injection.dart` с проверкой `ApiConfig.useMock`

## Соглашения

- **Язык:** комментарии, git-сообщения — на русском
- Domain не импортирует Flutter, Dio, Hive — только чистый Dart
- BLoC не вызывает другой BLoC напрямую
- Нет `print()` в продовом коде — только `debugPrint`
- Цвета и стили только из `app_colors.dart` / `app_text_styles.dart`
- Модели с `@freezed` / `@JsonSerializable` требуют регенерации после изменений
