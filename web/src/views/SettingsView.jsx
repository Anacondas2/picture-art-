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
    saved: 'Saved',
    clear: 'Clear',
    aiSection: 'AI Integration',
    aboutSection: 'About',
    version: 'Version 1.0',
    howTo: 'How to Use',
    howToDesc: '1. Create a project and choose a photo\n2. Select an art style\n3. Tap squares to see each tile\n4. Draw the tile on paper\n5. Mark as done and move to next',
  },
  ru: {
    title: 'Настройки',
    back: 'Назад',
    langSection: 'Язык',
    apiKey: 'Ключ Stability AI',
    apiKeyDesc: 'Нужен для AI стилизации. Получите на platform.stability.ai',
    apiKeyPh: 'sk-…',
    save: 'Сохранить',
    saved: 'Сохранено',
    clear: 'Очистить',
    aiSection: 'Интеграция AI',
    aboutSection: 'О приложении',
    version: 'Версия 1.0',
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
        <button className="nav-btn" onClick={onBack} aria-label={t.back}>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" width="22" height="22">
            <polyline points="15 18 9 12 15 6"/>
          </svg>
        </button>
        <h1 className="nav-title">{t.title}</h1>
        <div style={{ minWidth: 44 }} />
      </nav>

      <div className="scroll-area">

        {/* Language */}
        <div className="stg-section">
          <p className="section-label">{t.langSection}</p>
          <div className="glass stg-card stg-lang-row">
            <button
              className={`stg-lang-btn${lang === 'en' ? ' active' : ''}`}
              onClick={() => onChangeLang('en')}
            >
              🇬🇧 English
            </button>
            <button
              className={`stg-lang-btn${lang === 'ru' ? ' active' : ''}`}
              onClick={() => onChangeLang('ru')}
            >
              🇷🇺 Русский
            </button>
          </div>
        </div>

        {/* AI */}
        <div className="stg-section">
          <p className="section-label">{t.aiSection}</p>
          <div className="glass stg-card">
            <p className="stg-card__title">{t.apiKey}</p>
            <p className="stg-card__desc">{t.apiKeyDesc}</p>
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
            <div className="stg-key-actions">
              <button className="btn-primary" onClick={handleSave} style={{ flex: 1 }}>
                {showSaved ? `${t.saved} ✓` : t.save}
              </button>
              {inputKey && (
                <button className="btn-secondary" onClick={handleClear} style={{ minWidth: 80 }}>
                  {t.clear}
                </button>
              )}
            </div>
            {apiKey && (
              <p className="stg-key-active">
                {lang === 'ru' ? '● Ключ активен' : '● Key active'}
              </p>
            )}
          </div>
        </div>

        {/* How to */}
        <div className="stg-section">
          <p className="section-label">{t.howTo}</p>
          <div className="glass stg-card">
            {t.howToDesc.split('\n').map((line, i) => (
              <p key={i} className="stg-howto-line">{line}</p>
            ))}
          </div>
        </div>

        {/* About */}
        <div className="stg-section">
          <p className="section-label">{t.aboutSection}</p>
          <div className="glass stg-card stg-about">
            <div className="stg-about__icon">
              <svg viewBox="0 0 48 48" fill="none">
                <defs>
                  <linearGradient id="ag2" x1="0" y1="0" x2="1" y2="1">
                    <stop offset="0%" stopColor="#0a84ff"/>
                    <stop offset="100%" stopColor="#0055cc"/>
                  </linearGradient>
                </defs>
                <rect x="4"  y="4"  width="18" height="18" rx="4" stroke="url(#ag2)" strokeWidth="1.5" opacity="0.5"/>
                <rect x="26" y="4"  width="18" height="18" rx="4" stroke="url(#ag2)" strokeWidth="1.5" opacity="0.5"/>
                <rect x="4"  y="26" width="18" height="18" rx="4" stroke="url(#ag2)" strokeWidth="1.5" opacity="0.5"/>
                <rect x="26" y="26" width="18" height="18" rx="4" fill="url(#ag2)" opacity="0.85"/>
              </svg>
            </div>
            <div>
              <p className="stg-about__name">PictureArt</p>
              <p className="stg-about__ver">{t.version}</p>
            </div>
          </div>
        </div>

      </div>

      <style>{`
        .stg-section { padding: 16px 16px 0; }
        .stg-card { display: flex; flex-direction: column; gap: 12px; padding: 18px; border-radius: 18px; }
        .stg-lang-row { flex-direction: row; gap: 8px; }
        .stg-lang-btn {
          flex: 1; min-height: 44px; padding: 12px 8px;
          border-radius: 12px; font-family: 'Syne', system-ui, sans-serif;
          font-size: 13px; font-weight: 700; letter-spacing: 0.01em;
          background: rgba(255,255,255,0.18); border: 1px solid rgba(255,255,255,0.50);
          color: var(--ink-3); cursor: pointer;
          transition: all 0.2s cubic-bezier(0.16,1,0.3,1);
          touch-action: manipulation;
        }
        .stg-lang-btn.active {
          background: var(--ink-2); border-color: var(--ink-2); color: #fff;
          box-shadow: 0 4px 16px rgba(4,13,24,0.28);
        }
        .stg-card__title {
          font-family: 'Syne', system-ui, sans-serif;
          font-size: 16px; font-weight: 700; letter-spacing: -0.02em; color: var(--ink-2);
        }
        .stg-card__desc { font-size: 13px; color: var(--ink-3); line-height: 1.5; }
        .stg-key-actions { display: flex; gap: 8px; }
        .stg-key-active { font-family: 'Syne', system-ui, sans-serif; font-size: 12px; font-weight: 700; color: #14c87c; letter-spacing: 0.02em; }
        .stg-howto-line { font-size: 14px; color: var(--ink-3); line-height: 1.65; }
        .stg-about { flex-direction: row; align-items: center; gap: 14px; }
        .stg-about__icon svg { width: 44px; height: 44px; flex-shrink: 0; }
        .stg-about__name { font-family: 'Syne', system-ui, sans-serif; font-size: 17px; font-weight: 700; letter-spacing: -0.02em; color: var(--ink-2); }
        .stg-about__ver { font-family: 'Syne', system-ui, sans-serif; font-size: 12px; font-weight: 600; letter-spacing: 0.04em; color: var(--ink-4); margin-top: 2px; text-transform: uppercase; }
      `}</style>
    </div>
  )
}
