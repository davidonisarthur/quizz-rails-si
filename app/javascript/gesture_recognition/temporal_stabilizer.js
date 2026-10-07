export class TemporalGestureStabilizer {
  constructor({ requiredConsecutiveFrames = 10, onCompleted = () => {} } = {}) {
    this.requiredConsecutiveFrames = Math.min(15, Math.max(8, requiredConsecutiveFrames))
    this.onCompleted = onCompleted
    this.reset()
  }

  reset() {
    this.lastGestureId = null
    this.consecutiveFrames = 0
    this.completedGestureId = null
  }

  observe(candidate) {
    if (candidate.state === "no_hand") {
      this.reset()
      return { ...candidate, detected: false, confirmed: false, consecutiveFrames: 0, requiredConsecutiveFrames: this.requiredConsecutiveFrames }
    }

    if (!candidate.detected) {
      this.lastGestureId = null
      this.consecutiveFrames = 0
      this.completedGestureId = null
      return { ...candidate, detected: false, confirmed: false, consecutiveFrames: 0, requiredConsecutiveFrames: this.requiredConsecutiveFrames }
    }

    this.consecutiveFrames = this.lastGestureId === candidate.gestureId ? this.consecutiveFrames + 1 : 1
    this.lastGestureId = candidate.gestureId
    const confirmed = this.consecutiveFrames >= this.requiredConsecutiveFrames
    const result = {
      ...candidate,
      detected: confirmed,
      confirmed,
      state: confirmed ? "recognized" : "partial",
      consecutiveFrames: this.consecutiveFrames,
      requiredConsecutiveFrames: this.requiredConsecutiveFrames
    }

    if (confirmed && this.completedGestureId !== candidate.gestureId) {
      this.completedGestureId = candidate.gestureId
      this.onCompleted(result)
    }

    return result
  }
}
