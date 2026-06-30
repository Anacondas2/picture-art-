export const STYLES = [
  {
    id: 'none',
    nameEn: 'Original',
    nameRu: 'Оригинал',
    color: '#8899AA',
    emoji: '📷',
    prompt: null,
  },
  {
    id: 'pencilSketch',
    nameEn: 'Pencil Sketch',
    nameRu: 'Карандаш',
    color: '#B8C6D6',
    emoji: '✏️',
    prompt: 'pencil sketch drawing, graphite, fine linework, artistic, detailed',
  },
  {
    id: 'watercolor',
    nameEn: 'Watercolor',
    nameRu: 'Акварель',
    color: '#38BCEF',
    emoji: '💧',
    prompt: 'watercolor painting, soft transparent washes, wet on wet technique, artistic',
  },
  {
    id: 'gouache',
    nameEn: 'Gouache',
    nameRu: 'Гуашь',
    color: '#F073AD',
    emoji: '🎨',
    prompt: 'gouache painting, opaque matte colors, painterly, artistic illustration',
  },
  {
    id: 'oilPaint',
    nameEn: 'Oil Paint',
    nameRu: 'Масло',
    color: '#A878F3',
    emoji: '🖼️',
    prompt: 'oil painting, rich textured brushstrokes, impasto technique, old master style',
  },
  {
    id: 'acrylic',
    nameEn: 'Acrylic',
    nameRu: 'Акрил',
    color: '#33D49A',
    emoji: '🎭',
    prompt: 'acrylic painting, vibrant colors, layered paint, contemporary art style',
  },
  {
    id: 'coloredPencil',
    nameEn: 'Colored Pencil',
    nameRu: 'Цв. карандаш',
    color: '#6366F1',
    emoji: '🖊️',
    prompt: 'colored pencil drawing, visible hatching, rich color, detailed artistic',
  },
  {
    id: 'charcoal',
    nameEn: 'Charcoal',
    nameRu: 'Уголь',
    color: '#C7CDD6',
    emoji: '◾',
    prompt: 'charcoal drawing, dramatic shadows, high contrast, expressive marks',
  },
  {
    id: 'pastel',
    nameEn: 'Pastel',
    nameRu: 'Пастель',
    color: '#F7A1DC',
    emoji: '🌸',
    prompt: 'pastel chalk drawing, soft dreamy colors, blended textures, romantic artistic',
  },
  {
    id: 'ink',
    nameEn: 'Ink',
    nameRu: 'Тушь',
    color: '#EDEEF7',
    emoji: '🖋️',
    prompt: 'ink drawing, bold clean lines, high contrast black and white, artistic illustration',
  },
]

export const MEDIUMS = [
  { id: 'brush',     nameEn: 'Brush',    nameRu: 'Кисть' },
  { id: 'pencil',    nameEn: 'Pencil',   nameRu: 'Карандаш' },
  { id: 'pen',       nameEn: 'Pen',      nameRu: 'Ручка' },
  { id: 'charcoal',  nameEn: 'Charcoal', nameRu: 'Уголь' },
  { id: 'pastel',    nameEn: 'Pastel',   nameRu: 'Пастель' },
  { id: 'marker',    nameEn: 'Marker',   nameRu: 'Маркер' },
]

export const SKILL_LEVELS = [
  {
    id: 'beginner',
    nameEn: 'Beginner',
    nameRu: 'Начинающий',
    descEn: 'Simple grid',
    descRu: 'Простая сетка',
    defaultGrid: 8,
    emoji: '🌱',
  },
  {
    id: 'intermediate',
    nameEn: 'Intermediate',
    nameRu: 'Средний',
    descEn: 'Balanced detail',
    descRu: 'Умеренная детализация',
    defaultGrid: 12,
    emoji: '⚡',
  },
  {
    id: 'advanced',
    nameEn: 'Advanced',
    nameRu: 'Продвинутый',
    descEn: 'Fine detail',
    descRu: 'Высокая детализация',
    defaultGrid: 20,
    emoji: '🏆',
  },
]

export const GRID_OPTIONS = [6, 8, 10, 12, 14, 16, 18, 20, 24, 32]

export function styleById(id) {
  return STYLES.find(s => s.id === id) || STYLES[0]
}
