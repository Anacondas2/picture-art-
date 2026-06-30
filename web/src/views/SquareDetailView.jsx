import { useState, useEffect, useRef, useCallback } from 'react'
import { loadTile } from '../utils/storage'
import { extractColors } from '../utils/colorExtractor'

const T = {
  en: {
    title: 'Square',
    row: 'Row', col: 'Col', of: 'of',
    colors: 'Dominant colors',
    markDone: 'Mark as Done',
    markUndone: 'Undo',
    prev: 'Prev',
    next: 'Next',
    close: 'Close',
  },
  ru: {
    title: 'Клетка',
    row: 'Ряд', col: 'Стб', of: 'из',
    colors: 'Цвета',
    markDone: 'Отметить готовым',
    markUndone: 'Отменить',
    prev: 'Назад',
    next: 'Вперёд',
    close: 'Закрыть',
  },
}

export default function SquareDetailView({ lang, project, initialIndex, onBack, onSquareToggle }) {
  const t = T[lang]
  const [currentIdx, setCurrentIdx] = useState(initialIndex)
  const [tileImage, setTileImage] = useState(null)
  const [colors, setColors] = useState([])
  const [swipeOffset, setSwipeOffset] = useState(0)
  const [showSwipeHint, setShowSwipeHint] = useState(false)
  const [hintDismissed, setHintDismissed] = useState(false)

  const touchStartX = useRef(null)
  const touchStartY = useRef(null)
  const isHorizontal = useRef(null)

  const square = project.squares[currentIdx]
  const isCompleted = square?.isCompleted ?? false
  const canPrev = currentIdx > 0
  const canNext = currentIdx < project.squares.length - 1

  useEffect(() => {
    if (!square) return
    setTileImage(null)
    setColors([])
    loadTile(project.id, `${square.row}:${square.col}`).then(url => {
      if (url) {
        setTileImage(url)
        extractColors(url, 6).then(setColors)
      }
    })
  }, [project.id, square?.row, square?.col])

  useEffect(() => {
    if (!hintDismissed) {
      const t1 = setTimeout(() => setShowSwipeHint(true), 1200)
      const t2 = setTimeout(() => { setShowSwipeHint(false); setHintDismissed(true) }, 4000)
      return () => { clearTimeout(t1); clearTimeout(t2) }
    }
  }, []) // eslint-disable-line

  const slideTo = useCallback((dir) => {
    const target = currentIdx + (dir === 'next' ? 1 : -1)
    if (target < 0 || target >= project.squares.length) return

    const W = window.innerWidth
    setSwipeOffset(dir === 'next' ? -W : W)
    setTimeout(() => {
      setCurrentIdx(target)
      setSwipeOffset(dir === 'next' ? W : -W)
      requestAnimationFrame(() => {
        requestAnimationFrame(() => {
          setSwipeOffset(0)
        })
      })
    }, 160)
  }, [currentIdx, project.squares.length])

  const handleTouchStart = useCallback((e) => {
    touchStartX.current = e.touches[0].clientX
    touchStartY.current = e.touches[0].clientY
    isHorizontal.current = null
  }, [])

  const handleTouchMove = useCallback((e) => {
    if (touchStartX.current === null) return
    const dx = e.touches[0].clientX - touchStartX.current
    const dy = e.touches[0].clientY - touchStartY.current

    if (isHorizontal.current === null) {
      if (Math.abs(dx) > Math.abs(dy) + 4) isHorizontal.current = true
      else if (Math.abs(dy) > Math.abs(dx) + 4) isHorizontal.current = false
      else return
    }
    if (!isHorizontal.current) return

    e.preventDefault()
    setShowSwipeHint(false)
    setHintDismissed(true)

    const isEdge = (dx > 0 && !canPrev) || (dx < 0 && !canNext)
    setSwipeOffset(isEdge ? dx * 0.2 : dx)
  }, [canPrev, canNext])

  const handleTouchEnd = useCallback((e) => {
    if (!isHorizontal.current) { isHorizontal.current = null; return }
    const dx = e.changedTouches[0].clientX - (touchStartX.current || 0)
    touchStartX.current = null
    isHorizontal.current = null

    if (dx < -80 && canNext) slideTo('next')
    else if (dx > 80 && canPrev) slideTo('prev')
    else setSwipeOffset(0)
  }, [canPrev, canNext, slideTo])

  const handleToggle = useCallback(() => {
    if (!square) return
    onSquareToggle(square.row, square.col)
    if (!isCompleted && canNext) {
      setTimeout(() => slideTo('next'), 280)
    }
  }, [square, isCompleted, canNext, onSquareToggle, slideTo])

  if (!square) return null

  const transStyle = {
    transform: `translateX(${swipeOffset}px)`,
    transition: swipeOffset === 0 && isHorizontal.current === null
      ? 'transform 0.32s cubic-bezier(0.22,1,0.36,1)'
      : 'none',
  }

  return (
    <div className="view anim-slide-up" style={{ zIndex: 40 }}>
      <nav className="nav-bar">
        <button className="nav-btn" onClick={onBack}>
          {lang === 'ru' ? 'Закрыть' : 'Close'}
        </button>
        <h1 className="nav-title">{t.title}</h1>
        <div style={{ minWidth: 44 }} />
      </nav>

      <div className="sq-pos-bar">
        <span className="sq-pos-bar__pos">
          {t.row} {square.row + 1}, {t.col} {square.col + 1}
        </span>
        <span className="sq-pos-bar__count">
          {currentIdx + 1} {t.of} {project.squares.length}
        </span>
      </div>

      <div
        className="sq-tile-area"
        onTouchStart={handleTouchStart}
        onTouchMove={handleTouchMove}
        onTouchEnd={handleTouchEnd}
      >
        <div className="sq-tile-inner" style={transStyle}>
          {tileImage ? (
            <img
              src={tileImage}
              alt=""
              className={`sq-tile-img ${isCompleted ? 'done' : ''}`}
            />
          ) : (
            <div className="sq-tile-placeholder glass">
              <div className="canvas-spinner" />
            </div>
          )}
        </div>

        {showSwipeHint && (canPrev || canNext) && (
          <div className="sq-swipe-hint glass">
            {canPrev && <span>← {t.prev}</span>}
            {canPrev && canNext && <span style={{ color: 'var(--label-tertiary)' }}>·</span>}
            {canNext && <span>{t.next} →</span>}
          </div>
        )}
      </div>

      {isCompleted && (
        <div className="sq-done-badge">
          <span>✓</span>
          <span>{lang === 'ru' ? 'Завершено' : 'Done'}</span>
        </div>
      )}

      <div className="sq-colors">
        <p className="sq-colors__label">{t.colors}</p>
        <div className="sq-colors__row">
          {colors.map((c, i) => (
            <div key={i} className="sq-color-swatch neu" style={{ background: c }} />
          ))}
          {colors.length === 0 && tileImage && (
            <div className="sq-colors__loading">
              <div className="canvas-spinner" style={{ width: 16, height: 16, borderWidth: 2 }} />
            </div>
          )}
        </div>
      </div>

      <div className="sq-divider" />

      <div className="sq-action-bar">
        <button
          className={`sq-done-btn ${isCompleted ? 'undone' : 'btn-primary'}`}
          onClick={handleToggle}
        >
          {isCompleted ? `↩ ${t.markUndone}` : `✓ ${t.markDone}`}
        </button>

        <div className="sq-nav-row">
          <button
            className="btn-secondary sq-nav-btn"
            disabled={!canPrev}
            onClick={() => slideTo('prev')}
          >
            ← {t.prev}
          </button>
          <button
            className="btn-secondary sq-nav-btn"
            disabled={!canNext}
            onClick={() => slideTo('next')}
          >
            {t.next} →
          </button>
        </div>
      </div>

      <style>{`
        .sq-pos-bar {
          display: flex; justify-content: space-between; align-items: center;
          padding: 8px 16px; flex-shrink: 0;
        }
        .sq-pos-bar__pos, .sq-pos-bar__count { font-size: 12px; color: var(--label-tertiary); font-variant-numeric: tabular-nums; }
        .sq-tile-area {
          flex: 1; display: flex; align-items: center; justify-content: center;
          padding: 0 16px; overflow: hidden; position: relative; touch-action: pan-y;
        }
        .sq-tile-inner { width: 100%; max-height: 100%; display: flex; align-items: center; justify-content: center; }
        .sq-tile-img {
          width: 100%; max-height: 100%; object-fit: contain;
          border-radius: 14px; display: block;
          border: 0.5px solid var(--glass-border);
          box-shadow: 0 8px 24px rgba(99,102,241,0.15);
          transition: border-color 0.2s, box-shadow 0.2s;
        }
        .sq-tile-img.done {
          border-color: var(--green); border-width: 2px;
          box-shadow: 0 8px 24px rgba(34,197,94,0.25);
        }
        .sq-tile-placeholder {
          width: 100%; aspect-ratio: 1; border-radius: 14px;
          display: flex; align-items: center; justify-content: center;
        }
        .sq-swipe-hint {
          position: absolute; bottom: 12px; left: 50%; transform: translateX(-50%);
          display: flex; gap: 12px; padding: 8px 16px; font-size: 13px;
          color: var(--label-secondary); white-space: nowrap; animation: fadeIn 0.3s ease;
        }
        .sq-done-badge {
          display: flex; align-items: center; justify-content: center; gap: 6px;
          margin: 4px 16px; padding: 7px 16px; color: var(--green);
          background: rgba(34,197,94,0.1); border: 0.5px solid rgba(34,197,94,0.3);
          border-radius: 100px; font-size: 14px; font-weight: 600; flex-shrink: 0;
        }
        .sq-colors { padding: 8px 16px; flex-shrink: 0; }
        .sq-colors__label { font-size: 12px; color: var(--label-tertiary); margin-bottom: 8px; }
        .sq-colors__row { display: flex; gap: 10px; align-items: center; min-height: 36px; }
        .sq-colors__loading { display: flex; align-items: center; }
        .sq-color-swatch {
          width: 34px; height: 34px; border-radius: 50%;
          border: 0.5px solid var(--glass-border); flex-shrink: 0;
        }
        .sq-divider { height: 0.5px; background: var(--glass-border); flex-shrink: 0; }
        .sq-action-bar {
          padding: 12px 16px calc(var(--safe-bottom) + 12px);
          display: flex; flex-direction: column; gap: 10px; flex-shrink: 0;
          background: rgba(10,14,26,0.6); backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
        }
        .sq-done-btn {
          width: 100%; padding: 14px; border-radius: 14px;
          font-size: 16px; font-weight: 600; cursor: pointer;
          transition: transform 0.15s, background 0.15s; border: none;
        }
        .sq-done-btn.undone {
          background: rgba(34,197,94,0.1); border: 0.5px solid rgba(34,197,94,0.35);
          color: var(--green);
        }
        .sq-done-btn.undone:active { transform: scale(0.97); }
        .sq-nav-row { display: flex; gap: 10px; }
        .sq-nav-btn { flex: 1; }
        .canvas-spinner {
          width: 36px; height: 36px; border-radius: 50%;
          border: 3px solid rgba(255,255,255,0.1);
          border-top-color: var(--brand);
          animation: spin 0.8s linear infinite;
        }
        @keyframes spin { to { transform: rotate(360deg); } }
      `}</style>
    </div>
  )
}
