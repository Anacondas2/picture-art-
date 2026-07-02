const OPTIONS = [
  { id: 'en', flag: '🇬🇧', label: 'English' },
  { id: 'ru', flag: '🇷🇺', label: 'Русский' },
]

export default function LanguageSelectionView({ onSelect }) {
  return (
    <div className="view anim-fade" style={{ zIndex: 100 }}>
      <div className="lang-screen">
        {/* Top: Giant typographic mark */}
        <div className="lang-screen__hero">
          <p className="lang-screen__eyebrow">PictureArt</p>
          <h1 className="lang-screen__title">
            <span className="lang-screen__word1">Choose</span>
            <span className="lang-screen__word2">Language.</span>
          </h1>
        </div>

        {/* Bottom: Language options */}
        <div className="lang-screen__options">
          <p className="lang-screen__hint">/ Выберите язык</p>
          {OPTIONS.map(o => (
            <button
              key={o.id}
              className="lang-option glass"
              onClick={() => onSelect(o.id)}
            >
              <span className="lang-option__flag">{o.flag}</span>
              <span className="lang-option__label">{o.label}</span>
              <span className="lang-option__arrow">→</span>
            </button>
          ))}
        </div>
      </div>

      <style>{`
        .lang-screen {
          width: 100%; height: 100%;
          display: flex; flex-direction: column;
          justify-content: space-between;
          padding: calc(env(safe-area-inset-top,0px) + 64px) 28px calc(env(safe-area-inset-bottom,0px) + 56px);
        }

        .lang-screen__hero { display: flex; flex-direction: column; gap: 0; }

        .lang-screen__eyebrow {
          font-family: 'Syne', system-ui, sans-serif;
          font-size: 11px; font-weight: 700;
          letter-spacing: 0.18em; text-transform: uppercase;
          color: rgba(255,255,255,0.45);
          margin-bottom: 20px;
        }

        .lang-screen__title { display: flex; flex-direction: column; }

        .lang-screen__word1 {
          font-family: 'Syne', system-ui, sans-serif;
          font-size: clamp(56px, 15vw, 88px);
          font-weight: 800;
          letter-spacing: -0.048em;
          line-height: 0.9;
          color: rgba(255,255,255,0.95);
        }

        .lang-screen__word2 {
          font-family: 'Syne', system-ui, sans-serif;
          font-size: clamp(56px, 15vw, 88px);
          font-weight: 800;
          letter-spacing: -0.048em;
          line-height: 1.0;
          color: rgba(255,255,255,0.38);
        }

        .lang-screen__options { display: flex; flex-direction: column; gap: 10px; }

        .lang-screen__hint {
          font-family: 'Syne', system-ui, sans-serif;
          font-size: 11px; font-weight: 700;
          letter-spacing: 0.10em;
          color: rgba(255,255,255,0.35);
          margin-bottom: 14px;
        }

        .lang-option {
          display: flex; align-items: center; gap: 14px;
          padding: 18px 20px;
          border: none; cursor: pointer;
          transition: transform 0.2s cubic-bezier(0.16,1,0.3,1);
          touch-action: manipulation;
          text-align: left;
        }
        .lang-option:active { transform: scale(0.97); }

        .lang-option__flag { font-size: 28px; line-height: 1; }

        .lang-option__label {
          font-family: 'Syne', system-ui, sans-serif;
          font-size: 18px; font-weight: 700;
          letter-spacing: -0.02em;
          color: var(--ink-2);
          flex: 1;
        }

        .lang-option__arrow {
          font-family: 'Syne', system-ui, sans-serif;
          font-size: 18px; font-weight: 400;
          color: var(--ink-4);
        }
      `}</style>
    </div>
  )
}
