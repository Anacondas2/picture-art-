import { useState } from 'react'
import { styleById, MEDIUMS } from '../data/drawingStyles'

const T = {
  en: {
    title: 'PictureArt',
    newProject: 'New Project',
    emptyHeading1: 'Start',
    emptyHeading2: 'Drawing.',
    emptyDesc: 'Photograph anything — turn it into a grid-based drawing guide.',
    start: 'New Project',
    delete: 'Delete',
    done: 'done',
  },
  ru: {
    title: 'PictureArt',
    newProject: 'Новый проект',
    emptyHeading1: 'Начни',
    emptyHeading2: 'Рисовать.',
    emptyDesc: 'Сфотографируй что угодно — получи пошаговый гид для рисования.',
    start: 'Новый проект',
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
          <span className="project-card__emoji">{style.emoji}</span>
        )}
      </div>

      <div className="project-card__info">
        <p className="project-card__name">{project.name}</p>
        <p className="project-card__dims">{project.gridRows}×{project.gridCols}</p>
        {(style.id !== 'none' || medium) && (
          <p className="project-card__tags">
            {style.id !== 'none' && <span>{lang === 'ru' ? style.nameRu : style.nameEn}</span>}
            {medium && <span>{lang === 'ru' ? medium.nameRu : medium.nameEn}</span>}
          </p>
        )}
      </div>

      <div className="project-card__progress" aria-label={`${project.completedCount} of ${project.totalCount} ${t.done}`}>
        <span className={`project-card__fraction${allDone ? ' all-done' : ''}`}>
          {allDone ? '✓' : `${pct}%`}
        </span>
        <span className="project-card__sub">
          {project.completedCount}/{project.totalCount}
        </span>
      </div>

      <button
        className="btn-icon project-card__more"
        onClick={e => { e.stopPropagation(); setShowDel(v => !v) }}
        aria-label="Options"
      >
        <svg viewBox="0 0 24 24" fill="currentColor" width="18" height="18">
          <circle cx="12" cy="5" r="1.5"/><circle cx="12" cy="12" r="1.5"/><circle cx="12" cy="19" r="1.5"/>
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
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
            <circle cx="12" cy="12" r="3"/>
            <path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M4.93 19.07l1.41-1.41M17.66 6.34l1.41-1.41"/>
          </svg>
        </button>
      </nav>

      <div className="scroll-area">
        {projects.length === 0 ? (
          <div className="home-empty">
            <div className="home-empty__mark" aria-hidden="true">
              <svg viewBox="0 0 80 80" fill="none">
                <rect x="2"  y="2"  width="34" height="34" rx="5" stroke="currentColor" strokeWidth="1.5"/>
                <rect x="44" y="2"  width="34" height="34" rx="5" stroke="currentColor" strokeWidth="1.5"/>
                <rect x="2"  y="44" width="34" height="34" rx="5" stroke="currentColor" strokeWidth="1.5"/>
                <rect x="44" y="44" width="34" height="34" rx="5" fill="currentColor" opacity="0.9"/>
              </svg>
            </div>
            <h2 className="home-empty__heading">
              <span className="home-empty__line1">{t.emptyHeading1}</span>
              <span className="home-empty__line2">{t.emptyHeading2}</span>
            </h2>
            <p className="home-empty__desc">{t.emptyDesc}</p>
            <button className="btn-primary home-empty__cta" onClick={onNewProject}>
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" width="16" height="16">
                <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
              </svg>
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
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" width="16" height="16">
              <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
            </svg>
            {t.newProject}
          </button>
        </div>
      )}

      <style>{`
        .project-list { padding: 16px 16px 8px; display: flex; flex-direction: column; gap: 10px; }

        .project-card {
          display: flex; align-items: center; gap: 14px;
          padding: 16px 18px; position: relative; cursor: pointer;
          transition: transform 0.2s cubic-bezier(0.16,1,0.3,1);
        }
        .project-card:active { transform: scale(0.985); }

        .project-card__thumb {
          width: 48px; height: 48px; border-radius: 12px;
          overflow: hidden; flex-shrink: 0;
          background: rgba(255,255,255,0.28);
          display: flex; align-items: center; justify-content: center;
        }
        .project-card__thumb img { width: 100%; height: 100%; object-fit: cover; }
        .project-card__emoji { font-size: 22px; }

        .project-card__info { flex: 1; min-width: 0; }
        .project-card__name {
          font-family: 'Syne', system-ui, sans-serif;
          font-size: 17px; font-weight: 700; letter-spacing: -0.025em;
          color: var(--ink-2);
          white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        }
        .project-card__dims {
          font-family: 'Syne', system-ui, sans-serif;
          font-size: 12px; font-weight: 800; letter-spacing: 0.01em;
          color: var(--ink-4); margin-top: 3px;
        }
        .project-card__tags {
          display: flex; gap: 6px; margin-top: 3px;
          font-size: 11px; font-weight: 500; color: var(--ink-4); overflow: hidden;
        }
        .project-card__tags span { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

        .project-card__progress { display: flex; flex-direction: column; align-items: flex-end; flex-shrink: 0; gap: 2px; }
        .project-card__fraction {
          font-family: 'Syne', system-ui, sans-serif;
          font-size: 22px; font-weight: 800; letter-spacing: -0.05em;
          color: var(--ink-2); font-variant-numeric: tabular-nums; line-height: 1;
        }
        .project-card__fraction.all-done { color: #14c87c; }
        .project-card__sub {
          font-family: 'Syne', system-ui, sans-serif;
          font-size: 10px; font-weight: 700; letter-spacing: 0.04em;
          color: var(--ink-4); font-variant-numeric: tabular-nums;
        }
        .project-card__more { color: var(--ink-4); flex-shrink: 0; margin-right: -6px; }
        .project-card__del-btn {
          position: absolute; right: 60px; top: 50%; transform: translateY(-50%);
          background: rgba(239,68,68,0.12); border: 1px solid rgba(239,68,68,0.35);
          color: #ef4444; border-radius: 10px; padding: 7px 14px;
          font-family: 'Syne', system-ui, sans-serif;
          font-size: 12px; font-weight: 700; letter-spacing: 0.04em; text-transform: uppercase;
          cursor: pointer; white-space: nowrap; touch-action: manipulation;
        }

        .home-empty { padding: 52px 28px 32px; display: flex; flex-direction: column; align-items: flex-start; }
        .home-empty__mark { color: rgba(255,255,255,0.26); margin-bottom: 36px; }
        .home-empty__mark svg { width: 60px; height: 60px; }
        .home-empty__heading { display: flex; flex-direction: column; margin-bottom: 18px; }
        .home-empty__line1 {
          font-family: 'Syne', system-ui, sans-serif;
          font-size: clamp(52px, 14vw, 80px); font-weight: 800;
          letter-spacing: -0.045em; line-height: 0.92;
          color: rgba(255,255,255,0.94);
        }
        .home-empty__line2 {
          font-family: 'Syne', system-ui, sans-serif;
          font-size: clamp(52px, 14vw, 80px); font-weight: 800;
          letter-spacing: -0.045em; line-height: 1.0;
          color: rgba(255,255,255,0.42);
        }
        .home-empty__desc {
          font-size: 15px; font-weight: 400;
          color: rgba(255,255,255,0.60); line-height: 1.6;
          max-width: 290px; margin-bottom: 44px;
        }
        .home-empty__cta { width: auto; padding: 16px 36px; }

        .home-fab-area { padding: 12px 16px calc(var(--safe-bottom) + 16px); flex-shrink: 0; }
      `}</style>
    </div>
  )
}
