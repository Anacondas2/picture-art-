const DB_NAME = 'picture-art'
const DB_VERSION = 1

function openDB() {
  return new Promise((resolve, reject) => {
    const req = indexedDB.open(DB_NAME, DB_VERSION)
    req.onupgradeneeded = e => {
      const db = e.target.result
      if (!db.objectStoreNames.contains('projects')) {
        db.createObjectStore('projects', { keyPath: 'id' })
      }
      if (!db.objectStoreNames.contains('tiles')) {
        db.createObjectStore('tiles')
      }
    }
    req.onsuccess = e => resolve(e.target.result)
    req.onerror = e => reject(e.target.error)
  })
}

export async function saveProject(project) {
  const db = await openDB()
  return new Promise((resolve, reject) => {
    const tx = db.transaction('projects', 'readwrite')
    tx.objectStore('projects').put(project)
    tx.oncomplete = () => resolve()
    tx.onerror = e => reject(e.target.error)
  })
}

export async function loadAllProjects() {
  const db = await openDB()
  return new Promise((resolve, reject) => {
    const tx = db.transaction('projects', 'readonly')
    const req = tx.objectStore('projects').getAll()
    req.onsuccess = () =>
      resolve((req.result || []).sort((a, b) => b.createdAt - a.createdAt))
    req.onerror = e => reject(e.target.error)
  })
}

export async function deleteProject(id) {
  const db = await openDB()
  return new Promise((resolve, reject) => {
    const tx = db.transaction(['projects', 'tiles'], 'readwrite')
    const tileStore = tx.objectStore('tiles')

    // Delete tiles by iterating with a cursor (IDBKeyRange on composite keys)
    const prefix = `${id}:`
    const range = IDBKeyRange.bound(prefix, prefix + '￿')
    const cursor = tileStore.openCursor(range)
    cursor.onsuccess = e => {
      const c = e.target.result
      if (c) { c.delete(); c.continue() }
    }

    tx.objectStore('projects').delete(id)
    tx.oncomplete = () => resolve()
    tx.onerror = e => reject(e.target.error)
  })
}

export async function saveTile(projectId, key, dataUrl) {
  const db = await openDB()
  return new Promise((resolve, reject) => {
    const tx = db.transaction('tiles', 'readwrite')
    tx.objectStore('tiles').put(dataUrl, `${projectId}:${key}`)
    tx.oncomplete = () => resolve()
    tx.onerror = e => reject(e.target.error)
  })
}

export async function loadTile(projectId, key) {
  const db = await openDB()
  return new Promise((resolve, reject) => {
    const tx = db.transaction('tiles', 'readonly')
    const req = tx.objectStore('tiles').get(`${projectId}:${key}`)
    req.onsuccess = () => resolve(req.result || null)
    req.onerror = e => reject(e.target.error)
  })
}

export function generateId() {
  return `${Date.now()}-${Math.random().toString(36).slice(2, 9)}`
}
