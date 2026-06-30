const OPTIONS = [
  { id: 'en', flag: '🇬🇧', label: 'English' },
  { id: 'ru', flag: '🇷🇺', label: 'Русский' },
]

export default function LanguageSelectionView({ onSelect }) {
  return (
    <div className="view anim-fade" style={{ zIndex: 100, alignItems: 'center', justifyContent: 'center' }}>
      <div className="lang-select">
        <div className="lang-select__icon">
          <svg viewBox="0 0 48 48" fill="none">
            <defs>
              <linearGradient id="lg" x1="0" y1="0" x2="1" y2="1">
                <stop offset="0%" stopColor="#3B82F6"/>
                <stop offset="100%" stopColor="#6366F1"/>
              </linearGradient>
            </defs>
            <rect x="4" y="4" width="18" height="18" rx="4" stroke="url(#lg)" strokeWidth="1.5" opacity="0.5"/>
            <rect x="26" y="4" width="18" height="18" rx="4" stroke="url(#lg)" strokeWidth="1.5" opacity="0.5"/>
            <rect x="4" y="26" width="18" height="18" rx="4" stroke="url(#lg)" strokeWidth="1.5" opacity="0.5"/>
            <rect x="26" y="26" width="18" height="18" rx="4" fill="url(#lg)" opacity="0.85"/>
          </svg>
        </div>
        <h1 className="lang-select__title">PictureArt</h1>
        <p className="lang-select__sub">Choose your language / Выберите язык</p>
        <div className="lang-select__options">
          {OPTIONS.map(o => (
            <button
              key={o.id}
              className="lang-select__option glass"
              onClick={() => onSelect(o.id)}
            >
              <span className="lang-select__flag">{o.flag}</span>
              <span className="lang-select__label">{o.label}</span>
            </button>
          ))}
        </div>
      </div>

      <style>{`
        .lang-select { display: flex; flex-direction: column; align-items: center; gap: 16px; padding: 32px; text-align: center; }
        .lang-select__icon svg { width: 72px; height: 72px; }
        .lang-select__title { font-size: 24px; font-weight: 700; margin-top: 4px; }
        .lang-select__sub { font-size: 14px; color: var(--label-secondary); margin-bottom: 8px; }
        .lang-select__options { display: flex; flex-direction: column; gap: 10px; width: 100%; max-width: 280px; }
        .lang-select__option {
          display: flex; align-items: center; gap: 12px; padding: 16px 20px;
          border-radius: 14px; cursor: pointer; transition: transform 0.15s;
        }
        .lang-select__option:active { transform: scale(0.97); }
        .lang-select__flag { font-size: 26px; }
        .lang-select__label { font-size: 16px; font-weight: 600; color: var(--label-primary); }
      `}</style>
    </div>
  )
}
