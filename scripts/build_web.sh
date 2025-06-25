#!/bin/bash

# Flutter Web Build Script без tree shaking
# Использование: ./scripts/build_web.sh [debug|release]

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

# Определяем режим сборки
BUILD_MODE=${1:-release}

log "🚀 Начинаем сборку Flutter Web в режиме: $BUILD_MODE"

# Проверяем Flutter
if ! command -v flutter &> /dev/null; then
    error "Flutter не найден в PATH"
    exit 1
fi

log "📋 Версия Flutter:"
flutter --version

# Очистка
log "🧹 Очистка проекта..."
flutter clean

# Получение зависимостей
log "📦 Получение зависимостей..."
flutter pub get

# Генерация кода если нужно
if [ -f "pubspec.yaml" ] && grep -q "build_runner" pubspec.yaml; then
    log "🔧 Генерация кода..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
fi

# Сборка в зависимости от режима
if [ "$BUILD_MODE" = "debug" ]; then
    log "🔨 Сборка DEBUG версии без tree shaking..."
    flutter build web \
        --debug \
        --source-maps \
        --no-tree-shake-icons \
        --verbose
else
    log "🔨 Сборка RELEASE версии без tree shaking..."
    flutter build web \
        --release \
        -O 2 \
        --no-source-maps \
        --no-tree-shake-icons \
        --verbose
fi

# Проверяем результат
if [ $? -eq 0 ]; then
    success "✅ Сборка завершена успешно!"
    log "📁 Результат находится в: build/web/"
    
    # Показываем размер сборки
    if [ -d "build/web" ]; then
        log "📊 Размер сборки:"
        du -sh build/web/
        
        log "📊 Главные файлы:"
        ls -lah build/web/ | head -10
    fi
    
    # Инструкции для локального тестирования
    log "🌐 Для локального тестирования:"
    echo "  cd build/web && python3 -m http.server 8080"
    echo "  Затем откройте: http://localhost:8080"
    
else
    error "❌ Сборка завершилась с ошибкой!"
    exit 1
fi 