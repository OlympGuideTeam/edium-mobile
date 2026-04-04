# CLAUDE.md — Edium Mobile

Мобильное приложение Edium — Flutter (iOS/Android) + Swift для нативных iOS-модулей. Образовательная платформа с квизами.

> **Продуктовые флоу:** карта экранов → сервисы → API-контракт (включая WebSocket-события) описана в
> `claude/shared/PRODUCT_FLOWS.md` — читай перед реализацией новых экранов.

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

**Основные BLoC:** AuthBloc, TeacherQuizLibraryBloc, StudentQuizLibraryBloc, CreateQuizBloc, QuizLobbyBloc, QuizMonitorBloc, TakeQuizBloc, ClassBloc, CourseBloc

## HTTP-слой

`BaseApiService.request<T>(path, {method, req, query, parser})` — базовый метод для всех datasource.

`DioHandler` — синглтон: Bearer-токен + автообновление при 401/403 + логирование (debug).

## Навигация

GoRouter реактивно слушает `AuthBloc.stream`. При смене AuthState → автоматический redirect.

**Auth-флоу:** `/splash` → `/welcome` → `/phone` → `/otp` → `/role-selection` → `/teacher/home` или `/student/home`

**Таб-бар учителя:** Home / Квизы / Классы / Профиль

**Таб-бар ученика:** Home / Квизы / Классы / Профиль

## Карта экранов

### Авторизация
| # | Экран | Описание |
|---|-------|----------|
| 1 | Welcome | Войти или присоединиться к квизу по коду (без авторизации) |
| 2 | PhoneInput | Ввод телефона + выбор канала подтверждения (Telegram, SMS) |
| 3 | OtpInput | Ввод 6-значного кода |
| 4 | RoleSelection | Выбор роли: учитель / ученик |

### Учитель — таб-бар
| # | Экран | Описание |
|---|-------|----------|
| 5 | TeacherHome | Активные/предстоящие квизы, активность классов, кнопка "Создать" |
| 6 | TeacherQuizLibrary | Мои квизы + глобальные, фильтры, поиск, избранное |
| 7 | TeacherClasses | Список классов: кол-во учеников, последняя активность |
| 8 | TeacherProfile | Профиль + настройки |

### Ученик — таб-бар
| # | Экран | Описание |
|---|-------|----------|
| 9 | StudentHome | Баннер активного квиза, предстоящие дедлайны, последние оценки |
| 10 | StudentQuizLibrary | Доступные квизы, пройденные, в процессе |
| 11 | StudentClasses | Мои классы (курсы вложены внутрь класса) |
| 12 | StudentProfile | Профиль + настройки |

### Управление
| # | Экран | Описание |
|---|-------|----------|
| 13 | ClassDetail | Список учеников, квизы класса, курсы класса, пригласить |
| 14 | CourseDetail | Модули курса, квизы, участники (доступ из ClassDetail) |
| 15 | CreateQuiz | Тип квиза (синхр/асинхр), вопросы, настройки (таймер, дедлайн, лимит, отложенный старт) |
| 16 | CreateClass | Название, описание, пригласить учеников |
| 17 | CreateCourse | Название, модули, привязка к классу |
| 18 | Gradebook | Ведомость: оценки учеников по квизам класса |

### Квиз — вход
| # | Экран | Роль | Описание |
|---|-------|------|----------|
| 19 | QrScanner | все | Сканирование QR-кода камерой для входа в квиз (авторизованные и нет) |

### Квиз — проведение (🔌 WebSocket)
> QuizLobby и QuizMonitor — только для **синхронного** режима (все ученики отвечают одновременно, как в Quizizz)

| # | Экран | Роль | Описание |
|---|-------|------|----------|
| 20 | QuizLobby | ученик | Ожидание старта: список вошедших, QR/код для входа `WS` |
| 21 | QuizMonitor | учитель | Real-time прогресс учеников, QR-код для входа, кнопка дисквалификации `WS` |
| 22 | QuizTakingSync | ученик | Вопрос → ответ → ожидание → статистика → след. вопрос `WS` |
| 23 | QuizTakingAsync | ученик | Вопросы в своём темпе `WS` |
| 24 | QuizResultsStudent | ученик | Итоговый счёт, разбор ошибок |
| 25 | QuizResultsTeacher | учитель | Агрегированная статистика по квизу, ответы по вопросам |

### Работы — v2
| # | Экран | Описание |
|---|-------|----------|
| 26 | CreateWork | Создание проверочной работы |
| 27 | SolveWork | Решение работы (текст или фото → Hawkeye OCR) |
| 28 | GradeWork | Оценивание работы учителем |
| 29 | WorkResult | Оценка и разбор работы для ученика |

## Swift (нативные iOS-модули)

Swift используется для функциональности, недоступной в чистом Flutter.

**Расположение:** `ios/` — стандартная структура iOS-проекта Xcode.

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

**Сборка:** `flutter build ios` компилирует Swift вместе с Dart-кодом автоматически.

## Команды

```bash
flutter run
flutter test
flutter analyze
dart format .
dart fix --apply

# Открыть iOS-проект в Xcode (для Swift-разработки)
open ios/Runner.xcworkspace

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

