import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "modal", "video", "closeButton" ]

  connect() {
    this.triggerElement = null
  }

  disconnect() {
    this.stopVideo()
  }

  open(event) {
    event.preventDefault()
    this.triggerElement = event.currentTarget
    this.modalTarget.classList.remove("hidden")
    this.modalTarget.classList.add("flex")
    
    const url = event.currentTarget.dataset.videoUrl
    if (url && this.hasVideoTarget) {
      this.videoTarget.src = url
      this.videoTarget.load()
    }

    requestAnimationFrame(() => this.closeButtonTarget.focus())
  }

  close(event) {
    if (event) event.preventDefault()
    this.modalTarget.classList.add("hidden")
    this.modalTarget.classList.remove("flex")
    
    this.stopVideo()

    this.triggerElement?.focus()
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) this.close(event)
  }

  stopVideo() {
    if (!this.hasVideoTarget) return

    this.videoTarget.pause()
    this.videoTarget.removeAttribute("src")
    this.videoTarget.load()
  }

  handleKeydown(event) {
    if (this.modalTarget.classList.contains("hidden")) return

    if (event.key === "Escape") {
      this.close(event)
      return
    }

    if (event.key !== "Tab") return

    const focusable = this.modalTarget.querySelectorAll(
      "button:not([disabled]), video[controls], [href], input, select, textarea, [tabindex]:not([tabindex='-1'])"
    )
    const elements = Array.from(focusable)
    if (elements.length === 0) {
      event.preventDefault()
      this.modalTarget.focus()
      return
    }

    const first = elements[0]
    const last = elements[elements.length - 1]
    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault()
      last.focus()
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault()
      first.focus()
    }
  }
}
