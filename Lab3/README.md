# Лабораторная 3 — RunBaza

Навигация, формы и валидация в существующем Flutter-проекте **Lab2/run_baza**.
Платформа демонстрации — iOS. Исходная Л2 сохранена в `lab/2-runbaza-ui`;
работа Л3 ведётся в `lab/3-navigation-forms` и включается в `main` через PR.

## Запуск

```sh
cd Lab2/run_baza
flutter pub get --enforce-lockfile
open -a Simulator
flutter devices
flutter run -d <simulator-id>
```

Для Xcode откройте `Lab2/run_baza/ios/Runner.xcworkspace`, выберите Runner и
симулятор iPhone. Код UI находится в `Lab2/run_baza/lib`.

Вход принимает любой синтаксически корректный e-mail и пароль от 6 символов,
например `runner@example.com` / `runbaza26`. Это локальная проверка формы,
без аккаунта, сервера и сохранения пароля.

## Реализовано

- `go_router`, `MaterialApp.router`, маршруты по строковому ID.
- Пять независимых вкладок `StatefulShellRoute.indexedStack` и `NavigationBar`.
- Поиск по названию, городу и дистанциям; фильтр страны.
- Формы входа, участия в забеге, поездки водителя, запроса пассажира и профиля.
- `Form`, `GlobalKey<FormState>`, validators, controllers с `dispose`, фильтры ввода.
- `SnackBar` после проверки; `AlertDialog<bool>` перед выходом.
- Обработка неизвестных путей, ID и дистанций.
- Светлая и тёмная темы, иллюстрации городов и анимации из Л2.

Данные фиксированы. Отправка формы не создаёт запись, не бронирует место и
не отправляет запрос в сеть. Персистентность и реальная авторизация — следующий этап.

## Проверки

```sh
cd Lab2/run_baza
flutter analyze --fatal-infos
flutter test
flutter build ios --simulator --debug --no-codesign
flutter drive --driver=test_driver/lab3_driver.dart \
  --target=integration_test/lab3_test.dart -d <simulator-id>
```

100 unit/widget-тестов: валидация, стеки и состояние вкладок, ошибочные адреса,
диалоги, анимации, ширины 320–430, обе темы, масштаб текста до 160%.
Интеграционный сценарий на iOS сохраняет реальные снимки в `Lab3/evidence/ios`.

## Документы

- [Отчёт PDF](Reports/PAM_L3_HamuevOleg.pdf)
- [Редактируемый отчёт Word](Reports/PAM_L3_HamuevOleg.docx)
- [Руководство к защите PDF](Reports/PAM_L3_Guide_HamuevOleg.pdf)

В отчёте: маршруты, полный router.dart, снимки всех веток, разные ID, ошибки
форм, правила проверки, SnackBar, подтверждение выхода и история коммитов.
В руководстве: запуск на Mac, последовательность показа, объяснение кода и вопросы.

Референс обновлён по Samepace (main `438e942`, 11.10.2026). UI написан на Flutter;
Vue/Worker-код и серверные конфигурации референса не включены в этот репозиторий.
