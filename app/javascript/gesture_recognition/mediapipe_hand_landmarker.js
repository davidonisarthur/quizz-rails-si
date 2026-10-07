const MEDIAPIPE_VERSION = "1.1.0"
const WASM_ROOT = `https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@${MEDIAPIPE_VERSION}/wasm`
const MODEL_URL = "https://storage.googleapis.com/mediapipe-models/hand_landmarker/hand_landmarker/float16/1/hand_landmarker.task"

export class MediaPipeHandLandmarker {
  async load() {
    if (this.handLandmarker) return

    try {
      const { FilesetResolver, HandLandmarker } = await import("@mediapipe/tasks-vision")
      const vision = await FilesetResolver.forVisionTasks(WASM_ROOT)
      const options = (delegate) => ({
        baseOptions: { modelAssetPath: MODEL_URL, delegate },
        runningMode: "VIDEO",
        numHands: 1,
        minHandDetectionConfidence: 0.65,
        minHandPresenceConfidence: 0.65,
        minTrackingConfidence: 0.65
      })

      try {
        this.handLandmarker = await HandLandmarker.createFromOptions(vision, options("GPU"))
      } catch (_gpuError) {
        // Alguns navegadores ou dispositivos não expõem WebGL suficiente para o delegate GPU.
        // A versão WASM/CPU mantém o protótipo funcional sem alterar a análise geométrica.
        this.handLandmarker = await HandLandmarker.createFromOptions(vision, options("CPU"))
      }
    } catch (error) {
      this.close()
      console.error("Não foi possível inicializar o MediaPipe Hand Landmarker.", error)
      error.code = "mediapipe_load"
      throw error
    }
  }

  detect(video, timestamp) {
    return this.handLandmarker.detectForVideo(video, timestamp)
  }

  close() {
    this.handLandmarker?.close?.()
    this.handLandmarker = null
  }
}
