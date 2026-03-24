Реализуй новую фичу согласно Clean Architecture Edium.

При реализации любой фичи следуй этому порядку:

**1. Domain (бизнес-логика)**
- `domain/entities/` — новый бизнес-объект если нужен
- `domain/repositories/` — интерфейс репозитория
- `domain/usecases/` — UseCase(ы) (один UC = одно действие)

**2. Data (реализации)**
- `data/models/` — JSON-модель с `fromJson`/`toJson`
- `data/datasources/` — **две реализации**: Mock/Hive (работает без бэкенда) и Impl (HTTP)
- `data/repositories/` — реализация интерфейса

**3. DI (injection.dart)**
- Зарегистрировать datasource (с проверкой `ApiConfig.useMock`)
- Зарегистрировать repository и usecase

**4. Presentation**
- `presentation/{student|teacher}/{feature}/bloc/` — events, states, bloc
- `presentation/{student|teacher}/{feature}/` — виджеты экранов

**5. Навигация**
- Добавить маршрут в `core/router/app_router.dart`

**6. Тесты**
- BLoC-тест для каждого события
- UseCase-тест

Сначала реализуй мок-версию (Hive), убедись что работает, потом Impl-версию.
