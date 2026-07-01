import { useState, useEffect, useRef, useCallback } from 'react'
import { loadTile } from '../utils/storage'
import RingProgress from './components/RingProgress'

const T = {
  en: {
    title: 'Canvas',
    back: 'Back',
    completed: 'completed',
    next: 'Next Square',
    allDone: 'All done!',
    tapHint: 'Tap a square to open it',
  },
  ru: {
    title: 'Холст',
    back: 'Назад',
    completed: 'готово',
    next: 'Следующая',
    allDone: 'Всё готово!',
    tapHint: 'Нажмите на клетку, чтобы открыть',
  },
}

export default function CanvasView({ lang, project, onBack, onOpenSquare, onSquareToggle }) {
  const t = T[lang]
  const canvasRef = useRef(null)
  const imgRef = useRef(null)
  const [displayImage, setDisplayImage] = useState(null)
  const [imgSize, setImgSize] = useState(null)
  const [showHint, setShowHint] = useState(false)
  const [showCelebration, setShowCelebration] = useState(false)
  const [celebTriggered, setCelebTriggered] = useState(false)

  const completedCount = project.squares.filter(s => s.isCompleted).length
  const totalCount = project.squares.length
  const allDone = completedCount === totalCount && totalCount > 0

  useEffect(() => {
    loadTile(project.id, 'display').then(url => {
      if (url) setDisplayImage(url)
    })
  }, [project.id])

  useEffect(() => {
    if (completedCount === 0) {
      const t = setTimeout(() => setShowHint(true), 1500)
      return () => clearTimeout(t)
    }
    setShowHint(false)
  }, [completedCount])

  useEffect(() => {
    if (allDone && !celebTriggered) {
      setCelebTriggered(true)
      setTimeout(() => setShowCelebration(true), 400)
    }
  }, [allDone, celebTriggered])

  const drawCanvas = useCallback(() => {
    const canvas = canvasRef.current
    const img = imgRef.current
    if (!canvas || !img || !img.complete) return

    const container = canvas.parentElement
    const containerW = container.clientWidth
    const containerH = container.clientHeight
    const imgAspect = img.naturalWidth / img.naturalHeight
    const conAspect = containerW / containerH

    let drawW, drawH
    if (imgAspect > conAspect) {
      drawW = containerW
      drawH = containerW / imgAspect
    } else {
      drawH = containerH
      drawW = containerH * imgAspect
    }
    const drawX = (containerW - drawW) / 2
    const drawY = (containerH - drawH) / 2

    canvas.width = containerW
    canvas.height = containerH

    const ctx = canvas.getContext('2d')
    ctx.clearRect(0, 0, containerW, containerH)

    // Draw image
    ctx.drawImage(img, drawX, drawY, drawW, drawH)

    // Draw grid
    const cellW = drawW / project.gridCols
    const cellH = drawH / project.gridRows
    const lineW = Math.max(0.5, Math.min(cellW, cellH) * 0.02)

    ctx.strokeStyle = 'rgba(255,255,255,0.4)'
    ctx.lineWidth = lineW

    for (let col = 1; col < project.gridCols; col++) {
      ctx.beginPath()
      ctx.moveTo(drawX + col * cellW, drawY)
      ctx.lineTo(drawX + col * cellW, drawY + drawH)
      ctx.stroke()
    }
    for (let row = 1; row < project.gridRows; row++) {
      ctx.beginPath()
      ctx.moveTo(drawX, drawY + row * cellH)
      ctx.lineTo(drawX + drawW, drawY + row * cellH)
      ctx.stroke()
    }

    // Border
    ctx.strokeStyle = 'rgba(255,255,255,0.65)'
    ctx.lineWidth = lineW * 1.5
    ctx.strokeRect(drawX, drawY, drawW, drawH)

    // Completed overlays
    const checkSize = Math.min(cellW, cellH) * 0.35
    project.squares.filter(s => s.isCompleted).forEach(sq => {
      const x = drawX + sq.col * cellW
      const y = drawY + sq.row * cellH
      ctx.fillStyle = 'rgba(34,197,94,0.18)'
      ctx.fillRect(x, y, cellW, cellH)

      // Checkmark
      ctx.strokeStyle = '#22C55E'
      ctx.lineWidth = checkSize * 0.15
      ctx.lineCap = 'round'
      ctx.lineJoin = 'round'
      const cx = x + cellW / 2, cy = y + cellH / 2
      ctx.beginPath()
      ctx.moveTo(cx - checkSize * 0.3, cy)
      ctx.lineTo(cx - checkSize * 0.05, cy + checkSize * 0.3)
      ctx.lineTo(cx + checkSize * 0.4, cy - checkSize * 0.25)
      ctx.stroke()
    })

    setImgSize({ drawX, drawY, drawW, drawH, cellW, cellH })
  }, [project])

  const handleCanvasClick = useCallback((e) => {
    if (!imgSize) return
    const rect = canvasRef.current.getBoundingClientRect()
    const x = (e.clientX || e.touches?.[0]?.clientX) - rect.left
    const y = (e.clientY || e.touches?.[0]?.clientY) - rect.top
    const { drawX, drawY, drawW, drawH, cellW, cellH } = imgSize

    if (x < drawX || x > drawX + drawW || y < drawY || y > drawY + drawH) return

    const col = Math.min(Math.floor((x - drawX) / cellW), project.gridCols - 1)
    const row = Math.min(Math.floor((y - drawY) / cellH), project.gridRows - 1)
    if (row < 0 || col < 0) return

    setShowHint(false)
    const idx = row * project.gridCols + col
    onOpenSquare(idx)
  }, [imgSize, project, onOpenSquare])

  const firstUncompletedIdx = project.squares.findIndex(s => !s.isCompleted)

  return (
    <div className="view anim-slide-right">
      <nav className="nav-bar">
        <button className="nav-btn" onClick={onBack}>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <polyline points="15 18 9 12 15 6"/>
          </svg>
        </button>
        <h1 className="nav-title">{project.name}</h1>
        <div style={{ minWidth: 44 }} />
      </nav>

      <div
        className="canvas-area"
        style={{ flex: 1, position: 'relative', background: 'rgba(8,22,45,0.92)', overflow: 'hidden' }}
      >
        {displayImage && (
          <img
            ref={imgRef}
            src={displayImage}
            alt=""
            style={{ display: 'none' }}
            onLoad={drawCanvas}
          />
        )}
        <canvas
          ref={canvasRef}
          style={{ width: '100%', height: '100%', display: 'block', touchAction: 'none' }}
          onClick={handleCanvasClick}
          onTouchEnd={handleCanvasClick}
        />
        {!displayImage && (
          <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <div className="canvas-spinner" />
          </div>
        )}
        {showHint && completedCount === 0 && (
          <div className="canvas-hint glass">
            <span>{t.tapHint}</span>
          </div>
        )}
      </div>

      <div className="bottom-bar canvas-bottom">
        <RingProgress progress={project.progress || 0} allDone={allDone} size={36} />
        <div className="canvas-bottom__info">
          <span className="canvas-bottom__count">{completedCount} / {totalCount}</span>
          <span className="canvas-bottom__label">{t.completed}</span>
        </div>
        <div style={{ flex: 1 }} />
        {allDone ? (
          <div className="canvas-all-done">
            <span>✓</span>
            <span>{t.allDone}</span>
          </div>
        ) : (
          <button
            className="btn-primary canvas-next-btn"
            disabled={firstUncompletedIdx < 0}
            onClick={() => firstUncompletedIdx >= 0 && onOpenSquare(firstUncompletedIdx)}
          >
            {t.next}
          </button>
        )}
      </div>

      {showCelebration && (
        <CelebrationOverlay
          lang={lang}
          totalCount={totalCount}
          onDismiss={() => setShowCelebration(false)}
        />
      )}

      <style>{`
        .canvas-hint {
          position: absolute; bottom: 16px; left: 50%; transform: translateX(-50%);
          padding: 8px 16px; font-size: 13px; color: var(--label-primary);
          white-space: nowrap; animation: fadeIn 0.3s ease;
        }
        .canvas-spinner {
          width: 36px; height: 36px; border-radius: 50%;
          border: 3px solid rgba(127,205,255,0.2);
          border-top-color: var(--brand);
          animation: spin 0.8s linear infinite;
        }
        @keyframes spin { to { transform: rotate(360deg); } }
        .canvas-bottom { gap: 10px; }
        .canvas-bottom__info { display: flex; flex-direction: column; }
        .canvas-bottom__count { font-size: 17px; font-weight: 700; font-variant-numeric: tabular-nums; }
        .canvas-bottom__label { font-size: 11px; color: var(--label-tertiary); }
        .canvas-all-done {
          display: flex; align-items: center; gap: 6px;
          color: var(--green); font-weight: 600; font-size: 15px;
        }
        .canvas-next-btn { width: auto; padding: 11px 20px; font-size: 15px; }
      `}</style>
    </div>
  )
}

function CelebrationOverlay({ lang, totalCount, onDismiss }) {
  const isRu = lang === 'ru'
  const [appeared, setAppeared] = useState(false)

  useEffect(() => {
    requestAnimationFrame(() => requestAnimationFrame(() => setAppeared(true)))
    const t = setTimeout(onDismiss, 6000)
    return () => clearTimeout(t)
  }, [onDismiss])

  return (
    <div className="celeb-overlay" onClick={onDismiss}>
      <div className="celeb-content" onClick={e => e.stopPropagation()}>
        <div className={`celeb-icon ${appeared ? 'appeared' : ''}`}>
          <div className="celeb-ring r1" />
          <div className="celeb-ring r2" />
          <div className="celeb-ring r3" />
          <span className="celeb-check">✓</span>
        </div>
        <div className={`celeb-text ${appeared ? 'appeared' : ''}`}>
          <h2>{isRu ? 'Шедевр готов!' : 'Masterpiece Complete!'}</h2>
          <p>{isRu ? `Все ${totalCount} клеток завершены` : `All ${totalCount} squares done`}</p>
        </div>
        <button
          className={`btn-primary celeb-btn ${appeared ? 'appeared' : ''}`}
          onClick={onDismiss}
        >
          {isRu ? 'Отлично!' : 'Amazing!'}
        </button>
      </div>
      <style>{`
        .celeb-overlay {
          position: absolute; inset: 0; z-index: 100;
          background: rgba(5,20,50,0.88);
          backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
          display: flex; align-items: center; justify-content: center;
          animation: fadeIn 0.25s ease;
        }
        .celeb-content { display: flex; flex-direction: column; align-items: center; gap: 28px; padding: 32px; }
        .celeb-icon { position: relative; width: 96px; height: 96px; display: flex; align-items: center; justify-content: center; }
        .celeb-ring {
          position: absolute; border-radius: 50%;
          border: 1.5px solid rgba(34,197,94,0.15);
          animation: ringPulse 2s ease-out infinite;
        }
        .celeb-ring.r1 { width: 72px; height: 72px; animation-delay: 0s; }
        .celeb-ring.r2 { width: 96px; height: 96px; animation-delay: 0.35s; }
        .celeb-ring.r3 { width: 120px; height: 120px; animation-delay: 0.7s; }
        .celeb-check {
          font-size: 52px; line-height: 1;
          background: linear-gradient(135deg, #22C55E, #16A34A);
          -webkit-background-clip: text; -webkit-text-fill-color: transparent;
          transform: scale(0); opacity: 0; transition: transform 0.55s cubic-bezier(0.34,1.56,0.64,1) 0.1s, opacity 0.3s ease 0.1s;
        }
        .celeb-icon.appeared .celeb-check { transform: scale(1); opacity: 1; }
        .celeb-text { text-align: center; opacity: 0; transform: translateY(16px); transition: opacity 0.4s ease 0.28s, transform 0.4s ease 0.28s; }
        .celeb-text.appeared { opacity: 1; transform: translateY(0); }
        .celeb-text h2 { font-size: 22px; font-weight: 700; }
        .celeb-text p { font-size: 15px; color: var(--label-secondary); margin-top: 6px; }
        .celeb-btn { width: auto; padding: 14px 48px; opacity: 0; transition: opacity 0.3s ease 0.5s; }
        .celeb-btn.appeared { opacity: 1; }
        @keyframes ringPulse {
          0% { transform: scale(1); opacity: 0.3; }
          100% { transform: scale(2.2); opacity: 0; }
        }
      `}</style>
    </div>
  )
}
