#!/bin/bash

# Проверяем, установлен ли Flutter
if ! command -v flutter &> /dev/null; then
    echo "Flutter не установлен. Пожалуйста, установите Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Проверяем, установлен ли Node.js и npm
if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
    echo "Node.js или npm не установлены. Пожалуйста, установите Node.js: https://nodejs.org/"
    exit 1
fi

# Проверяем, установлен ли Firebase CLI
if ! command -v firebase &> /dev/null; then
    echo "Установка Firebase CLI..."
    npm install -g firebase-tools
fi

# Устанавливаем зависимости Flutter
echo "Установка зависимостей Flutter..."
flutter pub get

# Генерируем код
echo "Генерация кода..."
flutter pub run build_runner build --delete-conflicting-outputs

# Собираем веб-версию БЕЗ tree shaking (решает проблемы с иконками)
echo "Сборка веб-версии без tree shaking..."
flutter build web --no-tree-shake-icons

# Проверяем, залогинен ли пользователь в Firebase
if ! firebase login:list &> /dev/null; then
    echo "Требуется вход в Firebase..."
    firebase login
fi

# Деплоим на Firebase Hosting
echo "Деплой на Firebase Hosting..."
firebase deploy --only hosting

echo "Установка завершена!"
echo "URL вашего приложения будет показан после деплоя."
echo ""
echo "💡 Доступные команды для сборки:"
echo "  ./scripts/build_web.sh           - сборка без tree shaking"
echo "  ./scripts/build_web.sh debug     - debug сборка"
echo "  ./scripts/deploy_firebase.sh     - деплой в Firebase"
echo ""
echo "🔧 Эти скрипты автоматически отключают tree shaking для стабильной сборки." 