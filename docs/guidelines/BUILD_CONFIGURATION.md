# Конфигурация сборки Flutter Web без Tree Shaking

## Проблема

Flutter по умолчанию использует tree shaking при сборке веб-приложений, что может вызывать проблемы:
- ❌ Проблемы с отображением иконок
- ❌ Зависание при сборке на этапе tree shaking
- ❌ Ошибки с некоторыми пакетами

## Решение

Отключение tree shaking с помощью флага `--no-tree-shake-icons`.

## Доступные команды

### 🔧 Сборка
```bash
# Debug сборка без tree shaking
./scripts/build_web.sh debug

# Release сборка без tree shaking (по умолчанию)
./scripts/build_web.sh
./scripts/build_web.sh release
```

### 🚀 Деплой
```bash
# Полный деплой в Firebase с отключенным tree shaking
./scripts/deploy_firebase.sh
```

### 📱 Быстрая установка
```bash
# Автоматическая установка и деплой
./setup.sh
```

## Технические детали

### Флаги сборки

**Debug режим:**
```bash
flutter build web \
    --debug \
    --source-maps \
    --no-tree-shake-icons \
    --verbose
```

**Release режим:**
```bash
flutter build web \
    --release \
    -O 2 \
    --no-source-maps \
    --no-tree-shake-icons \
    --verbose
```

### Объяснение флагов

| Флаг | Описание |
|------|----------|
| `--no-tree-shake-icons` | **Основной флаг** - отключает tree shaking иконок |
| `--debug`/`--release` | Режим сборки |
| `-O 2` | Уровень оптимизации (1-4) для release |
| `--source-maps` | Включает source maps для отладки |
| `--no-source-maps` | Отключает source maps для production |
| `--verbose` | Подробный вывод для диагностики |

## Тестирование

После сборки можно протестировать локально:

```bash
cd build/web
python3 -m http.server 8080
# Откройте http://localhost:8080
```

## Альтернативные подходы

### 1. Временное отключение через командную строку
```bash
flutter build web --no-tree-shake-icons
```

### 2. Через переменные окружения (экспериментально)
```bash
export FLUTTER_WEB_TREE_SHAKE_ICONS=false
flutter build web
```

## Мониторинг размера

Отключение tree shaking может увеличить размер приложения. Мониторьте:

```bash
# Размер сборки
du -sh build/web/

# Основные файлы
ls -lah build/web/ | head -10
```

## Troubleshooting

### Если сборка всё ещё зависает:
1. Попробуйте очистить кэш: `flutter clean`
2. Обновите зависимости: `flutter pub get`
3. Регенерируйте код: `dart run build_runner build --delete-conflicting-outputs`

### Если размер приложения слишком большой:
1. Проверьте неиспользуемые зависимости в `pubspec.yaml`
2. Используйте анализ бандла: `flutter build web --dump-info`
3. Рассмотрите частичное включение tree shaking для конкретных пакетов

## Память

Эта конфигурация решает проблему с зависанием сборки на этапе tree shaking, которая часто возникает в проектах Flutter Web с большим количеством зависимостей или иконок. 