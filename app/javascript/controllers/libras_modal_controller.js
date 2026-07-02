import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "modal", "iframe" ]

  open(event) {
    event.preventDefault()
    this.modalTarget.classList.remove("hidden")
    this.modalTarget.classList.add("flex")
    
    // Set the iframe src if stored in data-video-url
    const url = event.currentTarget.dataset.videoUrl
    if (url && this.hasIframeTarget) {
      this.iframeTarget.src = url
    }
  }

  close(event) {
    if (event) event.preventDefault()
    this.modalTarget.classList.add("hidden")
    this.modalTarget.classList.remove("flex")
    
    // Stop the video playing by resetting src
    if (this.hasIframeTarget) {
      this.iframeTarget.src = ""
    }
  }
}
