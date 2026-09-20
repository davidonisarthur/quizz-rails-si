import { Controller } from "@hotwired/stimulus"

// Helper function to adopt VLibras dynamic elements into permanent container
function adoptVlibrasElements() {
  const container = document.getElementById("vlibras-widget-container")
  if (!container) return

  const accessWrapper = document.getElementById("vlibras-access-wrapper")
  if (accessWrapper && accessWrapper.parentElement !== container) {
    container.appendChild(accessWrapper)
  }

  const appRoot = document.getElementById("vlibras-app-root")
  if (appRoot && appRoot.parentElement !== container) {
    container.appendChild(appRoot)
  }
}

// Preserve document.body event listeners across Turbo page swaps
if (!window._vlibrasBodyPatched && typeof window !== "undefined" && window.HTMLBodyElement) {
  window._vlibrasBodyPatched = true
  const originalAdd = HTMLBodyElement.prototype.addEventListener
  const originalRemove = HTMLBodyElement.prototype.removeEventListener
  const bodyListeners = new Set()

  HTMLBodyElement.prototype.addEventListener = function(type, listener, options) {
    let exists = false
    for (const item of bodyListeners) {
      if (item.type === type && item.listener === listener) {
        exists = true
        break
      }
    }
    if (!exists) {
      bodyListeners.add({ type, listener, options })
    }
    return originalAdd.call(this, type, listener, options)
  }

  HTMLBodyElement.prototype.removeEventListener = function(type, listener, options) {
    for (const item of bodyListeners) {
      if (item.type === type && item.listener === listener) {
        bodyListeners.delete(item)
        break
      }
    }
    return originalRemove.call(this, type, listener, options)
  }

  const rebindListeners = () => {
    if (document.body) {
      for (const { type, listener, options } of bodyListeners) {
        originalAdd.call(document.body, type, listener, options)
      }
    }
  }

  document.addEventListener("turbo:render", rebindListeners)
  document.addEventListener("turbo:load", rebindListeners)
}

// Setup MutationObserver to continuously ensure VLibras elements stay inside the permanent container
if (typeof document !== "undefined" && !window._vlibrasObserverSet) {
  window._vlibrasObserverSet = true

  const observer = new MutationObserver((mutations) => {
    for (const mutation of mutations) {
      for (const node of mutation.addedNodes) {
        if (node.nodeType === Node.ELEMENT_NODE && (node.id === "vlibras-access-wrapper" || node.id === "vlibras-app-root")) {
          adoptVlibrasElements()
        }
      }
    }
  })

  const startObserving = () => {
    if (document.body) {
      observer.observe(document.body, { childList: true })
      adoptVlibrasElements()
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", startObserving)
  } else {
    startObserving()
  }

  document.addEventListener("turbo:before-render", () => {
    adoptVlibrasElements()
  })

  document.addEventListener("turbo:render", () => {
    if (document.body) {
      observer.observe(document.body, { childList: true })
      adoptVlibrasElements()
    }
  })
}

export default class extends Controller {
  static values = {
    text: String
  }

  connect() {
    this.initWidget()
  }

  initWidget() {
    const init = () => {
      if (window.VLibras && typeof window.VLibras.Widget === "function") {
        if (!window._vlibrasInstance) {
          window._vlibrasInstance = new window.VLibras.Widget("https://vlibras.gov.br/app")
        }
      }
      adoptVlibrasElements()
    }

    if (window.VLibras) {
      init()
    } else {
      let attempts = 0
      const poll = setInterval(() => {
        attempts++
        if (window.VLibras || attempts > 50) {
          clearInterval(poll)
          init()
        }
      }, 100)
    }
  }

  openWidget() {
    // 1. Modern VLibras v7 API
    if (window.VLibrasWidget && typeof window.VLibrasWidget.open === "function") {
      window.VLibrasWidget.open()
      return
    }

    // 2. Click button inside Shadow DOM of #vlibras-access-wrapper
    const accessWrapper = document.getElementById("vlibras-access-wrapper")
    const shadowButton = accessWrapper?.shadowRoot?.querySelector("#vlibras-button")
    if (shadowButton) {
      shadowButton.click()
      return
    }

    // 3. Legacy VLibras access button
    const legacyButton = document.querySelector("[vw-access-button]")
    if (legacyButton) {
      legacyButton.click()
    }
  }

  translate(event) {
    if (event) event.preventDefault()

    this.openWidget()

    const text = this.hasTextValue ? this.textValue : this.element.dataset.vlibrasTextValue
    if (text) {
      this.translateText(text)
    }
  }

  translateText(text) {
    if (!text || typeof text !== "string") return

    const execute = () => {
      const fn = (window.plugin && typeof window.plugin.translate === "function" && window.plugin.translate) ||
                 (window.vlibras && typeof window.vlibras.translateAndPlay === "function" && window.vlibras.translateAndPlay)
      if (fn) {
        fn(text)
        return true
      }
      return false
    }

    if (!execute()) {
      let attempts = 0
      const interval = setInterval(() => {
        attempts++
        if (execute() || attempts >= 30) {
          clearInterval(interval)
        }
      }, 200)
    }
  }
}
