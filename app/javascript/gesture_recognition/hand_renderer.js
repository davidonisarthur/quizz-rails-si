import { HAND_CONNECTIONS } from "gesture_recognition/hand_constants"

export class HandLandmarkRenderer {
  constructor(canvas) {
    this.canvas = canvas
    this.context = canvas.getContext("2d")
  }

  resizeTo(video) {
    if (!video.videoWidth || !video.videoHeight) return

    if (this.canvas.width !== video.videoWidth || this.canvas.height !== video.videoHeight) {
      this.canvas.width = video.videoWidth
      this.canvas.height = video.videoHeight
    }
  }

  clear() {
    this.context.clearRect(0, 0, this.canvas.width, this.canvas.height)
  }

  draw(landmarks) {
    this.clear()
    if (!landmarks?.length) return

    this.context.lineWidth = Math.max(2, this.canvas.width / 320)
    this.context.strokeStyle = "#4bb9ed"
    this.context.fillStyle = "#f4c95d"

    HAND_CONNECTIONS.forEach(([ start, end ]) => {
      const first = landmarks[start]
      const second = landmarks[end]
      if (!first || !second) return

      this.context.beginPath()
      this.context.moveTo(first.x * this.canvas.width, first.y * this.canvas.height)
      this.context.lineTo(second.x * this.canvas.width, second.y * this.canvas.height)
      this.context.stroke()
    })

    const radius = Math.max(3, this.canvas.width / 180)
    landmarks.forEach((landmark) => {
      this.context.beginPath()
      this.context.arc(landmark.x * this.canvas.width, landmark.y * this.canvas.height, radius, 0, Math.PI * 2)
      this.context.fill()
    })
  }
}
