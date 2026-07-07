const OPTIONS = [
  { id: 'en', label: 'English', sub: 'Continue in English' },
  { id: 'ru', label: 'Русский', sub: 'Продолжить на русском' },
]

export default function LanguageSelectionView({ onSelect }) {
  return (
    <div className="view anim-fade" style={{ zIndex: 100 }}>
      <div className="lang-screen">
        <div className="lang-screen__hero anim-rise">
          <div className="lang-screen__logo" aria-hidden="true">
            <svg viewBox="0 0 48 48" fill="none">
              <path d="M8 30c4-9 10-14 16-14s12 5 16 14" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
              <path d="M12 34c3-6.5 7.5-10 12-10s9 3.5 12 10" stroke="currentColor" strokeWidth="2" strokeLinecap="round" opacity="0.55"/>
              <circle cx="24" cy="12" r="3" fill="currentColor" opacity="0.85"/>
            </svg>
          </div>
          <h1 className="lang-screen__title">
            <span className="lang-screen__bright">Welcome to </span>
            <span className="lang-screen__ghost">PictureArt</span>
          </h1>
          <p className="lang-screen__sub">Choose your language · Выберите язык</p>
        </div>

        <div className="lang-screen__pebbles anim-rise" style={{ animationDelay: '0.1s' }} aria-hidden="true">
          <div className="lang-pebble lang-pebble-a glass" />
          <div className="lang-pebble lang-pebble-b glass" />
          <div className="lang-pebble lang-pebble-c glass" />
        </div>

        <div className="lang-screen__options">
          {OPTIONS.map((o, i) => (
            <button
              key={o.id}
              className="lang-option glass anim-rise"
              style={{ animationDelay: `${0.12 + i * 0.08}s` }}
              onClick={() => onSelect(o.id)}
            >
              <span className="lang-option__text">
                <span className="lang-option__label">{o.label}</span>
                <span className="lang-option__sub">{o.sub}</span>
              </span>
              <span className="lang-option__go" aria-hidden="true">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" width="18" height="18">
                  <line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/>
                </svg>
              </span>
            </button>
          ))}
        </div>
      </div>

      <style>{`
        .lang-screen {
          width: 100%; height: 100%;
          display: flex; flex-direction: column;
          justify-content: space-between;
          padding: calc(env(safe-area-inset-top,0px) + 84px) 30px calc(env(safe-area-inset-bottom,0px) + 64px);
        }

        .lang-screen__logo {
          color: rgba(255,255,255,0.95);
          margin-bottom: 30px;
        }
        .lang-screen__logo svg { width: 52px; height: 52px; }

        .lang-screen__title {
          font-family: 'Comfortaa', 'Inter', system-ui, sans-serif;
          font-size: clamp(34px, 9.6vw, 46px);
          font-weight: 400;
          letter-spacing: 0.005em;
          line-height: 1.22;
          max-width: 9em;
          margin-bottom: 18px;
        }
        .lang-screen__bright { color: rgba(255,255,255,0.97); }
        .lang-screen__ghost  { color: rgba(255,255,255,0.55); }

        .lang-screen__sub {
          font-family: 'Comfortaa', 'Inter', system-ui, sans-serif;
          font-size: 13px; font-weight: 500;
          letter-spacing: 0.04em;
          color: rgba(255,255,255,0.72);
        }

        .lang-screen__pebbles { position: relative; flex: 1; margin: 24px 0; min-height: 120px; }
        .lang-pebble { position: absolute; }
        .lang-pebble-a {
          width: 30vw; height: 26vw; max-width: 130px; max-height: 112px;
          left: 2%; top: 30%;
          border-radius: 46% 54% 52% 48% / 55% 48% 52% 45%;
          transform: rotate(-8deg);
        }
        .lang-pebble-b {
          width: 36vw; height: 30vw; max-width: 152px; max-height: 128px;
          left: 32%; top: 12%;
          border-radius: 52% 48% 47% 53% / 46% 55% 45% 54%;
          background: rgba(255,255,255,0.42);
        }
        .lang-pebble-c {
          width: 27vw; height: 24vw; max-width: 118px; max-height: 104px;
          right: 3%; top: 38%;
          border-radius: 48% 52% 55% 45% / 52% 46% 54% 48%;
          transform: rotate(7deg);
        }

        .lang-screen__options { display: flex; flex-direction: column; gap: 12px; }

        .lang-option {
          display: flex; align-items: center; gap: 14px;
          padding: 19px 24px;
          cursor: pointer;
          transition: transform 0.3s cubic-bezier(0.16,1,0.3,1);
          touch-action: manipulation;
          text-align: left;
          border-radius: 26px;
        }
        .lang-option:active { transform: scale(0.97); }

        .lang-option__text { flex: 1; display: flex; flex-direction: column; gap: 3px; }
        .lang-option__label {
          font-family: 'Comfortaa', 'Inter', system-ui, sans-serif;
          font-size: 18px; font-weight: 600;
          color: var(--ink);
        }
        .lang-option__sub {
          font-size: 12px; font-weight: 400;
          color: var(--ink-4);
        }
        .lang-option__go {
          display: flex; align-items: center; justify-content: center;
          width: 40px; height: 40px; border-radius: 100px;
          background: rgba(255,255,255,0.55);
          color: var(--ink-2);
          flex-shrink: 0;
        }
      `}</style>
    </div>
  )
}
