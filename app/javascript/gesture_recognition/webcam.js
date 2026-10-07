export class WebcamController {
  constructor() {
    this.stream = null
  }

  static isSupported() {
    return Boolean(navigator.mediaDevices?.getUserMedia)
  }

  async start(video) {
    this.stop(video)
    this.stream = await navigator.mediaDevices.getUserMedia({
      audio: false,
      video: {
        facingMode: "user",
        width: { ideal: 1280 },
        height: { ideal: 720 }
      }
    })
    video.srcObject = this.stream
    await video.play()
    return this.stream
  }

  stop(video) {
    this.stream?.getTracks().forEach((track) => track.stop())
    this.stream = null

    if (video) {
      video.pause()
      video.srcObject = null
    }
  }
}

export function cameraErrorCode(error) {
  if ([ "NotAllowedError", "SecurityError" ].includes(error?.name)) return "permission_denied"
  if (error?.name === "NotFoundError") return "not_found"
  return "camera"
}
