#!/bin/bash

# Firebase Deploy Script с отключенным tree shaking
# Использование: ./scripts/deploy_firebase.sh

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция для логирования
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

log "🚀 Начинаем деплой в Firebase..."

# Проверяем необходимые инструменты
if ! command -v flutter &> /dev/null; then
    error "Flutter не найден в PATH"
    exit 1
fi

if ! command -v firebase &> /dev/null; then
    error "Firebase CLI не найден в PATH"
    log "Установите: npm install -g firebase-tools"
    exit 1
fi

# Проверяем авторизацию Firebase
log "🔐 Проверяем авторизацию Firebase..."
if ! firebase projects:list &> /dev/null; then
    error "Не авторизованы в Firebase CLI"
    log "Выполните: firebase login"
    exit 1
fi

# Сборка приложения
log "🔨 Сборка Flutter Web без tree shaking..."
flutter clean
flutter pub get

# Генерация кода если нужно
if [ -f "pubspec.yaml" ] && grep -q "build_runner" pubspec.yaml; then
    log "🔧 Генерация кода..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
fi

# Сборка release версии без tree shaking
flutter build web \
    --release \
    -O 2 \
    --no-tree-shake-icons

if [ $? -ne 0 ]; then
    error "❌ Ошибка при сборке Flutter приложения"
    exit 1
fi

success "✅ Flutter приложение собрано успешно"

# Деплой Functions (если нужно)
if [ -d "functions" ]; then
    log "☁️ Деплой Firebase Functions..."
    cd functions
    npm install
    cd ..
    firebase deploy --only functions
    
    if [ $? -ne 0 ]; then
        warning "⚠️ Ошибка при деплое Functions, но продолжаем..."
    else
        success "✅ Functions задеплоены"
    fi
fi

# Деплой Hosting
log "🌐 Деплой Firebase Hosting..."
firebase deploy --only hosting

if [ $? -eq 0 ]; then
    success "🎉 Деплой завершен успешно!"
    
    # Получаем URL приложения
    PROJECT_ID=$(firebase use | grep -o 'Now using project [^[:space:]]*' | cut -d ' ' -f 4)
    if [ ! -z "$PROJECT_ID" ]; then
        log "🔗 Приложение доступно по адресу:"
        echo "   https://$PROJECT_ID.web.app"
        echo "   https://$PROJECT_ID.firebaseapp.com"
    fi
    
    log "📊 Проверьте статус в Firebase Console:"
    echo "   https://console.firebase.google.com/project/$PROJECT_ID/hosting"
    
else
    error "❌ Ошибка при деплое в Firebase"
    exit 1
fi 