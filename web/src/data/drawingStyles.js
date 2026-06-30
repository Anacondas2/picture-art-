export const STYLES = [
  {
    id: 'none',
    nameEn: 'No Style',
    nameRu: 'Без стиля',
    color: '#8899AA',
    emoji: '📷',
    prompt: '',
    compatibleMediums: ['brush', 'dryBrush', 'pencil', 'coloredPencil', 'marker', 'chalk'],
  },
  {
    id: 'gouache',
    nameEn: 'Gouache',
    nameRu: 'Гуашь',
    color: '#F073AD',
    emoji: '🎨',
    prompt: 'gouache painting, flat opaque matte colors, bold shapes, illustration, children book art style',
    compatibleMediums: ['brush', 'dryBrush'],
  },
  {
    id: 'watercolor',
    nameEn: 'Watercolor',
    nameRu: 'Акварель',
    color: '#38BCEF',
    emoji: '💧',
    prompt: 'watercolor painting, transparent washes, soft wet edges, blooming pigment, luminous white paper showing through',
    compatibleMediums: ['brush', 'dryBrush'],
  },
  {
    id: 'oilPaint',
    nameEn: 'Oil Paint',
    nameRu: 'Масло',
    color: '#A878F3',
    emoji: '🖼️',
    prompt: 'oil painting, thick impasto texture, rich saturated colors, visible brushstrokes, classical realism',
    compatibleMediums: ['brush', 'dryBrush'],
  },
  {
    id: 'acrylic',
    nameEn: 'Acrylic',
    nameRu: 'Акрил',
    color: '#33D49A',
    emoji: '🎭',
    prompt: 'acrylic painting, vibrant colors, smooth or textured brushwork, modern art style',
    compatibleMediums: ['brush', 'dryBrush', 'marker'],
  },
  {
    id: 'pencilSketch',
    nameEn: 'Pencil Sketch',
    nameRu: 'Карандаш',
    color: '#B8C6D6',
    emoji: '✏️',
    prompt: 'graphite pencil sketch, black and white only, detailed crosshatching and hatching, no color fills',
    compatibleMediums: ['pencil', 'coloredPencil'],
  },
  {
    id: 'coloredPencil',
    nameEn: 'Colored Pencil',
    nameRu: 'Цветной карандаш',
    color: '#6366F1',
    emoji: '🖊️',
    prompt: 'colored pencil drawing, fine detailed linework, layered color strokes, waxy texture, illustration',
    compatibleMediums: ['coloredPencil', 'pencil'],
  },
  {
    id: 'charcoal',
    nameEn: 'Charcoal',
    nameRu: 'Уголь',
    color: '#C7CDD6',
    emoji: '◾',
    prompt: 'charcoal drawing, deep blacks and soft grays, smudged shadows, dramatic contrast, expressive marks',
    compatibleMediums: ['chalk', 'pencil'],
  },
  {
    id: 'pastel',
    nameEn: 'Pastel',
    nameRu: 'Пастель',
    color: '#F7A1DC',
    emoji: '🌸',
    prompt: 'soft pastel drawing, chalky powdery texture, blended colors, impressionist style, muted tones',
    compatibleMediums: ['chalk', 'coloredPencil'],
  },
  {
    id: 'ink',
    nameEn: 'Ink',
    nameRu: 'Тушь',
    color: '#EDEEF7',
    emoji: '🖋️',
    prompt: 'ink drawing, bold black outlines, brush pen or liner, high contrast, graphic novel style',
    compatibleMediums: ['marker', 'brush'],
  },
]

export const MEDIUMS = [
  { id: 'brush',        nameEn: 'Brush',                nameRu: 'Кисть' },
  { id: 'dryBrush',      nameEn: 'Dry Brush',            nameRu: 'Сухая кисть' },
  { id: 'pencil',        nameEn: 'Pencil',               nameRu: 'Карандаш' },
  { id: 'coloredPencil', nameEn: 'Colored Pencil',       nameRu: 'Цветной карандаш' },
  { id: 'marker',        nameEn: 'Marker',               nameRu: 'Маркер' },
  { id: 'chalk',         nameEn: 'Chalk / Charcoal',     nameRu: 'Мел / Уголь' },
]

export const SKILL_LEVELS = [
  {
    id: 'beginner',
    nameEn: 'Beginner',
    nameRu: 'Начинающий',
    descEn: 'First steps in drawing',
    descRu: 'Первые шаги в рисовании',
    defaultGrid: 8,
    recommendedGrids: [8, 12],
    colorCount: 4,
    allowedStyles: ['none', 'pencilSketch', 'coloredPencil'],
    emoji: '🌱',
  },
  {
    id: 'intermediate',
    nameEn: 'Intermediate',
    nameRu: 'Средний',
    descEn: 'Improving my skills',
    descRu: 'Уже рисую, хочу развиваться',
    defaultGrid: 12,
    recommendedGrids: [12, 16, 20],
    colorCount: 6,
    allowedStyles: ['none', 'gouache', 'watercolor', 'pencilSketch', 'coloredPencil', 'charcoal', 'pastel'],
    emoji: '⚡',
  },
  {
    id: 'advanced',
    nameEn: 'Advanced',
    nameRu: 'Продвинутый',
    descEn: 'Experienced artist',
    descRu: 'Опытный художник',
    defaultGrid: 16,
    recommendedGrids: [16, 20, 24, 32],
    colorCount: 8,
    allowedStyles: STYLES.map(s => s.id),
    emoji: '🏆',
  },
]

export const GRID_OPTIONS = [6, 8, 10, 12, 14, 16, 18, 20, 24, 32]

// width/height in millimeters, matching PaperSize.swift
export const PAPER_SIZES = [
  { id: 'a5',          nameEn: 'A5',     nameRu: 'A5',     widthMM: 148, heightMM: 210 },
  { id: 'a4',          nameEn: 'A4',     nameRu: 'A4',     widthMM: 210, heightMM: 297 },
  { id: 'a3',          nameEn: 'A3',     nameRu: 'A3',     widthMM: 297, heightMM: 420 },
  { id: 'a2',          nameEn: 'A2',     nameRu: 'A2',     widthMM: 420, heightMM: 594 },
  { id: 'letter',      nameEn: 'Letter', nameRu: 'Letter', widthMM: 216, heightMM: 279 },
  { id: 'tabloid',     nameEn: 'Tabloid',nameRu: 'Tabloid',widthMM: 279, heightMM: 432 },
  { id: 'canvas20',    nameEn: 'Canvas', nameRu: 'Холст',  widthMM: 200, heightMM: 200, canvasLabel: '20×20' },
  { id: 'canvas30',    nameEn: 'Canvas', nameRu: 'Холст',  widthMM: 300, heightMM: 300, canvasLabel: '30×30' },
  { id: 'canvas40',    nameEn: 'Canvas', nameRu: 'Холст',  widthMM: 400, heightMM: 400, canvasLabel: '40×40' },
  { id: 'canvas50',    nameEn: 'Canvas', nameRu: 'Холст',  widthMM: 500, heightMM: 500, canvasLabel: '50×50' },
  { id: 'canvas30x40', nameEn: 'Canvas', nameRu: 'Холст',  widthMM: 300, heightMM: 400, canvasLabel: '30×40' },
  { id: 'canvas40x60', nameEn: 'Canvas', nameRu: 'Холст',  widthMM: 400, heightMM: 600, canvasLabel: '40×60' },
]

export function paperDisplayName(p, lang) {
  if (p.canvasLabel) {
    return lang === 'ru' ? `Холст ${p.canvasLabel} см` : `Canvas ${p.canvasLabel} cm`
  }
  const name = lang === 'ru' ? p.nameRu : p.nameEn
  const unit = lang === 'ru' ? 'мм' : 'mm'
  return `${name} (${p.widthMM}×${p.heightMM} ${unit})`
}

export function paperRecommendedGridSizes(p) {
  const minSide = Math.min(p.widthMM, p.heightMM)
  if (minSide < 180) return [6, 8]
  if (minSide < 260) return [8, 12]
  if (minSide < 350) return [12, 16]
  if (minSide < 450) return [16, 20]
  return [20, 24, 32]
}

export function paperDefaultGridSize(p) {
  return paperRecommendedGridSizes(p)[0] || 12
}

export function paperCellSize(p, rows, cols) {
  return { width: p.widthMM / cols, height: p.heightMM / rows }
}

export function paperCellSizeComment(p, rows, cols, lang) {
  const { width, height } = paperCellSize(p, rows, cols)
  const w = width.toFixed(1)
  const h = height.toFixed(1)
  return lang === 'ru'
    ? `Каждый квадратик: ${w}×${h} мм`
    : `Each square: ${w}×${h} mm`
}

export function paperDifficulty(p, rows, cols) {
  const { width, height } = paperCellSize(p, rows, cols)
  const minSide = Math.min(width, height)
  if (minSide >= 20) return 'easy'
  if (minSide >= 12) return 'medium'
  return 'hard'
}

export const DIFFICULTY_INFO = {
  easy:   { nameEn: 'Comfortable',  nameRu: 'Комфортно', color: '#22C55E' },
  medium: { nameEn: 'Moderate',     nameRu: 'Нормально', color: '#F59E0B' },
  hard:   { nameEn: 'Fine detail',  nameRu: 'Мелко',      color: '#EF4444' },
}

export function styleById(id) {
  return STYLES.find(s => s.id === id) || STYLES[0]
}

export function paperById(id) {
  return PAPER_SIZES.find(p => p.id === id) || PAPER_SIZES[1]
}
