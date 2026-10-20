import { HAND_LANDMARK_COUNT } from "gesture_recognition/hand_constants"

const EXPECTED_CONDITIONS = [ "index", "middle", "ring", "pinky", "orientation" ]

function clamp(value, minimum = 0, maximum = 1) {
  return Math.min(maximum, Math.max(minimum, value))
}

function handBounds(landmarks) {
  const xCoordinates = landmarks.map(({ x }) => x)
  const yCoordinates = landmarks.map(({ y }) => y)

  return {
    minX: Math.min(...xCoordinates),
    maxX: Math.max(...xCoordinates),
    minY: Math.min(...yCoordinates),
    maxY: Math.max(...yCoordinates)
  }
}

// Works exclusively with MediaPipe's normalized coordinates (0..1), never pixels.
export function evaluateHandFraming(landmarks) {
  if (!Array.isArray(landmarks) || landmarks.length !== HAND_LANDMARK_COUNT) {
    return { state: "waiting", score: 0, messageKey: "frame_waiting" }
  }

  const bounds = handBounds(landmarks)
  const width = bounds.maxX - bounds.minX
  const height = bounds.maxY - bounds.minY
  const size = Math.max(width, height)
  const centerX = (bounds.minX + bounds.maxX) / 2
  const centerY = (bounds.minY + bounds.maxY) / 2
  const centerDistance = Math.hypot(centerX - 0.5, centerY - 0.5)

  const sizeScore = clamp(1 - Math.abs(size - 0.55) / 0.35)
  const positionScore = clamp(1 - centerDistance / 0.38)
  const score = (sizeScore + positionScore) / 2
  const framed = size >= 0.28 && size <= 0.82 && centerDistance <= 0.24

  return {
    state: framed ? "framed" : "adjust",
    score,
    messageKey: framed ? "frame_good" : "frame_adjust"
  }
}

export function buildHandFeedback(landmarks, detection) {
  const framing = evaluateHandFraming(landmarks)
  const conditions = detection?.conditions || {}

  return {
    framing,
    conditions: EXPECTED_CONDITIONS.map((key) => ({
      key,
      matched: Boolean(conditions[key])
    }))
  }
}
