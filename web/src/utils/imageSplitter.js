export function splitImage(imageDataUrl, rows, cols) {
  return new Promise((resolve, reject) => {
    const img = new Image()
    img.onload = () => {
      const tileW = Math.floor(img.width / cols)
      const tileH = Math.floor(img.height / rows)
      const tiles = []

      for (let row = 0; row < rows; row++) {
        for (let col = 0; col < cols; col++) {
          const canvas = document.createElement('canvas')
          canvas.width = tileW
          canvas.height = tileH
          const ctx = canvas.getContext('2d')
          ctx.drawImage(img, col * tileW, row * tileH, tileW, tileH, 0, 0, tileW, tileH)
          tiles.push({ row, col, dataUrl: canvas.toDataURL('image/jpeg', 0.82) })
        }
      }
      resolve(tiles)
    }
    img.onerror = reject
    img.src = imageDataUrl
  })
}

export function resizeImage(dataUrl, maxW = 1024, maxH = 1024) {
  return new Promise((resolve, reject) => {
    const img = new Image()
    img.onload = () => {
      let w = img.width, h = img.height
      if (w > maxW || h > maxH) {
        const ratio = Math.min(maxW / w, maxH / h)
        w = Math.round(w * ratio)
        h = Math.round(h * ratio)
      }
      const canvas = document.createElement('canvas')
      canvas.width = w
      canvas.height = h
      canvas.getContext('2d').drawImage(img, 0, 0, w, h)
      resolve(canvas.toDataURL('image/jpeg', 0.9))
    }
    img.onerror = reject
    img.src = dataUrl
  })
}

export function loadImageFromFile(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader()
    reader.onload = e => resolve(e.target.result)
    reader.onerror = reject
    reader.readAsDataURL(file)
  })
}
