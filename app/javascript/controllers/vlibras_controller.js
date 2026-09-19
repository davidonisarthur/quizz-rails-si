import { Controller } from "@hotwired/stimulus"

const WIDGET_PATH = "https://vlibras.gov.br/app"
const MAX_INITIALIZATION_ATTEMPTS = 50
const MAX_TRANSLATION_ATTEMPTS = 30

function initializeWidget() {
  if (window._vlibrasInitialized) return true
  if (!window.VLibras || typeof window.VLibras.Widget !== "function") return false

  new window.VLibras.Widget({ rootPath: WIDGET_PATH })
  window._vlibrasInitialized = true
  return true
}

export default class extends Controller {
  static values = { text: String }

  connect() {
    this.initialize()
  }

  disconnect() {
    this.clearInitializationPoll()
    this.clearTranslationPoll()
  }

  initialize() {
    if (initializeWidget()) {
      this.clearInitializationPoll()
      return
    }

    if (this.initializationPoll) return

    let attempts = 0
    this.initializationPoll = window.setInterval(() => {
      attempts += 1
      if (initializeWidget() || attempts >= MAX_INITIALIZATION_ATTEMPTS) {
        this.clearInitializationPoll()
      }
    }, 100)
  }

  translate(event) {
    event?.preventDefault()
    this.initialize()
    this.openWidget()

    const text = this.hasTextValue ? this.textValue : this.element.dataset.vlibrasTextValue
    if (text) this.translateText(text)
  }

  openWidget() {
    window.VLibrasWidget?.open?.()
  }

  translateText(text) {
    const translate = () => {
      const translateAndPlay = window.vlibras?.translateAndPlay
      if (typeof translateAndPlay !== "function") return false

      translateAndPlay(text)
      return true
    }

    if (translate()) return

    this.clearTranslationPoll()
    let attempts = 0
    this.translationPoll = window.setInterval(() => {
      attempts += 1
      if (translate() || attempts >= MAX_TRANSLATION_ATTEMPTS) {
        this.clearTranslationPoll()
      }
    }, 200)
  }

  clearInitializationPoll() {
    if (!this.initializationPoll) return

    window.clearInterval(this.initializationPoll)
    this.initializationPoll = null
  }

  clearTranslationPoll() {
    if (!this.translationPoll) return

    window.clearInterval(this.translationPoll)
    this.translationPoll = null
  }
}
