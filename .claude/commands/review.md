Проведи code review указанного Flutter-файла/фичи.

Проверь:

**Clean Architecture:**
- Domain-слой не импортирует Flutter, Dio, Hive — только чистый Dart
- Data-слой реализует интерфейсы из Domain, не наследует от Widget
- Presentation-слой не обращается напрямую к datasource или repository

**BLoC:**
- BLoC не вызывает другой BLoC напрямую
- State immutable — используется copyWith или новый объект
- События именованы как `{Глагол}Event`: `LoadQuizzesEvent`, `SubmitAnswerEvent`
- BLoC-тест покрывает каждое событие

**Мок-система:**
- Если добавлен новый datasource — есть обе реализации (Mock/Hive и Impl)
- Регистрация в `injection.dart` учитывает `ApiConfig.useMock`

**UI:**
- Нет бизнес-логики в Widget (только `context.read<>().add()`)
- Shared-компоненты переиспользуют `presentation/shared/widgets/`
- Нет магических строк и цветов напрямую — только из `app_colors.dart` и `app_text_styles.dart`

**Общее:**
- Комментарии на русском языке
- Нет `print()` в продовом коде (только `debugPrint`)

Укажи конкретные проблемы с ссылками на строки.
