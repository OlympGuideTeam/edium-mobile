# CreateCourse Screen — Design Spec

## Overview

Экран создания курса. Учитель указывает название курса и добавляет модули (только название).
Переход из `ClassDetailScreen` по кнопке "Создать курс". Без секции "Привязать к классу".

## UI

Дизайн-система: монохромная (auth-стиль). `Colors.white` фон, `AppColors.mono*`, `AppTextStyles.screen*` / `field*` / `primaryButton`.

### Layout

```
SafeArea + Padding(screenPaddingH=24)
│
├─ Back button (← arrow_back_ios_new, mono400) + "Новый курс" (screenTitle)
│
├─ SizedBox(28)
│
├─ "Название курса" (fieldLabel)
├─ SizedBox(8)
├─ TextField (inputH=52, radiusMd=12, border mono250, text fieldText, hint fieldHint)
│   hint: "Алгебра. Базовый курс"
│
├─ SizedBox(24)
│
├─ Row: "Модули (N)" (fieldLabel) — Spacer — "+ Добавить" (fieldLabel, mono700, GestureDetector)
├─ SizedBox(12)
│
├─ ListView модулей:
│   ├─ _ModuleCard: "Модуль 1 · Название" (fieldText)
│   │   drag handle (::) слева, кнопка удаления (⋮ → popup или иконка ✕) справа
│   │   border: mono250, radiusLg=14
│   │   При тапе — inline-редактирование названия
│   └─ ...
│
├─ "+ Добавить модуль" кнопка (dashed border, mono300, radiusLg=14)
│   При нажатии — добавляет модуль с пустым названием и фокусом на TextField
│
├─ Spacer
│
├─ "Сохранить курс" button (mono900, white text, buttonH=52, radiusLg=14)
│   disabled (mono200) если название пустое
│   isLoading → CircularProgressIndicator
│
└─ SizedBox(24)
```

### Поведение

- **Добавить модуль**: оба элемента ("+ Добавить" в заголовке и кнопка внизу) добавляют пустой модуль
- **Редактирование модуля**: тап на карточку → inline TextField для изменения названия
- **Удаление модуля**: иконка ✕ справа или свайп
- **Drag & drop**: пока не реализуем (handle `::` визуально есть, но не функционален на первой итерации)
- **Валидация**: кнопка "Сохранить" disabled, если название курса пустое. Пустые модули (без названия) отбрасываются при отправке.

## Архитектура

### Новые файлы

```
lib/
├── domain/
│   ├── repositories/
│   │   └── course_repository.dart              # ICourseRepository (createCourse, createModule)
│   └── usecases/
│       └── course/
│           ├── create_course_usecase.dart       # POST /caesar/v1/courses
│           └── create_module_usecase.dart       # POST /caesar/v1/courses/{id}/modules
│
├── data/
│   ├── datasources/
│   │   └── course/
│   │       ├── course_datasource.dart           # ICourseDatasource interface
│   │       ├── course_datasource_impl.dart      # HTTP implementation
│   │       └── course_datasource_mock.dart      # Mock implementation
│   └── repositories/
│       └── course_repository_impl.dart          # CourseRepositoryImpl
│
├── presentation/
│   └── teacher/
│       └── create_course/
│           ├── create_course_screen.dart         # UI
│           └── bloc/
│               ├── create_course_bloc.dart
│               ├── create_course_event.dart
│               └── create_course_state.dart
│
└── core/
    └── router/app_router.dart                   # +route /course/create?classId=...
```

### Изменения в существующих файлах

1. **`core/router/app_router.dart`** — добавить route `/course/create`
2. **`core/di/injection.dart`** — зарегистрировать datasource, repository, usecases
3. **`presentation/class_detail/class_detail_screen.dart`** — навигация из TODO на строке ~591

### Domain

```dart
// course_repository.dart
abstract class ICourseRepository {
  Future<String> createCourse({required String title, required String classId});
  Future<void> createModule({required String courseId, required String title});
}
```

```dart
// create_course_usecase.dart
class CreateCourseUsecase {
  final ICourseRepository _repository;
  CreateCourseUsecase(this._repository);
  Future<String> call({required String title, required String classId}) =>
      _repository.createCourse(title: title, classId: classId);
}

// create_module_usecase.dart
class CreateModuleUsecase {
  final ICourseRepository _repository;
  CreateModuleUsecase(this._repository);
  Future<void> call({required String courseId, required String title}) =>
      _repository.createModule(courseId: courseId, title: title);
}
```

### Data

```dart
// course_datasource.dart
abstract class ICourseDatasource {
  Future<String> createCourse({required String title, required String classId});
  Future<void> createModule({required String courseId, required String title});
}

// course_datasource_impl.dart — BaseApiService
// POST caesar/v1/courses → {title, class_id} → {id: "..."}
// POST caesar/v1/courses/{courseId}/modules → {title} → void

// course_datasource_mock.dart
// createCourse → генерируем id с задержкой 300ms
// createModule → no-op с задержкой 200ms
```

### BLoC

**State:**
```dart
class CreateCourseState extends Equatable {
  final String title;
  final List<String> modules;        // список названий модулей
  final bool isSubmitting;
  final String? error;
  final bool success;

  bool get canSubmit => title.trim().isNotEmpty && !isSubmitting;
}
```

**Events:**
```dart
UpdateCourseTitleEvent(String title)
AddModuleEvent()                        // добавляет пустую строку
UpdateModuleEvent(int index, String title)
RemoveModuleEvent(int index)
SubmitCourseEvent(String classId)       // classId из query param
```

**Submit flow:**
```dart
Future<void> _onSubmit(SubmitCourseEvent event, Emitter emit) async {
  emit(state.copyWith(isSubmitting: true));
  try {
    // 1. Создаём курс
    final courseId = await _createCourse(title: state.title, classId: event.classId);

    // 2. Фильтруем пустые модули, создаём параллельно
    final validModules = state.modules.where((m) => m.trim().isNotEmpty);
    await Future.wait(
      validModules.map((m) => _createModule(courseId: courseId, title: m)),
    );

    emit(state.copyWith(isSubmitting: false, success: true));
  } catch (e) {
    emit(state.copyWith(isSubmitting: false, error: e.toString()));
  }
}
```

### Routing

```dart
// app_router.dart
GoRoute(
  path: '/course/create',
  builder: (_, state) {
    final classId = state.uri.queryParameters['classId'] ?? '';
    return CreateCourseScreen(classId: classId);
  },
),
```

### Navigation from ClassDetail

```dart
// class_detail_screen.dart, line ~591
onPressed: () {
  context.push('/course/create?classId=${widget.classId}');
},
```

### DI Registration (injection.dart)

```dart
// Datasource (inside mock/impl conditional)
// Mock:
getIt.registerLazySingleton<ICourseDatasource>(() => CourseDatasourceMock());
// Impl:
getIt.registerLazySingleton<ICourseDatasource>(() => CourseDatasourceImpl(getIt<DioHandler>().dio));

// Repository
getIt.registerLazySingleton<ICourseRepository>(() => CourseRepositoryImpl(getIt()));

// Usecases
getIt.registerLazySingleton(() => CreateCourseUsecase(getIt()));
getIt.registerLazySingleton(() => CreateModuleUsecase(getIt()));
```

## API Endpoints

| Method | Path | Body | Response |
|--------|------|------|----------|
| POST | `caesar/v1/courses` | `{title, class_id}` | `{id: "course-id"}` |
| POST | `caesar/v1/courses/{courseId}/modules` | `{title}` | 200 OK |

## Edge Cases

- Название курса пустое → кнопка disabled
- Модули без названия → отбрасываются при отправке
- Ошибка создания курса → `EdiumNotification.error`, модули не создаются
- Ошибка при создании одного модуля → остальные всё равно создаются (Future.wait), ошибка показывается
- Успех → `context.pop()`, ClassDetailScreen перезагружает данные
