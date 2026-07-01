import { useState } from 'react'
import RingProgress from './components/RingProgress'
import { styleById, MEDIUMS } from '../data/drawingStyles'

const T = {
  en: {
    title: 'PictureArt',
    newProject: 'New Project',
    empty: 'No projects yet',
    emptyDesc: 'Photograph anything — turn it into a drawing guide',
    start: 'Start first project',
    delete: 'Delete',
    squares: 'squares',
    done: 'done',
  },
  ru: {
    title: 'PictureArt',
    newProject: 'Новый проект',
    empty: 'Проектов пока нет',
    emptyDesc: 'Сфотографируйте что угодно — превратите в гид для рисования',
    start: 'Начать первый проект',
    delete: 'Удалить',
    squares: 'клеток',
    done: 'готово',
  },
}

function ProjectCard({ project, lang, onOpen, onDelete }) {
  const [showDel, setShowDel] = useState(false)
  const t = T[lang]
  const allDone = project.completedCount === project.totalCount && project.totalCount > 0
  const style = styleById(project.style)
  const medium = MEDIUMS.find(m => m.id === project.medium)

  return (
    <div
      className="project-card glass"
      onClick={() => { if (!showDel) onOpen(project) }}
    >
      <div className="project-card__thumb">
        {project.thumbDataUrl ? (
          <img src={project.thumbDataUrl} alt="" />
        ) : (
          <div className="project-card__thumb-placeholder">
            <span>{style.emoji}</span>
          </div>
        )}
        <RingProgress progress={project.progress || 0} allDone={allDone} size={32} />
      </div>

      <div className="project-card__info">
        <p className="project-card__name">{project.name}</p>
        <p className="project-card__meta">
          {project.gridRows}×{project.gridCols} · {project.completedCount}/{project.totalCount} {t.done}
        </p>
        {(style.id !== 'none' || medium) && (
          <p className="project-card__tags">
            {style.id !== 'none' && (
              <span>{style.emoji} {lang === 'ru' ? style.nameRu : style.nameEn}</span>
            )}
            {medium && (
              <span>{lang === 'ru' ? medium.nameRu : medium.nameEn}</span>
            )}
          </p>
        )}
      </div>

      <button
        className="btn-icon project-card__more"
        onClick={e => { e.stopPropagation(); setShowDel(v => !v) }}
      >
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
          <circle cx="12" cy="5" r="1"/><circle cx="12" cy="12" r="1"/><circle cx="12" cy="19" r="1"/>
        </svg>
      </button>

      {showDel && (
        <button
          className="project-card__del-btn"
          onClick={e => { e.stopPropagation(); onDelete(project.id); setShowDel(false) }}
        >
          🗑 {t.delete}
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
            <div className="home-empty__icon glass">
              <svg viewBox="0 0 64 64" fill="none">
                <defs>
                  <linearGradient id="eg" x1="0" y1="0" x2="1" y2="1">
                    <stop offset="0%" stopColor="#0a84ff"/>
                    <stop offset="100%" stopColor="#0055cc"/>
                  </linearGradient>
                </defs>
                <rect x="8" y="8" width="22" height="22" rx="4" stroke="url(#eg)" strokeWidth="2" opacity="0.5"/>
                <rect x="34" y="8" width="22" height="22" rx="4" stroke="url(#eg)" strokeWidth="2" opacity="0.5"/>
                <rect x="8" y="34" width="22" height="22" rx="4" stroke="url(#eg)" strokeWidth="2" opacity="0.5"/>
                <rect x="34" y="34" width="22" height="22" rx="4" fill="url(#eg)" opacity="0.8"/>
                <path d="M41 46l5 5 10-11" stroke="white" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
            </div>
            <h2 className="home-empty__title">{t.empty}</h2>
            <p className="home-empty__desc">{t.emptyDesc}</p>
            <button className="btn-primary home-empty__cta" onClick={onNewProject}>
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" width="18" height="18">
                <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
              </svg>
              {t.start}
            </button>
          </div>
        ) : (
          <div className="project-list">
            {projects.map(p => (
              <ProjectCard
                key={p.id}
                project={p}
                lang={lang}
                onOpen={onOpenProject}
                onDelete={onDeleteProject}
              />
            ))}
          </div>
        )}
      </div>

      {projects.length > 0 && (
        <div className="home-fab-area">
          <button className="btn-primary" onClick={onNewProject}>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" width="18" height="18">
              <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
            </svg>
            {t.newProject}
          </button>
        </div>
      )}

      <style>{`
        .project-list { padding: 12px 16px; display: flex; flex-direction: column; gap: 10px; }
        .project-card {
          display: flex; align-items: center; gap: 12px;
          padding: 12px 14px; position: relative; cursor: pointer;
          transition: transform 0.12s; min-height: 72px;
        }
        .project-card:active { transform: scale(0.98); }
        .project-card__thumb {
          width: 52px; height: 52px; border-radius: 10px; overflow: hidden;
          flex-shrink: 0; position: relative; background: rgba(255,255,255,0.3);
        }
        .project-card__thumb img { width: 100%; height: 100%; object-fit: cover; }
        .project-card__thumb .ring-progress { position: absolute; bottom: -4px; right: -4px; }
        .project-card__thumb-placeholder {
          width: 100%; height: 100%; display: flex; align-items: center;
          justify-content: center; font-size: 24px;
        }
        .project-card__info { flex: 1; min-width: 0; }
        .project-card__name {
          font-size: 15px; font-weight: 600; color: var(--label-primary);
          white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        }
        .project-card__meta { font-size: 12px; color: var(--label-tertiary); margin-top: 2px; }
        .project-card__tags { display: flex; gap: 8px; margin-top: 3px; font-size: 11px; color: var(--label-secondary); }
        .project-card__more { color: var(--label-tertiary); flex-shrink: 0; }
        .project-card__del-btn {
          position: absolute; right: 56px; top: 50%; transform: translateY(-50%);
          background: rgba(239,68,68,0.15); border: 0.5px solid rgba(239,68,68,0.4);
          color: #EF4444; border-radius: 8px; padding: 6px 12px; font-size: 13px;
          cursor: pointer; white-space: nowrap;
        }
        .home-empty {
          display: flex; flex-direction: column; align-items: center;
          padding: 60px 32px 32px; gap: 16px; text-align: center;
        }
        .home-empty__icon {
          width: 100px; height: 100px; display: flex; align-items: center;
          justify-content: center; border-radius: 24px; padding: 18px;
          margin-bottom: 8px;
        }
        .home-empty__icon svg { width: 64px; height: 64px; }
        .home-empty__title { font-size: 20px; font-weight: 700; }
        .home-empty__desc { font-size: 14px; color: var(--label-secondary); line-height: 1.5; max-width: 260px; }
        .home-empty__cta { margin-top: 8px; width: auto; padding: 14px 32px; }
        .home-fab-area { padding: 0 16px calc(var(--safe-bottom) + 16px); flex-shrink: 0; }
      `}</style>
    </div>
  )
}
