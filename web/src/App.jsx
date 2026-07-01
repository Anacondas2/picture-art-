import { useState, useEffect, useCallback } from 'react'
import { loadAllProjects, saveProject, deleteProject, generateId } from './utils/storage'
import HomeView from './views/HomeView'
import NewProjectSheet from './views/NewProjectSheet'
import CanvasView from './views/CanvasView'
import SquareDetailView from './views/SquareDetailView'
import SettingsView from './views/SettingsView'
import LanguageSelectionView from './views/LanguageSelectionView'

const LANG_KEY = 'appLang'

export default function App() {
  const [lang, setLang] = useState(() => localStorage.getItem(LANG_KEY) || null)
  const [view, setView] = useState('home') // home | canvas | squareDetail | settings
  const [projects, setProjects] = useState([])
  const [currentProject, setCurrentProject] = useState(null)
  const [currentSquareIdx, setCurrentSquareIdx] = useState(0)
  const [showNewProject, setShowNewProject] = useState(false)
  const [apiKey, setApiKey] = useState(() => localStorage.getItem('stabApiKey') || '')

  useEffect(() => {
    loadAllProjects().then(setProjects).catch(console.error)
  }, [])

  const handleSaveApiKey = useCallback((key) => {
    localStorage.setItem('stabApiKey', key)
    setApiKey(key)
  }, [])

  const handleSelectLang = useCallback((l) => {
    localStorage.setItem(LANG_KEY, l)
    setLang(l)
  }, [])

  const handleProjectCreated = useCallback(async (project) => {
    await saveProject(project)
    const updated = await loadAllProjects()
    setProjects(updated)
    setCurrentProject(project)
    setShowNewProject(false)
    setView('canvas')
  }, [])

  const handleOpenProject = useCallback((project) => {
    setCurrentProject(project)
    setView('canvas')
  }, [])

  const handleDeleteProject = useCallback(async (id) => {
    await deleteProject(id)
    const updated = await loadAllProjects()
    setProjects(updated)
    if (currentProject?.id === id) {
      setCurrentProject(null)
      setView('home')
    }
  }, [currentProject])

  const handleOpenSquare = useCallback((idx) => {
    setCurrentSquareIdx(idx)
    setView('squareDetail')
  }, [])

  const handleSquareToggle = useCallback(async (row, col) => {
    if (!currentProject) return
    const squares = currentProject.squares.map(sq =>
      sq.row === row && sq.col === col
        ? { ...sq, isCompleted: !sq.isCompleted }
        : sq
    )
    const completedCount = squares.filter(s => s.isCompleted).length
    const updated = {
      ...currentProject,
      squares,
      completedCount,
      progress: squares.length > 0 ? completedCount / squares.length : 0,
    }
    setCurrentProject(updated)
    await saveProject(updated)
    // also update in projects list
    setProjects(prev => prev.map(p => p.id === updated.id ? updated : p))
  }, [currentProject])

  const handleBack = useCallback(() => {
    if (view === 'squareDetail') setView('canvas')
    else if (view === 'canvas') { setView('home'); setCurrentProject(null) }
    else if (view === 'settings') setView('home')
  }, [view])

  if (!lang) {
    return <LanguageSelectionView onSelect={handleSelectLang} />
  }

  return (
    <div className="app">
      <div className="orb orb-1" />
      <div className="orb orb-2" />
      <div className="orb orb-3" />
      {/* Home is always rendered underneath (for smooth nav) */}
      <HomeView
        lang={lang}
        projects={projects}
        onNewProject={() => setShowNewProject(true)}
        onOpenProject={handleOpenProject}
        onDeleteProject={handleDeleteProject}
        onOpenSettings={() => setView('settings')}
        hidden={view !== 'home'}
      />

      {view === 'canvas' && currentProject && (
        <CanvasView
          key={currentProject.id}
          lang={lang}
          project={currentProject}
          onBack={handleBack}
          onOpenSquare={handleOpenSquare}
          onSquareToggle={handleSquareToggle}
        />
      )}

      {view === 'squareDetail' && currentProject && (
        <SquareDetailView
          key={`${currentProject.id}-${currentSquareIdx}`}
          lang={lang}
          project={currentProject}
          initialIndex={currentSquareIdx}
          onBack={() => setView('canvas')}
          onSquareToggle={handleSquareToggle}
        />
      )}

      {view === 'settings' && (
        <SettingsView
          lang={lang}
          apiKey={apiKey}
          onSaveApiKey={handleSaveApiKey}
          onChangeLang={handleSelectLang}
          onBack={handleBack}
        />
      )}

      {showNewProject && (
        <NewProjectSheet
          lang={lang}
          apiKey={apiKey}
          onClose={() => setShowNewProject(false)}
          onCreated={handleProjectCreated}
        />
      )}
    </div>
  )
}
