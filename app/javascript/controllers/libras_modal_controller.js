import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "modal", "iframe", "closeButton" ]

  connect() {
    this.triggerElement = null
  }

  open(event) {
    event.preventDefault()
    this.triggerElement = event.currentTarget
    this.modalTarget.classList.remove("hidden")
    this.modalTarget.classList.add("flex")
    
    // Set the iframe src if stored in data-video-url
    const url = event.currentTarget.dataset.videoUrl
    if (url && this.hasIframeTarget) {
      this.iframeTarget.src = url
    }

    requestAnimationFrame(() => this.closeButtonTarget.focus())
  }

  close(event) {
    if (event) event.preventDefault()
    this.modalTarget.classList.add("hidden")
    this.modalTarget.classList.remove("flex")
    
    // Stop the video playing by resetting src
    if (this.hasIframeTarget) {
      this.iframeTarget.src = ""
    }

    this.triggerElement?.focus()
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) this.close(event)
  }

  handleKeydown(event) {
    if (this.modalTarget.classList.contains("hidden")) return

    if (event.key === "Escape") {
      this.close(event)
      return
    }

    if (event.key !== "Tab") return

    const focusable = this.modalTarget.querySelectorAll(
      "button:not([disabled]), iframe, [href], input, select, textarea, [tabindex]:not([tabindex='-1'])"
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
