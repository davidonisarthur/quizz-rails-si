import {
  approximateHandOrientation,
  fingerCompatibility,
  isFingerBent,
  isFingerExtended
} from "gesture_recognition/hand_geometry"
import { HAND_LANDMARK_COUNT } from "gesture_recognition/hand_constants"

const GESTURE_01 = {
  index: "extended",
  middle: "extended",
  ring: "bent",
  pinky: "bent"
}

export function detectGesture(landmarks) {
  if (!Array.isArray(landmarks) || landmarks.length !== HAND_LANDMARK_COUNT) {
    return {
      gestureId: null,
      detected: false,
      confidence: 0,
      state: "no_hand",
      message: "Nenhuma mão detectada"
    }
  }

  const orientation = approximateHandOrientation(landmarks)
  const conditions = {
    index: isFingerExtended(landmarks, "index"),
    middle: isFingerExtended(landmarks, "middle"),
    ring: isFingerBent(landmarks, "ring"),
    pinky: isFingerBent(landmarks, "pinky"),
    orientation: orientation.upright
  }

  const compatibility = [
    fingerCompatibility(landmarks, "index", GESTURE_01.index),
    fingerCompatibility(landmarks, "middle", GESTURE_01.middle),
    fingerCompatibility(landmarks, "ring", GESTURE_01.ring),
    fingerCompatibility(landmarks, "pinky", GESTURE_01.pinky),
    orientation.score
  ]
  const confidence = compatibility.reduce((sum, value) => sum + value, 0) / compatibility.length
  const matches = Object.values(conditions).filter(Boolean).length
  const detected = matches === Object.keys(conditions).length && confidence >= 0.72

  if (detected) {
    return {
      gestureId: "gesture_01",
      detected: true,
      confidence,
      state: "candidate",
      message: "Configuração reconhecida",
      conditions
    }
  }

  return {
    gestureId: "gesture_01",
    detected: false,
    confidence,
    state: confidence >= 0.48 || matches >= 2 ? "partial" : "hand_detected",
    message: confidence >= 0.48 ? "Configuração parcialmente compatível" : "Mão detectada",
    conditions
  }
}
