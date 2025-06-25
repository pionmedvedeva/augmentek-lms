#!/bin/bash

# Быстрый деплой без лишних шагов
# Использование: ./scripts/quick_deploy.sh

echo "🚀 Быстрый деплой в Firebase..."

# Проверяем Firebase CLI
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI не найден"
    exit 1
fi

# Сборка БЕЗ очистки и генерации - только если нужно
echo "🔨 Сборка Flutter Web без tree shaking..."
flutter build web --release --no-tree-shake-icons

if [ $? -ne 0 ]; then
    echo "❌ Ошибка сборки"
    exit 1
fi

echo "✅ Сборка завершена"

# Деплой сразу на хостинг
echo "🌐 Деплой на Firebase Hosting..."
firebase deploy --only hosting

if [ $? -eq 0 ]; then
    echo "🎉 Деплой завершен!"
    echo "🔗 https://augmentek-lms.web.app"
else
    echo "❌ Ошибка деплоя"
    exit 1
fi 