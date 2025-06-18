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

# Собираем веб-версию
echo "Сборка веб-версии..."
flutter build web

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