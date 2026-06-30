export async function applyStyleToImage(imageDataUrl, prompt, apiKey, onProgress) {
  onProgress?.(5)

  const blob = await (await fetch(imageDataUrl)).blob()
  const formData = new FormData()
  formData.append('image', blob, 'image.jpg')
  formData.append('prompt', prompt)
  formData.append('output_format', 'jpeg')
  formData.append('fidelity', '0.65')

  onProgress?.(15)

  const res = await fetch(
    'https://api.stability.ai/v2beta/stable-image/control/style',
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        Accept: 'image/*',
      },
      body: formData,
    }
  )

  onProgress?.(75)

  if (!res.ok) {
    const msg = await res.text().catch(() => res.statusText)
    throw new Error(`Stability AI: ${res.status} — ${msg}`)
  }

  const resultBlob = await res.blob()
  onProgress?.(90)

  return new Promise((resolve, reject) => {
    const reader = new FileReader()
    reader.onload = () => resolve(reader.result)
    reader.onerror = reject
    reader.readAsDataURL(resultBlob)
  })
}
