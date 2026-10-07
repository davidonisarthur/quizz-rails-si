import { FINGER_LANDMARKS, MIDDLE_MCP, WRIST } from "gesture_recognition/hand_constants"

const EPSILON = 0.00001

export function distanceBetween(firstPoint, secondPoint) {
  if (!firstPoint || !secondPoint) return 0

  return Math.hypot(
    firstPoint.x - secondPoint.x,
    firstPoint.y - secondPoint.y,
    (firstPoint.z || 0) - (secondPoint.z || 0)
  )
}

export function palmScale(landmarks) {
  return Math.max(distanceBetween(landmarks?.[WRIST], landmarks?.[MIDDLE_MCP]), EPSILON)
}

export function normalizeDistance(landmarks, firstIndex, secondIndex, referenceDistance = palmScale(landmarks)) {
  return distanceBetween(landmarks?.[firstIndex], landmarks?.[secondIndex]) / Math.max(referenceDistance, EPSILON)
}

export function jointAngle(firstPoint, vertexPoint, lastPoint) {
  if (!firstPoint || !vertexPoint || !lastPoint) return 0

  const firstVector = [ firstPoint.x - vertexPoint.x, firstPoint.y - vertexPoint.y, (firstPoint.z || 0) - (vertexPoint.z || 0) ]
  const lastVector = [ lastPoint.x - vertexPoint.x, lastPoint.y - vertexPoint.y, (lastPoint.z || 0) - (vertexPoint.z || 0) ]
  const firstMagnitude = Math.hypot(...firstVector)
  const lastMagnitude = Math.hypot(...lastVector)

  if (firstMagnitude < EPSILON || lastMagnitude < EPSILON) return 0

  const cosine = firstVector.reduce((sum, coordinate, index) => sum + coordinate * lastVector[index], 0) / (firstMagnitude * lastMagnitude)
  return Math.acos(Math.min(1, Math.max(-1, cosine))) * (180 / Math.PI)
}

export function fingerMetrics(landmarks, fingerName) {
  const indices = FINGER_LANDMARKS[fingerName]
  if (!indices || !landmarks) return null

  const [ mcp, pip, dip, tip ] = indices
  const scale = palmScale(landmarks)

  return {
    tipToWrist: normalizeDistance(landmarks, WRIST, tip, scale),
    pipToWrist: normalizeDistance(landmarks, WRIST, pip, scale),
    pipAngle: jointAngle(landmarks[mcp], landmarks[pip], landmarks[tip]),
    dipAngle: jointAngle(landmarks[pip], landmarks[dip], landmarks[tip])
  }
}

export function isFingerExtended(landmarks, fingerName) {
  const metrics = fingerMetrics(landmarks, fingerName)
  if (!metrics) return false

  return metrics.pipAngle >= 155 &&
    metrics.dipAngle >= 150 &&
    metrics.tipToWrist > metrics.pipToWrist * 1.1
}

export function isFingerBent(landmarks, fingerName) {
  const metrics = fingerMetrics(landmarks, fingerName)
  if (!metrics) return false

  return metrics.pipAngle <= 130 ||
    metrics.dipAngle <= 130 ||
    metrics.tipToWrist <= metrics.pipToWrist * 1.06
}

export function fingerCompatibility(landmarks, fingerName, expectedState) {
  const metrics = fingerMetrics(landmarks, fingerName)
  if (!metrics) return 0

  if (expectedState === "extended") {
    const angleScore = Math.min(1, Math.max(0, (metrics.pipAngle - 120) / 60))
    const reachScore = Math.min(1, Math.max(0, (metrics.tipToWrist / Math.max(metrics.pipToWrist, EPSILON) - 0.9) / 0.3))
    return (angleScore + reachScore) / 2
  }

  const angleScore = Math.min(1, Math.max(0, (155 - metrics.pipAngle) / 55))
  const reachScore = Math.min(1, Math.max(0, (1.14 - metrics.tipToWrist / Math.max(metrics.pipToWrist, EPSILON)) / 0.22))
  return (angleScore + reachScore) / 2
}

export function approximateHandOrientation(landmarks) {
  const wrist = landmarks?.[WRIST]
  const middleMcp = landmarks?.[MIDDLE_MCP]
  if (!wrist || !middleMcp) return { direction: "unknown", upright: false, score: 0 }

  const dx = middleMcp.x - wrist.x
  const dy = middleMcp.y - wrist.y
  const magnitude = Math.hypot(dx, dy)
  if (magnitude < EPSILON) return { direction: "unknown", upright: false, score: 0 }

  const verticality = Math.abs(dy) / magnitude
  const upright = dy < 0 && verticality >= 0.62

  return {
    direction: dy < 0 ? "up" : "down",
    upright,
    score: upright ? verticality : 0
  }
}
