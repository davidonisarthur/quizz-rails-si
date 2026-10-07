import { Controller } from "@hotwired/stimulus"
import { detectGesture } from "gesture_recognition/gesture_detector"
import { HandLandmarkRenderer } from "gesture_recognition/hand_renderer"
import { MediaPipeHandLandmarker } from "gesture_recognition/mediapipe_hand_landmarker"
import { TemporalGestureStabilizer } from "gesture_recognition/temporal_stabilizer"
import { WebcamController, cameraErrorCode } from "gesture_recognition/webcam"

export default class extends Controller {
  static targets = [ "video", "canvas", "status", "detail", "startButton", "stopButton", "cameraPlaceholder" ]
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
    this.handlePageHide = () => this.shutdown()

    window.addEventListener("pagehide", this.handlePageHide)
    document.addEventListener("turbo:before-cache", this.handlePageHide)
    this.setIdleState()
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
        if (landmarks) {
          this.renderer.draw(landmarks)
          this.updateRecognition(this.stabilizer.observe(detectGesture(landmarks)))
        } else {
          this.renderer.clear()
          this.updateRecognition(this.stabilizer.observe(detectGesture(null)))
        }
      }
    } catch (error) {
      this.shutdown()
      this.showError("detection")
      return
    }

    this.animationFrame = window.requestAnimationFrame((nextTimestamp) => this.processFrame(nextTimestamp))
  }

  updateRecognition(result) {
    this.setStatus(result.state)

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
    const event = new CustomEvent("gesture:completed", { bubbles: true, detail: result })
    this.element.dispatchEvent(event)
  }

  setIdleState() {
    this.cameraPlaceholderTarget.textContent = this.message("state_idle")
    this.cameraPlaceholderTarget.classList.remove("hidden")
    this.setControls({ running: false })
    this.setStatus("idle", this.format("progress", { current: 0, required: this.requiredFramesValue || 10 }))
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
