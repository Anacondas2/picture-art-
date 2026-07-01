import { useState } from 'react'

const T = {
  en: {
    title: 'Settings',
    back: 'Back',
    langSection: 'Language',
    apiKey: 'Stability AI Key',
    apiKeyDesc: 'Required for AI style transfer. Get yours at platform.stability.ai',
    apiKeyPh: 'sk-…',
    save: 'Save',
    saved: 'Saved ✓',
    clear: 'Clear',
    aiSection: 'AI Integration',
    aboutSection: 'About',
    version: 'Version',
    howTo: 'How to use',
    howToDesc: '1. Create a project and choose a photo\n2. Select an art style\n3. Tap squares to see each tile\n4. Draw the tile on paper\n5. Mark as done and move to next',
  },
  ru: {
    title: 'Настройки',
    back: 'Назад',
    langSection: 'Язык',
    apiKey: 'Ключ Stability AI',
    apiKeyDesc: 'Нужен для AI стилизации фото. Получите на platform.stability.ai',
    apiKeyPh: 'sk-…',
    save: 'Сохранить',
    saved: 'Сохранено ✓',
    clear: 'Очистить',
    aiSection: 'Интеграция AI',
    aboutSection: 'О приложении',
    version: 'Версия',
    howTo: 'Как пользоваться',
    howToDesc: '1. Создайте проект и выберите фото\n2. Выберите художественный стиль\n3. Нажимайте на клетки, чтобы видеть их\n4. Нарисуйте клетку на бумаге\n5. Отметьте готовым и переходите к следующей',
  },
}

export default function SettingsView({ lang, apiKey, onSaveApiKey, onChangeLang, onBack }) {
  const t = T[lang]
  const [inputKey, setInputKey] = useState(apiKey)
  const [showSaved, setShowSaved] = useState(false)

  const handleSave = () => {
    onSaveApiKey(inputKey.trim())
    setShowSaved(true)
    setTimeout(() => setShowSaved(false), 2000)
  }

  const handleClear = () => {
    setInputKey('')
    onSaveApiKey('')
  }

  return (
    <div className="view anim-slide-right">
      <nav className="nav-bar">
        <button className="nav-btn" onClick={onBack}>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" width="20" height="20">
            <polyline points="15 18 9 12 15 6"/>
          </svg>
        </button>
        <h1 className="nav-title">{t.title}</h1>
        <div style={{ minWidth: 44 }} />
      </nav>

      <div className="scroll-area">
        <div className="settings-section">
          <p className="section-label">{t.langSection}</p>
          <div className="glass settings-card settings-lang-row">
            <button
              className={`settings-lang-btn ${lang === 'en' ? 'selected' : ''}`}
              onClick={() => onChangeLang('en')}
            >
              🇬🇧 English
            </button>
            <button
              className={`settings-lang-btn ${lang === 'ru' ? 'selected' : ''}`}
              onClick={() => onChangeLang('ru')}
            >
              🇷🇺 Русский
            </button>
          </div>
        </div>

        <div className="settings-section">
          <p className="section-label">{t.aiSection}</p>
          <div className="glass settings-card">
            <p className="settings-card__title">{t.apiKey}</p>
            <p className="settings-card__desc">{t.apiKeyDesc}</p>
            <div className="settings-key-row">
              <input
                type="password"
                className="input"
                value={inputKey}
                onChange={e => setInputKey(e.target.value)}
                placeholder={t.apiKeyPh}
                autoComplete="off"
                autoCorrect="off"
                spellCheck={false}
              />
            </div>
            <div className="settings-key-actions">
              <button
                className="btn-primary"
                onClick={handleSave}
                style={{ flex: 1 }}
              >
                {showSaved ? t.saved : t.save}
              </button>
              {inputKey && (
                <button
                  className="btn-secondary"
                  onClick={handleClear}
                  style={{ width: 80 }}
                >
                  {t.clear}
                </button>
              )}
            </div>
            {apiKey && (
              <p className="settings-key-active">
                {lang === 'ru' ? '● Ключ активен' : '● Key active'}
              </p>
            )}
          </div>
        </div>

        <div className="settings-section">
          <p className="section-label">{t.howTo}</p>
          <div className="glass settings-card">
            {t.howToDesc.split('\n').map((line, i) => (
              <p key={i} className="settings-howto-line">{line}</p>
            ))}
          </div>
        </div>

        <div className="settings-section">
          <p className="section-label">{t.aboutSection}</p>
          <div className="glass settings-card settings-about">
            <div className="settings-about__icon">
              <svg viewBox="0 0 48 48" fill="none">
                <defs>
                  <linearGradient id="ag" x1="0" y1="0" x2="1" y2="1">
                    <stop offset="0%" stopColor="#0a84ff"/>
                    <stop offset="100%" stopColor="#0055cc"/>
                  </linearGradient>
                </defs>
                <rect x="4" y="4" width="18" height="18" rx="4" stroke="url(#ag)" strokeWidth="1.5" opacity="0.5"/>
                <rect x="26" y="4" width="18" height="18" rx="4" stroke="url(#ag)" strokeWidth="1.5" opacity="0.5"/>
                <rect x="4" y="26" width="18" height="18" rx="4" stroke="url(#ag)" strokeWidth="1.5" opacity="0.5"/>
                <rect x="26" y="26" width="18" height="18" rx="4" fill="url(#ag)" opacity="0.85"/>
                <path d="M31 35l4 4 8-9" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
            </div>
            <div>
              <p className="settings-about__name">PictureArt</p>
              <p className="settings-about__ver">{t.version} 1.0</p>
            </div>
          </div>
        </div>
      </div>

      <style>{`
        .settings-section { padding: 16px 16px 0; }
        .settings-card {
          display: flex; flex-direction: column; gap: 10px;
          padding: 16px; border-radius: 16px;
        }
        .settings-lang-row { flex-direction: row; gap: 8px; }
        .settings-lang-btn {
          flex: 1; padding: 12px; border-radius: 12px; font-size: 14px; font-weight: 600;
          background: rgba(255,255,255,0.2); border: 1px solid rgba(255,255,255,0.5);
          color: var(--label-secondary); cursor: pointer; transition: all 0.15s;
        }
        .settings-lang-btn.selected {
          background: linear-gradient(135deg, #0a84ff, #0055cc);
          border-color: rgba(10,132,255,0.5); color: white;
          box-shadow: 0 4px 12px rgba(0,100,204,0.35);
        }
        .settings-card__title { font-size: 15px; font-weight: 600; }
        .settings-card__desc { font-size: 13px; color: var(--label-secondary); line-height: 1.45; }
        .settings-key-row { display: flex; gap: 8px; }
        .settings-key-actions { display: flex; gap: 8px; }
        .settings-key-active { font-size: 12px; color: var(--green); }
        .settings-howto-line { font-size: 14px; color: var(--label-secondary); line-height: 1.6; }
        .settings-about { flex-direction: row; align-items: center; gap: 14px; }
        .settings-about__icon svg { width: 44px; height: 44px; flex-shrink: 0; }
        .settings-about__name { font-size: 16px; font-weight: 700; }
        .settings-about__ver { font-size: 13px; color: var(--label-tertiary); }
      `}</style>
    </div>
  )
}
