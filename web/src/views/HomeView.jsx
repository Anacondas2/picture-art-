import { useState } from 'react'
import { styleById, MEDIUMS } from '../data/drawingStyles'

const T = {
  en: {
    title: 'PictureArt',
    newProject: 'New Project',
    emptyBright: 'Turn photos into ',
    emptyGhost: 'art you can draw',
    emptyDesc: 'Photograph anything and get a calm, square-by-square drawing guide.',
    start: 'Start First Project',
    delete: 'Delete',
    done: 'done',
  },
  ru: {
    title: 'PictureArt',
    newProject: 'Новый проект',
    emptyBright: 'Преврати фото в ',
    emptyGhost: 'рисунок по клеткам',
    emptyDesc: 'Сфотографируй что угодно — получи спокойный пошаговый гид для рисования.',
    start: 'Начать первый проект',
    delete: 'Удалить',
    done: 'готово',
  },
}

function ProjectCard({ project, lang, onOpen, onDelete }) {
  const [showDel, setShowDel] = useState(false)
  const t = T[lang]
  const allDone = project.completedCount === project.totalCount && project.totalCount > 0
  const style = styleById(project.style)
  const medium = MEDIUMS.find(m => m.id === project.medium)
  const pct = project.totalCount > 0
    ? Math.round((project.completedCount / project.totalCount) * 100)
    : 0

  return (
    <div
      className="project-card glass"
      onClick={() => { if (!showDel) onOpen(project) }}
    >
      <div className="project-card__thumb">
        {project.thumbDataUrl ? (
          <img src={project.thumbDataUrl} alt="" />
        ) : (
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" width="22" height="22" style={{ color: 'var(--ink-4)' }}>
            <rect x="3" y="3" width="8" height="8" rx="2"/>
            <rect x="13" y="3" width="8" height="8" rx="2"/>
            <rect x="3" y="13" width="8" height="8" rx="2"/>
            <rect x="13" y="13" width="8" height="8" rx="2" fill="currentColor" stroke="none" opacity="0.6"/>
          </svg>
        )}
      </div>

      <div className="project-card__info">
        <p className="project-card__name">{project.name}</p>
        <p className="project-card__meta">
          {project.gridRows}×{project.gridCols}
          {style.id !== 'none' && <> · {lang === 'ru' ? style.nameRu : style.nameEn}</>}
          {medium && <> · {lang === 'ru' ? medium.nameRu : medium.nameEn}</>}
        </p>
      </div>

      <div className="project-card__progress" aria-label={`${project.completedCount} of ${project.totalCount} ${t.done}`}>
        <span className={`project-card__pct${allDone ? ' all-done' : ''}`}>
          {allDone ? '✓' : `${pct}`}
        </span>
        {!allDone && <span className="project-card__pct-sign">%</span>}
      </div>

      <button
        className="btn-icon project-card__more"
        onClick={e => { e.stopPropagation(); setShowDel(v => !v) }}
        aria-label="Options"
      >
        <svg viewBox="0 0 24 24" fill="currentColor" width="18" height="18">
          <circle cx="12" cy="5" r="1.4"/><circle cx="12" cy="12" r="1.4"/><circle cx="12" cy="19" r="1.4"/>
        </svg>
      </button>

      {showDel && (
        <button
          className="project-card__del-btn"
          onClick={e => { e.stopPropagation(); onDelete(project.id); setShowDel(false) }}
        >
          {t.delete}
        </button>
      )}
    </div>
  )
}

export default function HomeView({ lang, projects, onNewProject, onOpenProject, onDeleteProject, onOpenSettings, hidden }) {
  const t = T[lang]

  return (
    <div className="view" style={{ display: hidden ? 'none' : undefined }}>
      <nav className="nav-bar">
        <div style={{ minWidth: 44 }} />
        <h1 className="nav-title">{t.title}</h1>
        <button className="nav-btn" onClick={onOpenSettings} aria-label="Settings">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round">
            <circle cx="12" cy="12" r="3"/>
            <path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M4.93 19.07l1.41-1.41M17.66 6.34l1.41-1.41"/>
          </svg>
        </button>
      </nav>

      <div className="scroll-area">
        {projects.length === 0 ? (
          <div className="home-empty">
            <h2 className="home-empty__heading anim-rise">
              <span className="home-empty__bright">{t.emptyBright}</span>
              <span className="home-empty__ghost">{t.emptyGhost}</span>
            </h2>
            <p className="home-empty__desc anim-rise" style={{ animationDelay: '0.1s' }}>{t.emptyDesc}</p>

            <div className="home-empty__pebbles anim-rise" style={{ animationDelay: '0.18s' }} aria-hidden="true">
              <div className="pebble pebble-a glass" />
              <div className="pebble pebble-b glass" />
              <div className="pebble pebble-c glass" />
            </div>

            <button className="btn-primary home-empty__cta anim-rise" style={{ animationDelay: '0.26s' }} onClick={onNewProject}>
              {t.start}
            </button>
          </div>
        ) : (
          <div className="project-list">
            {projects.map(p => (
              <ProjectCard key={p.id} project={p} lang={lang} onOpen={onOpenProject} onDelete={onDeleteProject} />
            ))}
          </div>
        )}
      </div>

      {projects.length > 0 && (
        <div className="home-fab-area">
          <button className="btn-primary" onClick={onNewProject}>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" width="16" height="16">
              <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
            </svg>
            {t.newProject}
          </button>
        </div>
      )}

      <style>{`
        .project-list { padding: 18px 18px 8px; display: flex; flex-direction: column; gap: 12px; }

        .project-card {
          display: flex; align-items: center; gap: 14px;
          padding: 18px 20px; position: relative; cursor: pointer;
          transition: transform 0.3s cubic-bezier(0.16,1,0.3,1);
        }
        .project-card:active { transform: scale(0.98); }

        .project-card__thumb {
          width: 50px; height: 50px; border-radius: 18px;
          overflow: hidden; flex-shrink: 0;
          background: rgba(255,255,255,0.40);
          display: flex; align-items: center; justify-content: center;
        }
        .project-card__thumb img { width: 100%; height: 100%; object-fit: cover; }

        .project-card__info { flex: 1; min-width: 0; }
        .project-card__name {
          font-family: 'Comfortaa', 'Inter', system-ui, sans-serif;
          font-size: 16px; font-weight: 600;
          color: var(--ink);
          white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        }
        .project-card__meta {
          font-size: 12px; font-weight: 400; color: var(--ink-4);
          margin-top: 4px;
          white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        }

        .project-card__progress {
          display: flex; align-items: baseline; flex-shrink: 0; gap: 1px;
        }
        .project-card__pct {
          font-family: 'Comfortaa', 'Inter', system-ui, sans-serif;
          font-size: 26px; font-weight: 300;
          color: var(--ink-2);
          font-variant-numeric: tabular-nums;
          line-height: 1;
        }
        .project-card__pct.all-done { color: var(--green); font-weight: 500; }
        .project-card__pct-sign {
          font-family: 'Comfortaa', 'Inter', system-ui, sans-serif;
          font-size: 12px; font-weight: 500;
          color: var(--ink-4);
        }

        .project-card__more { color: var(--ink-4); flex-shrink: 0; margin-right: -8px; }
        .project-card__del-btn {
          position: absolute; right: 62px; top: 50%; transform: translateY(-50%);
          background: rgba(255,255,255,0.85);
          border: 1px solid rgba(217,54,54,0.30);
          color: var(--red);
          border-radius: 100px; padding: 9px 18px;
          font-family: 'Comfortaa', 'Inter', system-ui, sans-serif;
          font-size: 12px; font-weight: 600;
          cursor: pointer; white-space: nowrap; touch-action: manipulation;
          box-shadow: 0 6px 20px rgba(60,100,130,0.20);
        }

        /* ── Empty state — misty hero ── */
        .home-empty {
          padding: 46px 30px 32px;
          display: flex; flex-direction: column; align-items: flex-start;
        }
        .home-empty__heading {
          font-family: 'Comfortaa', 'Inter', system-ui, sans-serif;
          font-size: clamp(32px, 8.8vw, 42px);
          font-weight: 400;
          letter-spacing: 0.005em;
          line-height: 1.28;
          margin-bottom: 16px;
          max-width: 11em;
        }
        .home-empty__bright { color: rgba(255,255,255,0.97); }
        .home-empty__ghost  { color: rgba(255,255,255,0.55); }

        .home-empty__desc {
          font-size: 14px; font-weight: 400;
          color: rgba(255,255,255,0.75);
          line-height: 1.65;
          max-width: 280px;
          margin-bottom: 34px;
        }

        .home-empty__pebbles {
          position: relative;
          width: 100%; height: 150px;
          margin-bottom: 34px;
        }
        .pebble { position: absolute; }
        .pebble-a {
          width: 108px; height: 96px;
          left: 4%; top: 26px;
          border-radius: 46% 54% 52% 48% / 55% 48% 52% 45%;
          transform: rotate(-7deg);
        }
        .pebble-b {
          width: 128px; height: 108px;
          left: 33%; top: 0;
          border-radius: 52% 48% 47% 53% / 46% 55% 45% 54%;
          background: rgba(255,255,255,0.42);
        }
        .pebble-c {
          width: 100px; height: 88px;
          right: 5%; top: 40px;
          border-radius: 48% 52% 55% 45% / 52% 46% 54% 48%;
          transform: rotate(6deg);
        }

        .home-empty__cta { width: 100%; }

        .home-fab-area { padding: 12px 18px calc(var(--safe-bottom) + 18px); flex-shrink: 0; }
      `}</style>
    </div>
  )
}
