export function extractColors(imageDataUrl, count = 6) {
  return new Promise((resolve) => {
    const img = new Image()
    img.onload = () => {
      const size = 64
      const canvas = document.createElement('canvas')
      canvas.width = size
      canvas.height = size
      const ctx = canvas.getContext('2d')
      ctx.drawImage(img, 0, 0, size, size)
      const { data } = ctx.getImageData(0, 0, size, size)

      const buckets = new Map()
      const step = 4 * 4
      for (let i = 0; i < data.length; i += step) {
        const a = data[i + 3]
        if (a < 128) continue
        const r = data[i] >> 5
        const g = data[i + 1] >> 5
        const b = data[i + 2] >> 5
        const key = (r << 10) | (g << 5) | b
        buckets.set(key, (buckets.get(key) || 0) + 1)
      }

      const sorted = [...buckets.entries()]
        .sort((a, b) => b[1] - a[1])
        .slice(0, count)
        .map(([key]) => {
          const r = ((key >> 10) & 0x1f) * 8 + 4
          const g = ((key >> 5) & 0x1f) * 8 + 4
          const b = (key & 0x1f) * 8 + 4
          return `rgb(${r},${g},${b})`
        })

      resolve(sorted)
    }
    img.onerror = () => resolve([])
    img.src = imageDataUrl
    img.crossOrigin = 'anonymous'
  })
}
