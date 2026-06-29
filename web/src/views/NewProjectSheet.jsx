import { useState, useRef } from 'react'
import { loadImageFromFile, resizeImage, splitImage } from '../utils/imageSplitter'
import { saveTile, generateId } from '../utils/storage'
import { applyStyleToImage } from '../utils/stabilityAI'
import { STYLES, SKILL_LEVELS, MEDIUMS, GRID_OPTIONS, styleById } from '../data/drawingStyles'

const T = {
  en: {
    title: 'New Project',
    close: 'Cancel',
    next: 'Next',
    generate: 'Generate',
    back: 'Back',
    step1: 'Choose Photo',
    step2: 'Configure',
    tapPhoto: 'Tap to choose a photo',
    orCamera: 'from your camera roll',
    name: 'Project name',
    namePh: 'My Drawing',
    skillLevel: 'Skill Level',
    style: 'Art Style',
    medium: 'Medium',
    gridSize: 'Grid Size',
    rows: 'Rows',
    cols: 'Cols',
    noKey: 'No API key — original photo will be used. Add key in Settings.',
    processing: 'Processing…',
    splitting: 'Splitting into tiles…',
    done: 'Done!',
    error: 'Error. Try again.',
  },
  ru: {
    title: 'Новый проект',
    close: 'Отмена',
    next: 'Далее',
    generate: 'Создать',
    back: 'Назад',
    step1: 'Выбрать фото',
    step2: 'Настройки',
    tapPhoto: 'Нажмите, чтобы выбрать фото',
    orCamera: 'из галереи',
    name: 'Название проекта',
    namePh: 'Мой рисунок',
    skillLevel: 'Уровень',
    style: 'Стиль',
    medium: 'Техника',
    gridSize: 'Размер сетки',
    rows: 'Строки',
    cols: 'Столбцы',
    noKey: 'Ключ API не задан — будет использовано оригинальное фото. Добавьте ключ в Настройках.',
    processing: 'Обработка…',
    splitting: 'Разбивка на клетки…',
    done: 'Готово!',
    error: 'Ошибка. Попробуйте ещё раз.',
  },
}

export default function NewProjectSheet({ lang, apiKey, onClose, onCreated }) {
  const t = T[lang]
  const fileRef = useRef(null)

  const [step, setStep] = useState('photo') // photo | configure | processing
  const [imageDataUrl, setImageDataUrl] = useState(null)
  const [name, setName] = useState('')
  const [selectedStyle, setSelectedStyle] = useState('none')
  const [selectedMedium, setSelectedMedium] = useState('brush')
  const [skillLevel, setSkillLevel] = useState('intermediate')
  const [gridRows, setGridRows] = useState(12)
  const [gridCols, setGridCols] = useState(12)
  const [progress, setProgress] = useState(0)
  const [progressLabel, setProgressLabel] = useState('')
  const [error, setError] = useState('')

  const n = name.trim() || t.namePh

  const handleFile = async (e) => {
    const file = e.target.files?.[0]
    if (!file) return
    try {
      const raw = await loadImageFromFile(file)
      const resized = await resizeImage(raw, 1024, 1024)
      setImageDataUrl(resized)
      setStep('configure')
      if (!name) setName(file.name.replace(/\.[^.]+$/, '').replace(/[_-]/g, ' '))
    } catch (err) {
      console.error(err)
    }
  }

  const handleGenerate = async () => {
    setStep('processing')
    setError('')
    setProgress(0)
    const id = generateId()

    try {
      let displayImage = imageDataUrl
      const style = styleById(selectedStyle)

      if (style.prompt && apiKey) {
        setProgressLabel(t.processing)
        displayImage = await applyStyleToImage(imageDataUrl, style.prompt, apiKey, p => setProgress(p))
      } else {
        setProgress(50)
      }

      setProgressLabel(t.splitting)
      const tiles = await splitImage(displayImage, gridRows, gridCols)
      setProgress(80)

      // Save display image and tiles
      await saveTile(id, 'display', displayImage)
      await saveTile(id, 'thumb', displayImage) // thumb = same for now
      for (const tile of tiles) {
        await saveTile(id, `${tile.row}:${tile.col}`, tile.dataUrl)
      }

      setProgress(100)
      setProgressLabel(t.done)

      const squares = tiles.map(({ row, col }) => ({ row, col, isCompleted: false }))
      const project = {
        id,
        name: n,
        style: selectedStyle,
        medium: selectedMedium,
        skillLevel,
        gridRows,
        gridCols,
        squares,
        totalCount: squares.length,
        completedCount: 0,
        progress: 0,
        thumbDataUrl: displayImage.slice(0, 200), // just store header as tiny preview key
        createdAt: Date.now(),
      }

      // Store the full thumb as data url for display
      project.thumbDataUrl = displayImage

      await new Promise(r => setTimeout(r, 600))
      onCreated(project)
    } catch (err) {
      console.error(err)
      setError(t.error + ' ' + err.message)
      setStep('configure')
    }
  }

  const skill = SKILL_LEVELS.find(s => s.id === skillLevel)

  return (
    <div className="view anim-slide-up" style={{ zIndex: 50 }}>
      <nav className="nav-bar">
        <button className="nav-btn" onClick={step === 'configure' ? () => setStep('photo') : onClose}>
          {step === 'configure' ? (
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <polyline points="15 18 9 12 15 6"/>
            </svg>
          ) : (
            <span style={{ fontSize: 14 }}>{t.close}</span>
          )}
        </button>
        <h1 className="nav-title">{t.title}</h1>
        <div style={{ minWidth: 44 }} />
      </nav>

      {step === 'photo' && (
        <div className="scroll-area nps-photo-step">
          <input
            ref={fileRef}
            type="file"
            accept="image/*"
            capture="environment"
            style={{ display: 'none' }}
            onChange={handleFile}
          />
          <button
            className="nps-photo-picker glass"
            onClick={() => fileRef.current?.click()}
          >
            <div className="nps-photo-picker__icon">
              <svg viewBox="0 0 48 48" fill="none">
                <defs>
                  <linearGradient id="cg" x1="0" y1="0" x2="1" y2="1">
                    <stop offset="0%" stopColor="#3B82F6"/>
                    <stop offset="100%" stopColor="#6366F1"/>
                  </linearGradient>
                </defs>
                <rect x="4" y="10" width="40" height="30" rx="6" stroke="url(#cg)" strokeWidth="2"/>
                <circle cx="24" cy="25" r="9" stroke="url(#cg)" strokeWidth="2"/>
                <circle cx="24" cy="25" r="4" fill="url(#cg)" opacity="0.6"/>
                <rect x="30" y="6" width="8" height="6" rx="2" fill="url(#cg)" opacity="0.5"/>
              </svg>
            </div>
            <p className="nps-photo-picker__label">{t.tapPhoto}</p>
            <p className="nps-photo-picker__sub">{t.orCamera}</p>
          </button>
        </div>
      )}

      {step === 'configure' && (
        <div className="scroll-area">
          {/* Preview */}
          {imageDataUrl && (
            <div className="nps-preview">
              <img src={imageDataUrl} alt="" className="nps-preview__img" />
            </div>
          )}

          <div className="nps-section">
            <p className="section-label">{t.name}</p>
            <input
              className="input"
              value={name}
              onChange={e => setName(e.target.value)}
              placeholder={t.namePh}
              maxLength={50}
            />
          </div>

          <div className="nps-section">
            <p className="section-label">{t.skillLevel}</p>
            <div className="nps-skill-row">
              {SKILL_LEVELS.map(s => (
                <button
                  key={s.id}
                  className={`nps-skill-card glass ${skillLevel === s.id ? 'selected' : ''}`}
                  onClick={() => {
                    setSkillLevel(s.id)
                    setGridRows(s.defaultGrid)
                    setGridCols(s.defaultGrid)
                  }}
                >
                  <span className="nps-skill-card__emoji">{s.emoji}</span>
                  <span className="nps-skill-card__name">{lang === 'ru' ? s.nameRu : s.nameEn}</span>
                  <span className="nps-skill-card__desc">{lang === 'ru' ? s.descRu : s.descEn}</span>
                </button>
              ))}
            </div>
          </div>

          <div className="nps-section">
            <p className="section-label">{t.style}</p>
            {!apiKey && selectedStyle !== 'none' && (
              <p className="nps-warning">{t.noKey}</p>
            )}
            <div className="hscroll" style={{ paddingBottom: 8 }}>
              {STYLES.map(s => (
                <button
                  key={s.id}
                  className="nps-style-card"
                  style={{ '--accent': s.color }}
                  onClick={() => setSelectedStyle(s.id)}
                >
                  <div className={`nps-style-card__circle neu ${selectedStyle === s.id ? 'sel' : ''}`}>
                    <span>{s.emoji}</span>
                  </div>
                  <span className="nps-style-card__label" style={{ color: selectedStyle === s.id ? s.color : 'var(--label-secondary)' }}>
                    {lang === 'ru' ? s.nameRu : s.nameEn}
                  </span>
                </button>
              ))}
            </div>
          </div>

          <div className="nps-section">
            <p className="section-label">{t.medium}</p>
            <div className="hscroll">
              {MEDIUMS.map(m => (
                <button
                  key={m.id}
                  className={`chip ${selectedMedium === m.id ? 'selected' : ''}`}
                  onClick={() => setSelectedMedium(m.id)}
                >
                  {lang === 'ru' ? m.nameRu : m.nameEn}
                </button>
              ))}
            </div>
          </div>

          <div className="nps-section">
            <p className="section-label">{t.gridSize}</p>
            <div className="nps-grid-selectors">
              <div className="nps-grid-picker">
                <p className="nps-grid-picker__label">{t.rows}</p>
                <select
                  className="nps-grid-select input"
                  value={gridRows}
                  onChange={e => setGridRows(Number(e.target.value))}
                >
                  {GRID_OPTIONS.map(v => <option key={v} value={v}>{v}</option>)}
                </select>
              </div>
              <div className="nps-grid-badge">
                <span className="nps-grid-badge__val">{gridRows}×{gridCols}</span>
                <span className="nps-grid-badge__total">{gridRows * gridCols}</span>
              </div>
              <div className="nps-grid-picker">
                <p className="nps-grid-picker__label">{t.cols}</p>
                <select
                  className="nps-grid-select input"
                  value={gridCols}
                  onChange={e => setGridCols(Number(e.target.value))}
                >
                  {GRID_OPTIONS.map(v => <option key={v} value={v}>{v}</option>)}
                </select>
              </div>
            </div>
          </div>

          {error && <p className="nps-error">{error}</p>}

          <div className="nps-section">
            <button className="btn-primary" onClick={handleGenerate}>
              {t.generate}
            </button>
          </div>
        </div>
      )}

      {step === 'processing' && (
        <div className="nps-processing">
          <div className="nps-processing__spinner">
            <svg viewBox="0 0 80 80" fill="none">
              <defs>
                <linearGradient id="spg" x1="0" y1="0" x2="1" y2="1">
                  <stop offset="0%" stopColor="#3B82F6"/>
                  <stop offset="100%" stopColor="#6366F1"/>
                </linearGradient>
              </defs>
              <circle cx="40" cy="40" r="34" stroke="rgba(255,255,255,0.08)" strokeWidth="4"/>
              <circle
                cx="40" cy="40" r="34"
                stroke="url(#spg)" strokeWidth="4"
                strokeLinecap="round"
                strokeDasharray={`${2 * Math.PI * 34 * progress / 100} ${2 * Math.PI * 34}`}
                transform="rotate(-90 40 40)"
                style={{ transition: 'stroke-dasharray 0.4s ease' }}
              />
              <text x="40" y="45" textAnchor="middle" fill="white" fontSize="16" fontWeight="700">
                {Math.round(progress)}%
              </text>
            </svg>
          </div>
          <p className="nps-processing__label">{progressLabel || t.processing}</p>
        </div>
      )}

      <style>{`
        .nps-photo-step { display: flex; align-items: center; justify-content: center; padding: 24px; }
        .nps-photo-picker {
          width: 100%; max-width: 340px; display: flex; flex-direction: column;
          align-items: center; justify-content: center; gap: 12px;
          padding: 48px 32px; cursor: pointer; text-align: center;
          min-height: 280px; transition: transform 0.15s;
        }
        .nps-photo-picker:active { transform: scale(0.98); }
        .nps-photo-picker__icon svg { width: 64px; height: 64px; }
        .nps-photo-picker__label { font-size: 17px; font-weight: 600; }
        .nps-photo-picker__sub { font-size: 13px; color: var(--label-secondary); }
        .nps-preview { margin: 16px 16px 0; border-radius: 14px; overflow: hidden; max-height: 180px; }
        .nps-preview__img { width: 100%; height: 180px; object-fit: cover; display: block; }
        .nps-section { padding: 16px 16px 0; }
        .nps-warning {
          font-size: 12px; color: var(--label-secondary); padding: 8px 12px;
          background: rgba(59,130,246,0.1); border: 0.5px solid rgba(59,130,246,0.3);
          border-radius: 8px; margin-bottom: 10px; line-height: 1.4;
        }
        .nps-skill-row { display: flex; gap: 8px; }
        .nps-skill-card {
          flex: 1; display: flex; flex-direction: column; align-items: center;
          gap: 4px; padding: 10px 6px; border: none; cursor: pointer;
          border-radius: 12px; transition: all 0.15s;
        }
        .nps-skill-card.selected {
          background: linear-gradient(135deg, var(--accent-blue), var(--brand)) !important;
          border-color: rgba(99,102,241,0.6) !important;
          box-shadow: 0 4px 12px rgba(99,102,241,0.35);
        }
        .nps-skill-card__emoji { font-size: 20px; }
        .nps-skill-card__name { font-size: 12px; font-weight: 600; color: var(--label-primary); }
        .nps-skill-card__desc { font-size: 10px; color: var(--label-secondary); text-align: center; }
        .nps-style-card {
          display: flex; flex-direction: column; align-items: center; gap: 6px;
          padding: 10px 4px; background: none; border: none; cursor: pointer;
          flex-shrink: 0;
        }
        .nps-style-card__circle {
          width: 56px; height: 56px; border-radius: 50%; display: flex;
          align-items: center; justify-content: center; font-size: 22px;
          transition: all 0.15s; border: 2px solid transparent;
        }
        .nps-style-card__circle.sel {
          box-shadow: 0 0 0 2px var(--accent), 0 4px 12px color-mix(in srgb, var(--accent) 45%, transparent);
          transform: scale(1.08);
        }
        .nps-style-card__label { font-size: 11px; text-align: center; width: 68px; transition: color 0.15s; }
        .nps-grid-selectors { display: flex; align-items: center; gap: 12px; }
        .nps-grid-picker { flex: 1; display: flex; flex-direction: column; gap: 6px; }
        .nps-grid-picker__label { font-size: 13px; color: var(--label-secondary); }
        .nps-grid-select { cursor: pointer; appearance: auto; }
        .nps-grid-badge { display: flex; flex-direction: column; align-items: center; flex-shrink: 0; }
        .nps-grid-badge__val { font-size: 24px; font-weight: 700; color: var(--brand); }
        .nps-grid-badge__total { font-size: 11px; color: var(--label-tertiary); }
        .nps-error { color: #EF4444; font-size: 13px; padding: 0 16px 8px; }
        .nps-processing {
          flex: 1; display: flex; flex-direction: column; align-items: center;
          justify-content: center; gap: 24px;
        }
        .nps-processing__spinner svg { width: 120px; height: 120px; }
        .nps-processing__label { font-size: 16px; color: var(--label-secondary); font-weight: 500; }
      `}</style>
    </div>
  )
}
