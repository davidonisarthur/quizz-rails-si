import { Controller } from "@hotwired/stimulus"
import { detectGesture } from "gesture_recognition/gesture_detector"
import { buildHandFeedback } from "gesture_recognition/hand_feedback"
import { HandLandmarkRenderer } from "gesture_recognition/hand_renderer"
import { MediaPipeHandLandmarker } from "gesture_recognition/mediapipe_hand_landmarker"
import { TemporalGestureStabilizer } from "gesture_recognition/temporal_stabilizer"
import { WebcamController, cameraErrorCode } from "gesture_recognition/webcam"

export default class extends Controller {
  static targets = [
    "video", "canvas", "status", "detail", "startButton", "stopButton", "cameraPlaceholder",
    "framing", "framingGuide", "feedbackItem", "stabilityBar", "stabilityValue",
    "history", "historyEmpty", "clearHistory"
  ]
  static values = {
    requiredFrames: Number,
    messages: Object
  }

  connect() {
    this.webcam = new WebcamController()
    this.renderer = new HandLandmarkRenderer(this.canvasTarget)
    this.landmarker = new MediaPipeHandLandmarker()
    this.stabilizer = new TemporalGestureStabilizer({
      requiredConsecutiveFrames: this.requiredFramesValue || 10,
      onCompleted: (result) => this.onGestureCompleted(result)
    })
    this.running = false
    this.starting = false
    this.runToken = 0
    this.animationFrame = null
    this.lastVideoTime = -1
    this.historyStorageKey = "primoquiz:hand-gesture-history:v1"
    this.historyEntries = this.loadHistory()
    this.handlePageHide = () => this.shutdown()

    window.addEventListener("pagehide", this.handlePageHide)
    document.addEventListener("turbo:before-cache", this.handlePageHide)
    this.setIdleState()
    this.renderHistory()
  }

  disconnect() {
    window.removeEventListener("pagehide", this.handlePageHide)
    document.removeEventListener("turbo:before-cache", this.handlePageHide)
    this.shutdown()
  }

  async start() {
    if (this.running || this.starting) return

    if (!window.isSecureContext) {
      this.showError("insecure_context")
      return
    }

    if (!WebcamController.isSupported()) {
      this.showError("unsupported")
      return
    }

    this.starting = true
    const runToken = ++this.runToken
    this.setControls({ starting: true })
    this.setStatus("loading", this.message("state_loading"))

    try {
      await this.webcam.start(this.videoTarget)
      await this.landmarker.load()
      if (runToken !== this.runToken || !this.element.isConnected) return

      this.running = true
      this.lastVideoTime = -1
      this.cameraPlaceholderTarget.classList.add("hidden")
      this.setControls({ running: true })
      this.processFrame(performance.now())
    } catch (error) {
      this.shutdown()
      this.showError(error?.code || cameraErrorCode(error))
    } finally {
      this.starting = false
    }
  }

  stop() {
    this.shutdown()
    this.setIdleState()
  }

  shutdown() {
    this.runToken += 1
    this.running = false
    this.starting = false
    if (this.animationFrame) window.cancelAnimationFrame(this.animationFrame)
    this.animationFrame = null
    this.stabilizer?.reset()
    this.renderer?.clear()
    this.webcam?.stop(this.videoTarget)
    this.landmarker?.close()
  }

  processFrame(timestamp) {
    if (!this.running) return

    try {
      if (this.videoTarget.readyState >= HTMLMediaElement.HAVE_CURRENT_DATA && this.videoTarget.currentTime !== this.lastVideoTime) {
        this.lastVideoTime = this.videoTarget.currentTime
        this.renderer.resizeTo(this.videoTarget)

        const result = this.landmarker.detect(this.videoTarget, timestamp)
        const landmarks = result.landmarks?.[0]
        const detection = detectGesture(landmarks)
        const feedback = buildHandFeedback(landmarks, detection)
        if (landmarks) {
          this.renderer.draw(landmarks, { candidate: detection.detected })
        } else {
          this.renderer.clear()
        }
        this.updateRecognition(this.stabilizer.observe(detection), feedback)
      }
    } catch (error) {
      this.shutdown()
      this.showError("detection")
      return
    }

    this.animationFrame = window.requestAnimationFrame((nextTimestamp) => this.processFrame(nextTimestamp))
  }

  updateRecognition(result, feedback) {
    this.setStatus(result.state)
    this.updateFeedback(feedback)
    this.updateStability(result)

    if (result.state === "recognized" || result.state === "partial") {
      this.detailTarget.textContent = this.format("progress", {
        current: Math.min(result.consecutiveFrames, result.requiredConsecutiveFrames),
        required: result.requiredConsecutiveFrames
      })
    } else {
      this.detailTarget.textContent = result.message
    }
  }

  onGestureCompleted(result) {
    this.saveHistoryEntry(result)
    const event = new CustomEvent("gesture:completed", { bubbles: true, detail: result })
    this.element.dispatchEvent(event)
  }

  setIdleState() {
    this.cameraPlaceholderTarget.textContent = this.message("state_idle")
    this.cameraPlaceholderTarget.classList.remove("hidden")
    this.setControls({ running: false })
    this.setStatus("idle", this.format("progress", { current: 0, required: this.requiredFramesValue || 10 }))
    this.updateFeedback(buildHandFeedback(null, null))
    this.updateStability({ consecutiveFrames: 0, requiredConsecutiveFrames: this.requiredFramesValue || 10 })
  }

  showError(errorCode) {
    this.cameraPlaceholderTarget.textContent = this.message(`error_${errorCode}`) || this.message("state_error")
    this.cameraPlaceholderTarget.classList.remove("hidden")
    this.setControls({ running: false })
    this.setStatus("error", this.message(`error_${errorCode}`) || this.message("state_error"))
  }

  setControls({ running = false, starting = false }) {
    this.startButtonTarget.disabled = running || starting
    this.stopButtonTarget.disabled = !running && !starting
  }

  setStatus(state, detail = null) {
    this.statusTarget.textContent = this.message(`state_${state}`) || this.message("state_error")
    if (detail) this.detailTarget.textContent = detail
  }

  updateFeedback(feedback) {
    if (!feedback) return

    const { framing, conditions } = feedback
    this.framingTarget.textContent = this.message(framing.messageKey)
    this.framingTarget.dataset.state = framing.state
    this.framingGuideTarget.dataset.state = framing.state

    const conditionByKey = new Map(conditions.map((condition) => [ condition.key, condition ]))
    this.feedbackItemTargets.forEach((item) => {
      const matched = conditionByKey.get(item.dataset.feedbackKey)?.matched || false
      const status = item.querySelector("[data-feedback-status]")

      item.dataset.state = matched ? "matched" : "adjust"
      if (status) status.textContent = this.message(matched ? "feedback_matched" : "feedback_adjust")
    })
  }

  updateStability(result) {
    const required = result.requiredConsecutiveFrames || this.requiredFramesValue || 10
    const current = Math.min(result.consecutiveFrames || 0, required)
    const progress = Math.round((current / required) * 100)

    this.stabilityBarTarget.style.width = `${progress}%`
    this.stabilityBarTarget.setAttribute("aria-valuenow", progress)
    const label = this.format("progress", { current, required })
    this.stabilityBarTarget.setAttribute("aria-valuetext", label)
    this.stabilityValueTarget.textContent = label
  }

  clearHistory() {
    this.historyEntries = []
    try {
      window.localStorage.removeItem(this.historyStorageKey)
    } catch (_error) {
      // A page remains usable when local storage is disabled by the browser.
    }
    this.renderHistory()
  }

  loadHistory() {
    try {
      const savedEntries = JSON.parse(window.localStorage.getItem(this.historyStorageKey) || "[]")
      return Array.isArray(savedEntries)
        ? savedEntries.filter((entry) => entry?.gestureId && entry?.completedAt).slice(0, 5)
        : []
    } catch (_error) {
      return []
    }
  }

  saveHistoryEntry(result) {
    this.historyEntries = [
      { gestureId: result.gestureId, completedAt: new Date().toISOString() },
      ...this.historyEntries
    ].slice(0, 5)

    try {
      window.localStorage.setItem(this.historyStorageKey, JSON.stringify(this.historyEntries))
    } catch (_error) {
      // History is optional and is never required for recognition to work.
    }
    this.renderHistory()
  }

  renderHistory() {
    if (!this.hasHistoryTarget) return

    this.historyTarget.replaceChildren()
    this.historyEntries.forEach((entry) => {
      const item = document.createElement("li")
      item.className = "rounded-md border border-bg3 px-3 py-2 text-xs leading-5 text-tx1"
      item.textContent = this.format("history_entry", {
        gesture: entry.gestureId,
        time: this.formatTimestamp(entry.completedAt)
      })
      this.historyTarget.append(item)
    })

    this.historyEmptyTarget.classList.toggle("hidden", this.historyEntries.length > 0)
    this.clearHistoryTarget.classList.toggle("hidden", this.historyEntries.length === 0)
  }

  formatTimestamp(timestamp) {
    try {
      return new Intl.DateTimeFormat(document.documentElement.lang || "pt-BR", {
        dateStyle: "short",
        timeStyle: "short"
      }).format(new Date(timestamp))
    } catch (_error) {
      return timestamp
    }
  }

  message(key) {
    return this.messagesValue?.[key] || ""
  }

  format(key, values) {
    return Object.entries(values).reduce(
      (message, [ name, value ]) => message.replace(`%{${name}}`, value),
      this.message(key)
    )
  }
}
