export default function RingProgress({ progress = 0, allDone = false, size = 36 }) {
  const r = (size - 4) / 2
  const circ = 2 * Math.PI * r
  const offset = circ - Math.min(Math.max(progress, 0), 1) * circ
  const cx = size / 2
  const cy = size / 2

  return (
    <svg
      className="ring-progress"
      width={size}
      height={size}
      viewBox={`0 0 ${size} ${size}`}
      style={{ transform: 'rotate(-90deg)' }}
    >
      <circle
        cx={cx} cy={cy} r={r}
        fill="none"
        stroke="rgba(255,255,255,0.1)"
        strokeWidth="3"
      />
      <circle
        cx={cx} cy={cy} r={r}
        fill="none"
        stroke={allDone ? '#22C55E' : '#6366F1'}
        strokeWidth="3"
        strokeLinecap="round"
        strokeDasharray={circ}
        strokeDashoffset={offset}
        style={{ transition: 'stroke-dashoffset 0.5s ease, stroke 0.3s ease' }}
      />
      <text
        x={cx} y={cy}
        textAnchor="middle"
        dominantBaseline="central"
        fill={allDone ? '#22C55E' : 'rgba(255,255,255,0.5)'}
        fontSize={size * 0.22}
        fontWeight="600"
        style={{ transform: `rotate(90deg) translate(0, 0)`, transformOrigin: `${cx}px ${cy}px` }}
      >
        {allDone ? '✓' : `${Math.round(progress * 100)}`}
      </text>
    </svg>
  )
}
