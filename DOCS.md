# EDIUM — АРХИТЕКТУРНАЯ ДОКУМЕНТАЦИЯ
## Образовательная мобильная платформа

---

## Содержание

1. [Обзор архитектуры](#1-обзор-архитектуры)
2. [Структура проекта](#2-структура-проекта)
3. [Жизненный цикл запуска приложения](#3-жизненный-цикл-запуска-приложения)
4. [Сетевой слой (Network Layer)](#4-сетевой-слой-network-layer)
5. [Система моков и переключение на реальный бэкенд](#5-система-моков-и-переключение-на-реальный-бэкенд)
6. [Dependency Injection (GetIt)](#6-dependency-injection-getit)
7. [BLoC — управление состоянием](#7-bloc--управление-состоянием)
8. [Навигация (GoRouter)](#8-навигация-gorouter)
9. [Хранилище данных (Hive)](#9-хранилище-данных-hive)
10. [Полный флоу: от запуска до прохождения квиза](#10-полный-флоу-от-запуска-до-прохождения-квиза)

---

## 1. Обзор архитектуры

Edium построен на базе **Clean Architecture** с разделением на 5 слоев:

```
┌─────────────────────────────────────────────────────────┐
│                   PRESENTATION                          │
│     Экраны (Widgets) + BLoC (события/состояния)         │
├─────────────────────────────────────────────────────────┤
│                     DOMAIN                              │
│   Entities + Repository Interfaces + UseCases           │
├─────────────────────────────────────────────────────────┤
│                      DATA                               │
│  Models + Datasources (Mock/Real) + Repository Impl     │
├─────────────────────────────────────────────────────────┤
│                    SERVICES                             │
│       Dio, Token Storage, Doorman API Service           │
├─────────────────────────────────────────────────────────┤
│                      CORE                               │
│     DI, Router, Theme, Config, Hive Storage             │
└─────────────────────────────────────────────────────────┘
```

**Принцип:** верхние слои зависят от нижних, но **НЕ** наоборот. Domain-слой не знает ни о Flutter, ни о Dio, ни о Hive — он содержит только чистую бизнес-логику.

---

## 2. Структура проекта

```
lib/
├── core/                          # Инфраструктура
│   ├── config/
│   │   └── api_config.dart        # Флаг useMock = true/false
│   ├── di/
│   │   └── injection.dart         # GetIt — регистрация зависимостей
│   ├── router/
│   │   └── app_router.dart        # GoRouter + redirect по AuthState
│   ├── storage/
│   │   ├── hive_storage.dart      # Инициализация Hive-боксов
│   │   └── profile_storage.dart   # Хранение имени, роли, телефона
│   └── theme/
│       ├── app_colors.dart        # Палитра
│       ├── app_text_styles.dart   # Стили текста
│       └── app_theme.dart         # ThemeData
│
├── data/                          # Реализация данных
│   ├── models/                    #
│   ├── datasources/               # Источники данных
│   └── repositories/              # Реализации репозиториев
│
├── domain/                        # Чистая бизнес-логика
│   ├── entities/                  # Бизнес-объекты
│   ├── repositories/              # Абстрактные интерфейсы
│   └── usecases/                  # Единицы бизнес-логики
│
├── presentation/                  # UI
│   └── shared/
│       └── widgets/               # EdiumButton, QuizCard, SearchBar
│
├── services/                      # Внешние сервисы
│   ├── doorman_api_service/       # Авторизация через Doorman
│   ├── network/                   # DioHandler, BaseApiService, Endpoints
│   └── token_storage/             # FlutterSecureStorage для JWT
│
└── main.dart                      # Точка входа
```

---

## 3. Жизненный цикл запуска приложения

Вот что происходит при запуске приложения (`main.dart`):

```
main()
  │
  ├── 1. WidgetsFlutterBinding.ensureInitialized()
  │      Инициализация привязок Flutter до runApp
  │
  ├── 2. HiveStorage.init()
  │      Открытие трех Hive-боксов:
  │        - 'quizzes'   — хранение квизов (мок-режим)
  │        - 'profile'   — имя, роль, телефон пользователя
  │        - 'sessions'  — сессии прохождения квизов
  │
  ├── 3. initializeDependencies()
  │      Регистрация всех зависимостей в GetIt (подробнее в разделе 6)
  │
  ├── 4. getIt<AuthBloc>().add(AppStarted())
  │      Запускаем проверку авторизации:
  │        - Есть ли сохраненные токены/имя?
  │        - Если да → загружаем пользователя
  │        - Если нет → AuthUnauthenticated
  │
  └── 5. runApp(EdiumApp())
         MaterialApp.router с GoRouter
```

---

## 4. Сетевой слой (Network Layer)

Сетевой слой состоит из трех компонентов.

### 4.1 DioHandler — центральный HTTP-клиент

**Файл:** `lib/services/network/dio_handler.dart`

DioHandler — это синглтон, который настраивает Dio с тремя интерсепторами:

```
┌───────────────────────────────────────┐
│            DioHandler                 │
│                                       │
│  Dio(BaseOptions)                     │
│    baseUrl: https://edium.ru/         │
│    connectTimeout: 10s                │
│    receiveTimeout: 10s                │
│    contentType: application/json      │
│                                       │
│  Interceptors (в порядке выполнения): │
│                                       │
│  1. QueuedInterceptorsWrapper         │
│     └─ Добавляет Authorization       │
│        header к каждому запросу       │
│                                       │
│  2. DioRefreshInterceptor             │
│     └─ Автоматический refresh токена  │
│        при 401/403 ответах            │
│                                       │
│  3. PrettyDioLogger                   │
│     └─ Логирование запросов           │
│        (только в debug-режиме)        │
└───────────────────────────────────────┘
```

**Как работает автообновление токенов:**

```
Запрос → Сервер отвечает 401/403
    │
    ├── DioRefreshInterceptor перехватывает
    ├── Берет refresh_token из TokenManager
    ├── Отправляет POST doorman/v1/auth/refresh
    ├── Получает новую пару access_token + refresh_token
    ├── Сохраняет в FlutterSecureStorage
    ├── Повторяет оригинальный запрос с новым токеном
    │
    └── Если refresh не удался:
        ├── Удаляет токены из хранилища
        └── Пробрасывает ошибку дальше
```

**Инициализация:** `DioHandler.setup()` вызывается из `initializeDependencies()`:

1. Читает токены из FlutterSecureStorage
2. Если есть — загружает в TokenManager
3. Создает экземпляр DioHandler
4. Регистрирует как синглтон в GetIt

### 4.2 BaseApiService — базовый класс для API-сервисов

**Файл:** `lib/services/network/base_api_service.dart`

Все реальные datasource'ы и API-сервисы наследуются от BaseApiService. Он предоставляет единственный метод:

```dart
Future<T> request<T>(
  String path, {
    required HttpMethod method,    // GET, POST, PUT, PATCH, DELETE
    Map<String, dynamic>? req,     // тело запроса
    Map<String, dynamic>? headers, // доп. заголовки
    Map<String, dynamic>? query,   // query-параметры
    required T Function(dynamic) parser,  // парсер ответа
  })
```

Метод:

1. Формирует Options (метод + заголовки)
2. Вызывает `dio.request(path, data, queryParameters, options)`
3. Вызывает `parser(response.data)` для преобразования ответа
4. Возвращает типизированный результат `T`

**Пример использования в QuizDatasourceImpl:**

```dart
Future<List<QuizModel>> getQuizzes(...) {
  return request(
    'api/v1/quizzes',
    method: HttpMethod.get,
    query: { 'scope': scope, 'page': page, 'limit': limit },
    parser: (data) => (data['items'] as List)
        .map((e) => QuizModel.fromJson(e))
        .toList(),
  );
}
```

### 4.3 DoormanApiService — сервис авторизации

**Файл:** `lib/services/doorman_api_service/doorman_api_service.dart`

Doorman — это отдельный микросервис бэкенда для аутентификации. DoormanApiService наследует BaseApiService и реализует 5 методов:

| Метод | Эндпоинт |
|-------|----------|
| `sendOtpRequest()` | POST `doorman/v1/otp/send` |
| `otpVerifyRequest()` | POST `doorman/v1/otp/verify` |
| `registerRequest()` | POST `doorman/v1/auth/register` |
| `refreshTokensRequest()` | POST `doorman/v1/auth/refresh` |
| `logoutRequest()` | POST `doorman/v1/auth/logout` |

Каждый метод принимает DTO (Data Transfer Object) и вызывает базовый `request()` с соответствующим парсером.

### 4.4 TokenStorage — хранение JWT-токенов

**Файл:** `lib/services/token_storage/token_storage.dart`

Использует **FlutterSecureStorage** (зашифрованное хранилище ОС) для хранения `access_token` и `refresh_token`:

- `saveTokens(accessToken, refreshToken)` — сохранить пару
- `getAccessToken()` — получить access token
- `getRefreshToken()` — получить refresh token
- `deleteTokens()` — удалить оба
- `hasTokens()` — есть ли токен?

### 4.5 Endpoints

**Файл:** `lib/services/network/endpoints.dart`

Все URL авторизации хранятся как enum:

| Enum | URL |
|------|-----|
| `DoormanEndpoints.otpSend` | `doorman/v1/otp/send` |
| `DoormanEndpoints.otpVerify` | `doorman/v1/otp/verify` |
| `DoormanEndpoints.authTokensRefresh` | `doorman/v1/auth/refresh` |
| `DoormanEndpoints.authLogout` | `doorman/v1/auth/logout` |
| `DoormanEndpoints.authRegister` | `doorman/v1/auth/register` |

URL для квизов и пользователей прописаны непосредственно в datasource_impl файлах (например `api/v1/quizzes`).

---

## 5. Система моков и переключение на реальный бэкенд

Это одна из ключевых архитектурных особенностей проекта.

### 5.1 Как работает переключение

**Файл:** `lib/core/config/api_config.dart`

```dart
class ApiConfig {
  static bool useMock = true;   // <-- единственный флаг
}
```

Один статический флаг определяет **ВСЕ** поведение приложения:

- **`true`** → используются мок-реализации (Hive, локальные данные)
- **`false`** → используются реальные реализации (HTTP-запросы через Dio)

Переключение происходит в **ОДНОМ** месте: `injection.dart`

### 5.2 Как это реализовано в DI (injection.dart)

```dart
if (ApiConfig.useMock) {
  // МОК: данные хранятся локально в Hive
  getIt.registerLazySingleton<IUserDatasource>(
      () => UserDatasourceMock(getIt<ProfileStorage>()));
  getIt.registerLazySingleton<IQuizDatasource>(
      () => QuizDatasourceHive(getIt<ProfileStorage>()));
  getIt.registerLazySingleton<IQuizSessionDatasource>(
      () => QuizSessionDatasourceHive());
  getIt.registerLazySingleton<IAuthRepository>(
      () => AuthRepositoryMock());
} else {
  // РЕАЛЬНЫЙ БЭКЕНД: HTTP-запросы через Dio
  getIt.registerLazySingleton<IUserDatasource>(
      () => UserDatasourceImpl(getIt<DioHandler>().dio));
  getIt.registerLazySingleton<IQuizDatasource>(
      () => QuizDatasourceImpl(getIt<DioHandler>().dio));
  getIt.registerLazySingleton<IQuizSessionDatasource>(
      () => QuizSessionDatasourceImpl(getIt<DioHandler>().dio));
  getIt.registerLazySingleton<IAuthRepository>(
      () => AuthRepositoryImpl(doorman: getIt(), tokenStorage: getIt()));
}
```

**Ключевой момент:** Repository и UseCase **НЕ** знают, какая реализация используется. Они работают через абстрактные интерфейсы.

### 5.3 Паттерн «интерфейс → две реализации»

На примере квизов:

```
┌─────────────────────┐
│  IQuizDatasource    │  ← абстрактный интерфейс
│  (abstract class)   │
└──────┬──────┬───────┘
       │      │
┌──────┴──┐ ┌─┴──────────┐
│ Hive    │ │ Impl       │
│ (мок)   │ │ (реальный) │
└─────────┘ └────────────┘
```

**IQuizDatasource** определяет контракт:

- `getQuizzes()`, `createQuiz()`, `getQuizById()`, `likeQuiz()`, `getQuizResults()`, `updateQuizStatus()`, `deleteQuiz()`

**QuizDatasourceHive** реализует через Hive:

- Данные в `Hive.box<String>('quizzes')`
- При первом запуске — seed-квизы (3 предустановленных)
- JSON сериализация/десериализация, имитация задержек

**QuizDatasourceImpl** реализует через HTTP:

- Наследует BaseApiService
- GET `api/v1/quizzes`, POST `api/v1/quizzes` и т.д.

### 5.4 Как работает мок авторизации

| Метод | AuthRepositoryMock | AuthRepositoryImpl |
|-------|-------------------|---------------------|
| `sendOtp()` | Всегда успешен (имитация SMS) | POST `doorman/v1/otp/send` |
| `verifyOtp()` | Принимает только код `"1234"` | POST `doorman/v1/otp/verify` → сохраняет JWT |
| `logout()` | Сбрасывает флаг | POST `doorman/v1/auth/logout` → удаляет JWT |
| `isAuthenticated()` | Внутренний флаг | Проверка токенов в хранилище |

### 5.5 Как работают мок-сессии квизов

**QuizSessionDatasourceHive** — наиболее сложная мок-реализация. Имитирует серверное поведение:

- **startSession(quizId):** генерирует ID, создает `QuizSessionModel(status: 'in_progress')`, сохраняет в Hive, записывает `startedAt`
- **submitAnswer(sessionId, questionId, answer):** загружает сессию и квиз из Hive, вызывает `_evaluateAnswer()` (single_choice, multi_choice, text_input), добавляет AnswerRecord, возвращает `{ correct, explanation }`
- **completeSession(sessionId):** считает score, ставит `status = 'completed'`, записывает `completedAt`

Мок-режим даёт полностью рабочее приложение без единого HTTP-запроса.

### 5.6 Как переключиться на реальный бэкенд

1. Открыть `lib/core/config/api_config.dart`
2. Изменить: `static bool useMock = false;`
3. Убедиться, что `baseUrl` указывает на рабочий сервер
4. Перезапустить приложение

Остальное произойдёт автоматически — DI подставит реальные реализации вместо моков.

---

## 6. Dependency Injection (GetIt)

GetIt — это **Service Locator**. Все зависимости регистрируются при запуске и доступны из любого места через `getIt<Тип>()`.

**Файл:** `lib/core/di/injection.dart`

### 6.1 Порядок регистрации

`initializeDependencies()` выполняет:

| Уровень | Регистрация |
|---------|-------------|
| **1. Хранилища** | `ITokenStorage` → TokenStorage, `ProfileStorage` → ProfileStorage |
| **2. Сеть** | `DioHandler.setup()`, `IDoormanApiService` → DoormanApiService(dio) |
| **3. Datasources** | При `useMock`: UserDatasourceMock, QuizDatasourceHive, QuizSessionDatasourceHive, AuthRepositoryMock. Иначе: *Impl-версии |
| **4. Repositories** | IUserRepository, IQuizRepository, IQuizSessionRepository → *Impl |
| **5. UseCases** | SendOtpUsecase, VerifyOtpUsecase, GetQuizzesUsecase, StartQuizUsecase и др. |
| **6. BLoC** | AuthBloc (singleton) |

### 6.2 Типы регистрации

| Метод | Поведение | Использование |
|-------|-----------|---------------|
| `registerSingleton<T>(instance)` | Создаётся сразу при регистрации, один экземпляр на всё время | TokenStorage, ProfileStorage, AuthBloc |
| `registerLazySingleton<T>(() => instance)` | Создаётся при первом `getIt<T>()`, один экземпляр | Datasource, Repository, UseCase |

---

## 7. BLoC — управление состоянием

BLoC (Business Logic Component) — паттерн управления состоянием.

**Схема:** `UI (Widget) ──Event──→ BLoC ──State──→ UI (перерисовка)`

Виджет отправляет **событие** (Event). BLoC обрабатывает его и выдаёт новое **состояние** (State). Виджет перестраивается.

### 7.1 AuthBloc — центральный блок авторизации

**Файл:** `lib/presentation/auth/bloc/`

**События (AuthEvent):**

- `AppStarted` — приложение запустилось, проверить токены
- `SendOtpEvent(phone)` — отправить SMS-код
- `VerifyOtpEvent(phone, otp)` — проверить код
- `NameSubmittedEvent(name)` — пользователь ввёл имя
- `RoleSelectedEvent` — роль выбрана
- `LogoutEvent` — выход

**Состояния (AuthState):**

- `AuthInitial`, `AuthLoading`, `AuthOtpSent(phone)`, `AuthNameRequired(user)`, `AuthRoleRequired(user)`, `AuthAuthenticated(user)`, `AuthUnauthenticated`, `AuthError(message)`

**Переходы:**

- **AppStarted:** AuthInitial → AuthLoading → AuthAuthenticated / AuthRoleRequired / AuthUnauthenticated
- **SendOtpEvent:** * → AuthLoading → AuthOtpSent / AuthError
- **VerifyOtpEvent:** * → AuthLoading → AuthNameRequired / AuthRoleRequired / AuthAuthenticated / AuthError
- **NameSubmittedEvent:** * → AuthLoading → AuthRoleRequired / AuthAuthenticated
- **RoleSelectedEvent:** * → AuthAuthenticated
- **LogoutEvent:** * → AuthLoading → AuthUnauthenticated

AuthBloc зарегистрирован как **синглтон** в GetIt: один экземпляр на всё время жизни приложения. GoRouter слушает его стрим для redirect-ов.

### 7.2 TakeQuizBloc — блок прохождения квиза

**Файл:** `lib/presentation/student/quiz_library/bloc/take_quiz_bloc.dart`

**События:** `StartSessionEvent`, `SetAnswerEvent`, `SubmitCurrentAnswerEvent`, `NextQuestionEvent`, `CompleteSessionEvent`, `TimerTickEvent`

**Состояния:** `TakeQuizInitial`, `TakeQuizLoading`, `TakeQuizInProgress` (quiz, session, currentIndex, currentAnswer, answerSubmitted, lastCorrect, lastExplanation, remainingSeconds), `TakeQuizCompleted(session)`, `TakeQuizError(message)`

**Флоу вопроса:** показ вопроса → выбор ответа → SubmitCurrentAnswerEvent → показ результата (зелёный/красный) → NextQuestionEvent → следующий вопрос.

**Таймер:** при `timeLimitMinutes` запускается `Timer.periodic(1 сек)`, при `remaining <= 0` — автоматический `CompleteSessionEvent`. Elapsed считается от `session.startedAt` (персистентно при возврате на экран).

### 7.3 Другие BLoC-и (обзорно)

- **StudentQuizBloc** — список квизов для студента, completed/inProgress сессии, поиск
- **TeacherQuizLibraryBloc** — квизы преподавателя (global + mine), лайки, удаление
- **CreateQuizBloc** — пошаговое создание квиза, вопросы, настройки (таймер, дедлайн, перемешивание), публикация (draft → active)

---

## 8. Навигация (GoRouter)

**Файл:** `lib/core/router/app_router.dart`

### 8.1 Маршруты

| Путь | Экран |
|------|--------|
| `/splash` | SplashScreen |
| `/welcome` | WelcomeScreen |
| `/phone` | PhoneInputScreen |
| `/otp?phone=...` | OtpScreen |
| `/name-input` | NameInputScreen |
| `/role-selection` | RoleSelectionScreen |
| `/teacher/home` | TeacherHomeScreen |
| `/student/home` | StudentHomeScreen |

### 8.2 Redirect — автоматическое перенаправление

GoRouter проверяет **AuthState** при каждой навигации:

| AuthState | Действие |
|-----------|----------|
| AuthInitial | `/splash` |
| AuthLoading | остаёмся на месте |
| AuthUnauthenticated | `/welcome` (если не на auth-экране) |
| AuthOtpSent | `/welcome` (если на /splash) |
| AuthNameRequired | `/name-input` |
| AuthRoleRequired | `/role-selection` |
| AuthAuthenticated | `/teacher/home` или `/student/home` по `user.role` |

### 8.3 RouterNotifier

```dart
class RouterNotifier extends ChangeNotifier {
  RouterNotifier() {
    _sub = getIt<AuthBloc>().stream.listen((_) => notifyListeners());
  }
}
```

RouterNotifier подписан на стрим AuthBloc. При новом состоянии → `notifyListeners()` → GoRouter вызывает `_redirect()` → при необходимости выполняется навигация. Навигация становится **реактивной** на основе состояния авторизации.

---

## 9. Хранилище данных (Hive)

Hive — быстрая NoSQL БД для Flutter без нативных зависимостей.

### 9.1 Три бокса

`HiveStorage.init()` открывает:

1. **`profile`** (Box<String>): `name`, `role`, `phone`, `user_name_+7...`
2. **`quizzes`** (Box<String>): `'1'`, `'2'`, … (JSON квизов), `__seeded`
3. **`sessions`** (Box<String>): `session-1`, `session-2`, … (JSON сессий)

### 9.2 ProfileStorage

**Файл:** `lib/core/storage/profile_storage.dart`

- `getName()` / `saveName(name)`, `getRole()` / `saveRole(role)`, `getPhone()` / `savePhone(phone)`
- `saveUserName(phone, name)`, `getUserName(phone)`
- `isLoggedIn` → `hasName && hasPhone`
- `clear()` — удаляет name, role, phone, **но сохраняет** записи `user_name_*` (имя по телефону переживает logout)

---

## 10. Полный флоу: от запуска до прохождения квиза

### 10.1 Запуск приложения (первый раз)

`main()` → HiveStorage.init() → initializeDependencies() → AuthBloc.add(AppStarted) → profileStorage.isLoggedIn == false → emit(AuthUnauthenticated) → GoRouter redirect на `/welcome` → WelcomeScreen.

### 10.2 Регистрация / Вход

- Welcome → `/phone` → SendOtpEvent → AuthOtpSent → переход на `/otp`
- VerifyOtpEvent(phone, "1234") → при первом входе AuthNameRequired → `/name-input` → NameSubmittedEvent → AuthRoleRequired → `/role-selection` → SetRoleUsecase + RoleSelectedEvent → AuthAuthenticated → redirect на `/student/home` или `/teacher/home`

### 10.3 Прохождение квиза

StudentHome → вкладка «Квизы» → StudentQuizBloc LoadQuizzesEvent → список квизов и сессий → карточки с бейджами «В процессе» / «Пройден» → QuizPreviewScreen → «Начать квиз» → TakeQuizScreen, StartSessionEvent → вопросы → SetAnswerEvent → SubmitCurrentAnswerEvent → NextQuestionEvent → CompleteSessionEvent → QuizResultScreen (процент, «Отличная работа!» / «Не сдавайтесь!») → «Вернуться к квизам».

### 10.4 Logout и повторный вход

LogoutEvent → logout() + profileStorage.clear() (user_name_* остаётся) → AuthUnauthenticated → `/welcome`. При повторном входе с тем же номером — getUserName(phone) вернёт имя → экран ввода имени пропускается.

---

## Краткая сводка

| Что | Технология | Где |
|-----|------------|-----|
| HTTP-клиент | Dio | `services/network/` |
| JWT хранение | FlutterSecureStorage | `services/token_storage/` |
| State management | flutter_bloc | `presentation/*/bloc/` |
| Навигация | GoRouter | `core/router/` |
| DI контейнер | GetIt | `core/di/` |
| Локальное хранение | Hive | `core/storage/` |
| Мок/Реальный | ApiConfig.useMock | `core/config/` |
| Авторизация | Doorman (OTP + JWT) | `services/doorman_api/` |

**Архитектурный принцип:** Presentation → Domain ← Data (стрелки = направление зависимостей). Domain не знает о Data и Presentation. Переключение мок ↔ реальный бэкенд — одна строка кода.

