import Foundation
import Combine

final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published var currentLanguage: String {
        didSet { UserDefaults.standard.set(currentLanguage, forKey: "appLanguage") }
    }

    private init() {
        currentLanguage = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
    }

    func t(_ key: String) -> String {
        Strings.table[currentLanguage]?[key] ?? Strings.table["en"]?[key] ?? key
    }
}

private enum Strings {
    static let table: [String: [String: String]] = [
        "en": [
            // Onboarding
            "onboarding.title": "Welcome to PictureArt!",
            "onboarding.subtitle": "Choose your language to get started",
            "onboarding.continue": "Continue",

            // Home
            "home.title": "My Projects",
            "home.newProject": "New Project",
            "home.empty": "No projects yet.\nTap + to create your first.",
            "home.delete": "Delete",
            "home.progress": "Progress",
            "home.squares": "squares done",

            // New Project
            "newproject.title": "New Project",
            "newproject.name": "Project Name",
            "newproject.namePlaceholder": "My Drawing",
            "newproject.choosePhoto": "Choose Photo",
            "newproject.changePhoto": "Change Photo",

            // Style Selection
            "style.title": "Choose Style",
            "style.subtitle": "How should the AI transform your photo?",
            "style.medium": "Drawing Medium",
            "style.gridSize": "Grid Size",
            "style.skipAI": "Skip AI (use original photo)",
            "style.generate": "Generate",
            "style.rows": "Rows",
            "style.cols": "Columns",

            // Processing
            "processing.title": "Processing...",
            "processing.applyingStyle": "Applying AI style...",
            "processing.splitting": "Splitting into grid...",
            "processing.saving": "Saving project...",

            // Canvas
            "canvas.title": "Canvas",
            "canvas.completed": "completed",
            "canvas.next": "Next →",
            "canvas.allDone": "All done! 🎉",
            "canvas.tap": "Tap a square to draw it",

            // Square Detail
            "square.title": "Square",
            "square.markDone": "Mark as Done ✓",
            "square.done": "Done ✓",
            "square.colors": "Colors to use",
            "square.of": "of",

            // Settings
            "settings.title": "Settings",
            "settings.apiSection": "Stability AI",
            "settings.apiKey": "API Key",
            "settings.apiKeyHint": "Enter your Stability AI API key",
            "settings.apiKeyInfo": "Get a free key at platform.stability.ai",
            "settings.language": "Language",
            "settings.languageRu": "Русский",
            "settings.languageEn": "English",
            "settings.about": "About",
            "settings.version": "Version 1.0",
            "settings.appName": "PictureArt",

            // Errors
            "error.noApiKey": "Please add your Stability AI API key in Settings to use AI styles.",
            "error.network": "Network error. Please check your connection.",
            "error.api": "AI error: ",
            "error.imageLoad": "Could not load image.",
            "error.retry": "Retry",
            "error.cancel": "Cancel",
            "error.ok": "OK",
        ],
        "ru": [
            // Onboarding
            "onboarding.title": "Добро пожаловать в PictureArt!",
            "onboarding.subtitle": "Выберите язык для начала работы",
            "onboarding.continue": "Продолжить",

            // Home
            "home.title": "Мои проекты",
            "home.newProject": "Новый проект",
            "home.empty": "Нет проектов.\nНажмите + чтобы создать первый.",
            "home.delete": "Удалить",
            "home.progress": "Прогресс",
            "home.squares": "квадратов выполнено",

            // New Project
            "newproject.title": "Новый проект",
            "newproject.name": "Название проекта",
            "newproject.namePlaceholder": "Мой рисунок",
            "newproject.choosePhoto": "Выбрать фото",
            "newproject.changePhoto": "Изменить фото",

            // Style Selection
            "style.title": "Выберите стиль",
            "style.subtitle": "Как ИИ должен преобразовать фото?",
            "style.medium": "Материал для рисования",
            "style.gridSize": "Размер сетки",
            "style.skipAI": "Без ИИ (использовать оригинал)",
            "style.generate": "Создать",
            "style.rows": "Строки",
            "style.cols": "Столбцы",

            // Processing
            "processing.title": "Обработка...",
            "processing.applyingStyle": "Применяю стиль ИИ...",
            "processing.splitting": "Разбиваю на части...",
            "processing.saving": "Сохраняю проект...",

            // Canvas
            "canvas.title": "Холст",
            "canvas.completed": "выполнено",
            "canvas.next": "Следующий →",
            "canvas.allDone": "Всё готово! 🎉",
            "canvas.tap": "Нажмите на квадратик чтобы нарисовать его",

            // Square Detail
            "square.title": "Квадратик",
            "square.markDone": "Отметить как готово ✓",
            "square.done": "Готово ✓",
            "square.colors": "Цвета для рисования",
            "square.of": "из",

            // Settings
            "settings.title": "Настройки",
            "settings.apiSection": "Stability AI",
            "settings.apiKey": "API ключ",
            "settings.apiKeyHint": "Введите ваш API ключ Stability AI",
            "settings.apiKeyInfo": "Получите бесплатный ключ на platform.stability.ai",
            "settings.language": "Язык",
            "settings.languageRu": "Русский",
            "settings.languageEn": "English",
            "settings.about": "О приложении",
            "settings.version": "Версия 1.0",
            "settings.appName": "PictureArt",

            // Errors
            "error.noApiKey": "Добавьте API ключ Stability AI в настройках для использования ИИ стилей.",
            "error.network": "Ошибка сети. Проверьте подключение к интернету.",
            "error.api": "Ошибка ИИ: ",
            "error.imageLoad": "Не удалось загрузить изображение.",
            "error.retry": "Повторить",
            "error.cancel": "Отмена",
            "error.ok": "OK",
        ]
    ]
}
