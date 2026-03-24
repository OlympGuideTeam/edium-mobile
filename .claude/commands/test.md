Напиши тесты для указанного BLoC/UseCase/Repository.

**BLoC-тесты (`bloc_test` пакет):**
```dart
blocTest<MyBloc, MyState>(
  'описание на русском',
  build: () => MyBloc(useCase: mockUseCase),
  act: (bloc) => bloc.add(MyEvent()),
  expect: () => [MyLoadingState(), MySuccessState(...)],
);
```

- Мокай UseCase через `mockito` или `mocktail`
- Покрой: успех, ошибку сети, пустой результат
- Называй тесты на русском: `'загружает список квизов при успешном запросе'`

**UseCase-тесты:**
- Мокай Repository-интерфейс
- Проверяй что UseCase правильно преобразует данные
- Тестируй граничные случаи (пустой список, null-поля)

**Widget-тесты:**
- Используй `flutter_test` + `bloc_test` с `MockBloc`
- Проверяй что нужные виджеты отображаются для каждого State
- `tester.pumpWidget(BlocProvider(create: ..., child: MyWidget()))`

**Мок-система в тестах:**
- В тестах использовать реальные мок-реализации (Hive) или фиктивные объекты
- Не тестировать `ApiConfig.useMock` — это конфигурация, не логика

Запусти после написания: `flutter test`
