# Документация экранов LMS Augmentek

**Обновлено:** 26 июня 2024  
**Статус:** Все экраны реализованы ✅  
**URL:** https://augmentek-lms.web.app

## Архитектура и навигация

### Система табов (BottomNavigationBar)
- **"За парту"** (таб 0) - главная страница студента для всех пользователей
- **"В коридор"** (таб 1) - список курсов для всех пользователей  
- **"Учительская"** (таб 2) - админ панель только для администраторов

### AppBar
- **Заголовок:** "Augmentek"
- **Действие:** Аватар пользователя (клик → модальное окно профиля)
- **Debug кнопка:** Плавающая справа для отладки

## Цветовая схема (из AppTheme)

```dart
primaryBlue = Color(0xFF4A90B8)        // Основной синий
darkBlue = Color(0xFF2C5F7C)           // Темно-синий  
lightBlue = Color(0xFF87CEEB)          // Светло-голубой
peachBackground = Color(0xFFF5E6D3)    // Персиковый фон
warmWhite = Color(0xFFFFFFFE)          // Теплый белый
accentOrange = Color(0xFFE8A87C)       // Акцентный оранжевый
```

- **Фон приложения:** Персиковый (`peachBackground`)
- **AppBar:** Синий (`primaryBlue`) с белым текстом
- **Карточки:** Теплый белый (`warmWhite`)

## Полная структура экранов

### 1. 🔐 Экран входа (LoginScreen)
**Компонент:** `lib/features/auth/screens/login_screen.dart`

- Автоматическая аутентификация через Telegram WebApp
- Loading состояние с индикатором
- Переход на главную после успешной аутентификации

### 2. 🏠 Главная страница (HomeScreen)
**Компонент:** `lib/features/home/presentation/screens/home_screen.dart`

**Структура:**
```
AppBar("Augmentek") + аватар пользователя
IndexedStack с экранами (сохранение состояния)
BottomNavigationBar с 2-3 табами
```

**Табы навигации:**
- **Таб 0:** "За парту" (Icons.home) → StudentDashboard
- **Таб 1:** "В коридор" (Icons.school) → CourseListScreen  
- **Таб 2:** "Учительская" (Icons.admin_panel_settings) → AdminDashboard (только для админов)

### 3. 👨‍🎓 Панель студента (StudentDashboard) - Таб "За парту"
**Компонент:** `lib/features/student/presentation/screens/student_dashboard.dart`

**Welcome Card с градиентом:**
- **Цвета:** `primaryBlue` → `lightBlue`
- **Текст приветствия:** "Добро пожаловать!"
- **Имя пользователя:** `firstName + lastName`
- **Бейдж "Администратор"** (`accentOrange`) для админов
- **Нижний текст:** "Продолжим разбираться?"

**Быстрые действия (3 карточки):**
- **"Следующий урок"** (`primaryBlue`, Icons.play_arrow)
- **"Курсы"** (`lightBlue`, Icons.school) → EnrolledCoursesScreen
- **"Домашки"** (`accentOrange`, Icons.assignment) → StudentHomeworkScreen

**Секция "Продолжить обучение":**
- Если нет курсов: **"Ты нигде не учишься. Выгляни в коридор, чтобы найти что-нибудь интересное!"**
- Если есть курсы: отображается активный курс

### 4. 📚 Список курсов (CourseListScreen) - Таб "В коридор"
**Компонент:** `lib/features/course/presentation/screens/course_list_screen.dart`

- Поиск курсов в реальном времени
- Компактные карточки курсов
- Pull-to-refresh обновление
- Для студентов: только активные курсы
- Переход на детали курса по клику

### 5. 🎓 Мои курсы (EnrolledCoursesScreen)
**Компонент:** `lib/features/student/presentation/screens/enrolled_courses_screen.dart`

**AppBar:** "Мои курсы"
**Пустое состояние:** "Ты нигде не учишься. Выгляни в коридор, чтобы найти что-нибудь интересное!"
**Список:** Карточки записанных курсов
**Переход:** StudentCourseViewScreen по клику на курс

### 6. 📖 Просмотр курса студентом (StudentCourseViewScreen)
**Компонент:** `lib/features/student/presentation/screens/student_course_view_screen.dart`

**Структура:**
- **Обложка курса** (120px высота) с fallback градиентом
- **Название и описание курса**
- **Статистика:** Бейджи "Разделы" (синий) и "Уроки" (зеленый)
- **"Уроки курса"** (Icons.article) - уроки без раздела
- **"Программа курса"** (Icons.folder) - уроки в разделах
- **Пустое состояние:** "Курс пока пуст" / "Материалы курса скоро появятся"

### 7. 📝 Просмотр урока (LessonViewScreen)
**Компонент:** `lib/features/course/presentation/screens/lesson_view_screen.dart`

**AppBar:** Название урока, цвет `primaryBlue`
**Элементы:**
- Заголовок и описание урока
- Бейдж длительности (синий): "Длительность: X мин"
- **"Материал урока"** - текстовый контент в сером блоке
- **"Видео урока"** - YouTube плеер с `progressIndicatorColor: Colors.deepPurple`
- **Домашнее задание** с формой отправки и статусами

### 8. 📝 Мои домашние задания (StudentHomeworkScreen)
**Компонент:** `lib/features/student/presentation/screens/student_homework_screen.dart`

**AppBar:** "Мои домашние задания", цвет `primaryBlue`
**Пустое состояние:** "У вас пока нет домашних заданий"
**Карточки заданий:** 
- Статусы с цветными бейджами (оранжевый/зеленый/красный)
- История отправки и проверки
- Комментарии преподавателя

### 9. 👨‍💼 Админ панель (AdminDashboard) - Таб "Учительская"
**Компонент:** `lib/features/admin/presentation/screens/admin_dashboard.dart`

**AppBar:** 
- **Заголовок:** "Учительская"
- **Цвет:** `primaryBlue`
- **TabBar с 3 табами:**
  - **"Курсы"** (Icons.school) → CourseManagementScreen
  - **"Пользователи"** (Icons.people) → UserListScreen  
  - **"Домашки"** (Icons.assignment) → HomeworkReviewScreen

**Проверка доступа:**
- Если не админ: "Доступ запрещен" / "У вас нет прав доступа в учительскую"

### 10. 📋 Управление курсами (CourseManagementScreen)
**Компонент:** `lib/features/admin/presentation/screens/course_management_screen.dart`

**Пустое состояние:** "Курсы отсутствуют" / "Создайте первый курс для начала работы"
**Функции:**
- Создание курса через FAB "+"
- Редактирование курсов
- Удаление с подтверждением
- Переключение статуса активности
- Переход к управлению содержимым курса

### 11. 👥 Список пользователей (UserListScreen)
**Компонент:** `lib/features/admin/presentation/screens/user_list_screen.dart`

**Статистика:** "Всего пользователей: X" в синем блоке
**Пустое состояние:** "Пользователи отсутствуют" / "Пользователи появятся после регистрации"
**Карточки пользователей:**
- Аватар с fallback на инициалы
- Имя, username, ID
- Бейдж "Администратор" (`accentOrange`)
- Информация о курсах и активности

**Детальный профиль (Modal):**
- DraggableScrollableSheet при клике на пользователя
- **"Учебная информация"** (цвет `primaryBlue`)
- Записанные курсы, прогресс, активность
- "Не записан ни на один курс" для пользователей без курсов

### 12. ✅ Проверка домашних заданий (HomeworkReviewScreen)
**Компонент:** `lib/features/admin/presentation/screens/homework_review_screen.dart`

**AppBar:** "Проверка домашних заданий", цвет `primaryBlue`
**Пустое состояние:** "Нет домашних заданий для проверки"
**Навигация:** Стрелки влево/вправо между заданиями
**Секции:**
- **"Задание:"** (оранжевый заголовок) в оранжевом блоке
- **"Ответ студента:"** (фиолетовый заголовок) в фиолетовом блоке
- Поле комментария
- Кнопки: **"На доработку"** (оранжевая) и **"Зачет"** (зеленая)

### 13. 🛠️ Управление содержимым курса (CourseContentScreen)
**Компонент:** `lib/features/course/presentation/screens/course_content_screen.dart`

**Функции:**
- Создание секций и уроков
- FAB для добавления элементов
- Редактирование уроков
- Кнопка "Изменить порядок" для drag&drop
- **Пустое состояние:** "Курс пока пуст" / "Добавьте разделы и уроки для структурированного обучения"

### 14. ✏️ Редактирование урока (LessonEditScreen)
**Компонент:** `lib/features/course/presentation/screens/lesson_edit_screen.dart`

**Поля формы:**
- Название урока, описание, длительность
- **"Содержание урока"** - большое текстовое поле
- **"Видео урока"** - URL YouTube с живым превью
- **"Домашнее задание"** - задание и правильный ответ
- YouTube плеер с `progressIndicatorColor: Colors.deepPurple`

### 15. 🔄 Изменение порядка (CourseContentReorderableScreen)
**Компонент:** `lib/features/course/presentation/screens/course_content_reorderable_screen.dart`

- Drag & drop для секций и уроков
- Сохранение порядка в Firestore
- Индикаторы перетаскивания

## Модальные окна и диалоги

### Профиль пользователя (AppBar аватар)
**В компоненте:** HomeScreen
- **Заголовок:** "Профиль пользователя"
- Большой аватар (40px radius)
- Имя, username, статус админа
- Telegram ID в сером блоке

### Создание курса (CreateCourseDialog)
**Компонент:** `lib/features/admin/presentation/widgets/create_course_dialog.dart`
- Поля названия, описания, обложки
- URL input для изображений  
- Переключатель активности
- Предпросмотр обложки

## Общие компоненты

### UserAvatar Widget
**Компонент:** `lib/shared/widgets/user_avatar.dart`
- Обработка SVG аватаров Telegram с CORS fallback
- Круглые аватары с инициалами при ошибке
- Разные размеры: 18px (AppBar), 30px (welcome), 40px (модалы)

### Debug панель (DebugLogScreen)
**Компонент:** `lib/shared/widgets/debug_log_screen.dart`  
- Плавающая кнопка "Отладка" (красная с счетчиком)
- Полноэкранный overlay с логами
- Цветная подсветка событий

## Состояния загрузки и ошибок

### Loading states
- `CircularProgressIndicator` по центру
- Для списков: индикатор в контейнере

### Error states  
- Красная иконка `Icons.error` (64px)
- Текст ошибки
- Кнопка "Повторить" для retry

### Empty states
Каждый экран имеет уникальное пустое состояние:
- **StudentDashboard:** "Ты нигде не учишься. Выгляни в коридор, чтобы найти что-нибудь интересное!"
- **EnrolledCoursesScreen:** То же сообщение
- **CourseContentScreen:** "Курс пока пуст"
- **StudentHomeworkScreen:** "У вас пока нет домашних заданий"
- **UserListScreen:** "Пользователи отсутствуют"
- **CourseManagementScreen:** "Курсы отсутствуют"
- **HomeworkReviewScreen:** "Нет домашних заданий для проверки"

## Права доступа

### Студент (isAdmin: false)
- Табы: "За парту", "В коридор"
- Доступ к курсам, урокам, домашним заданиям
- Отправка ответов на задания

### Администратор (isAdmin: true)  
- Все функции студента +
- Таб "Учительская" с тремя разделами
- Управление курсами, пользователями, проверка заданий
- Создание и редактирование контента

**Бейдж "Администратор"** отображается оранжевым цветом (`accentOrange`) в welcome карточке и профилях.

**Система готова к продакшену:** Все экраны реализованы с правильными текстами и цветами ✅ 