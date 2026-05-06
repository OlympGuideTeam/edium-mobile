# Student Dashboard — Design Spec

**Date:** 2026-05-06  
**Branch:** fix/ui-6  
**Author:** Исаев К.А.

---

## Overview

Добавить на главный экран студента (`student_home_screen.dart`) две секции с данными из `GET /sessions/dashboard`:
- **ПОСЛЕДНИЕ ОЦЕНКИ** — последние 5 завершённых тестов (некликабельные карточки)
- **ДОСТУПНЫЕ ТЕСТЫ** — тесты с активным дедлайном (кликабельные карточки → `/test/:sessionId`)

Кнопка «Начать обучение» (переход на таб Квизы) остаётся, но скрывается, когда `active_tests` не пустой.

---

## API

`GET /riddler/v1/sessions/dashboard`  
Security: Bearer JWT

```
Response 200:
  recent_grades[]:
    session_id: uuid
    quiz_template_id: uuid
    quiz_title: string
    attempt_id: uuid
    score: float|null   // 0–10
    status: grading | graded | completed | published
    finished_at: datetime|null

  active_tests[]:
    session_id: uuid
    quiz_template_id: uuid
    quiz_title: string
    total_time_limit_sec: int|null
    session_started_at: datetime|null
    session_finished_at: datetime|null   // дедлайн
    attempt_id: uuid|null
    attempt_status: in_progress|null
```

---

## Архитектура (Clean Architecture, по образцу AwaitingReview)

### Слой Domain

**Entity:** `lib/domain/entities/student_dashboard.dart`
```dart
class StudentDashboard {
  final List<RecentGradeItem> recentGrades;
  final List<ActiveTestItem> activeTests;
}

class RecentGradeItem {
  final String sessionId;
  final String quizTemplateId;
  final String quizTitle;
  final String attemptId;
  final double? score;           // 0–10
  final String status;           // grading | graded | completed | published
  final DateTime? finishedAt;
}

class ActiveTestItem {
  final String sessionId;
  final String quizTemplateId;
  final String quizTitle;
  final int? totalTimeLimitSec;
  final DateTime? sessionStartedAt;
  final DateTime? sessionFinishedAt;
  final String? attemptId;
  final String? attemptStatus;   // in_progress | null
}
```

**Repository interface:** `lib/domain/repositories/student_dashboard_repository.dart`
```dart
abstract class IStudentDashboardRepository {
  Future<StudentDashboard> getDashboard();
}
```

**UseCase:** `lib/domain/usecases/student_dashboard/get_student_dashboard_usecase.dart`
```dart
class GetStudentDashboardUsecase {
  GetStudentDashboardUsecase(this._repo);
  Future<StudentDashboard> call() => _repo.getDashboard();
}
```

### Слой Data

**Model:** `lib/data/models/student_dashboard_model.dart`  
`StudentDashboardModel`, `RecentGradeItemModel`, `ActiveTestItemModel` — `fromJson`, `toEntity()`.

**Datasource interface:** `lib/data/datasources/student_dashboard/student_dashboard_datasource.dart`

**Impl:** `lib/data/datasources/student_dashboard/student_dashboard_datasource_impl.dart`  
`GET riddler/v1/sessions/dashboard`, парсит ответ в модель.

**Mock:** `lib/data/datasources/student_dashboard/student_dashboard_datasource_mock.dart`  
3–4 фиктивных записи: 2–3 recent_grades (с разными score/status), 1–2 active_tests.

**Repository impl:** `lib/data/repositories/student_dashboard_repository_impl.dart`

### Слой Presentation

**Cubit:** `lib/presentation/student/home/bloc/student_dashboard_cubit.dart`

```dart
sealed class StudentDashboardState extends Equatable {}
class StudentDashboardInitial extends StudentDashboardState {}
class StudentDashboardLoading extends StudentDashboardState {}
class StudentDashboardLoaded extends StudentDashboardState {
  final StudentDashboard dashboard;
}
class StudentDashboardError extends StudentDashboardState {
  final String message;
}
```

```dart
class StudentDashboardCubit extends Cubit<StudentDashboardState> {
  StudentDashboardCubit(this._usecase) : super(StudentDashboardInitial());
  Future<void> load() async { ... }
}
```

### DI (injection.dart)

```dart
// datasource
getIt.registerLazySingleton<IStudentDashboardDatasource>(() =>
  ApiConfig.useMock
    ? StudentDashboardDatasourceMock()
    : StudentDashboardDatasourceImpl(getIt()));

// repository
getIt.registerLazySingleton<IStudentDashboardRepository>(() =>
  StudentDashboardRepositoryImpl(getIt()));

// usecase
getIt.registerFactory(() => GetStudentDashboardUsecase(getIt()));
```

---

## UI

### Структура _StudentDashboardPage

1. Добавить `BlocProvider` для `StudentDashboardCubit` в `StudentHomeScreen`.
2. Обернуть `SingleChildScrollView` в `RefreshIndicator` (как в teacher_home).
3. Вставить секции до кнопки «Начать обучение»:

```
УЧЕНИК badge
Edium / Привет, Иван

[Active Live Banner — если есть]

[_DashboardSection — BlocBuilder<StudentDashboardCubit>]
  если loaded && recent_grades.isNotEmpty:
    ПОСЛЕДНИЕ ОЦЕНКИ  sectionTag
    _RecentGradeCard × N (до 5)
    SizedBox(height: 14)
  если loaded && active_tests.isNotEmpty:
    ДОСТУПНЫЕ ТЕСТЫ  sectionTag
    _ActiveTestTile × N
    SizedBox(height: 24)

[Кнопка «Начать обучение» — только если active_tests пустой или ещё не загружен]
```

### _RecentGradeCard

- Контейнер в стиле `_AwaitingReviewCard`: `border: mono150`, `radiusLg`, padding 16.
- Некликабельный (нет `InkWell`).
- Строка: quiz_title (bold) + score справа.
  - `score != null` → `"${score.toStringAsFixed(1)}"` (mono900)
  - `status == grading` → `"Проверяется"` (mono400)
  - `status == graded` → `"Будет позже"` (mono400)
  - иначе → `"—"` (mono400)

### _ActiveTestTile

- Стиль `_QuickActionTile`: `border: mono150`, `radiusLg`, иконка 44×44 mono50 bg + `CupertinoIcons.doc_text`.
- Кликабельный: `context.push('/test/${item.sessionId}')`.
- Основной текст: `quiz_title`.
- Подзаголовок:
  - `attempt_status == in_progress` → `"В процессе"`
  - `session_finished_at != null` → `"Дедлайн: ${_fmt.format(finishedAt)}"` (DateFormat `d MMM`, ru)
  - иначе → `"Доступен"`
- Иконка-стрелка `chevron_right` справа.

### Состояния загрузки

- `StudentDashboardLoading` / `StudentDashboardInitial` → не отображать секции (skeleton не нужен, секции просто скрыты).
- `StudentDashboardError` → не отображать секции (тихо, без сообщения об ошибке на главном экране).

---

## Навигация

Тап на `_ActiveTestTile`:
```dart
context.push('/test/${item.sessionId}');
```
(без `extra.courseItem` — `TestPreviewScreen` обработает null и загрузит мета через datasource)

---

## Файлы к созданию / изменению

### Новые файлы
| Файл | Описание |
|------|----------|
| `domain/entities/student_dashboard.dart` | Entity |
| `domain/repositories/student_dashboard_repository.dart` | Interface |
| `domain/usecases/student_dashboard/get_student_dashboard_usecase.dart` | UseCase |
| `data/models/student_dashboard_model.dart` | JSON-модели |
| `data/datasources/student_dashboard/student_dashboard_datasource.dart` | Interface |
| `data/datasources/student_dashboard/student_dashboard_datasource_impl.dart` | HTTP impl |
| `data/datasources/student_dashboard/student_dashboard_datasource_mock.dart` | Mock |
| `data/repositories/student_dashboard_repository_impl.dart` | Repo impl |
| `presentation/student/home/bloc/student_dashboard_cubit.dart` | Cubit + States |

### Изменённые файлы
| Файл | Что меняется |
|------|-------------|
| `core/di/injection.dart` | Регистрация datasource, repo, usecase |
| `presentation/student/home/student_home_screen.dart` | BlocProvider + секции + RefreshIndicator + условная кнопка |

---

## Edge cases

- `recent_grades` пустой → секция «ПОСЛЕДНИЕ ОЦЕНКИ» скрыта.
- `active_tests` пустой → секция «ДОСТУПНЫЕ ТЕСТЫ» скрыта, кнопка «Начать обучение» видна.
- `active_tests` непустой → кнопка «Начать обучение» скрыта.
- API вернул ошибку → обе секции скрыты, кнопка видна.
