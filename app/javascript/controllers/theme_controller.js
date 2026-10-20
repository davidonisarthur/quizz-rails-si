import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.syncPressedState()
  }

  toggle() {
    if (document.documentElement.classList.contains("dark")) {
      document.documentElement.classList.remove("dark")
      localStorage.setItem("theme", "light")
    } else {
      document.documentElement.classList.add("dark")
      localStorage.setItem("theme", "dark")
    }

    this.syncPressedState()
  }

  syncPressedState() {
    this.element.setAttribute("aria-pressed", document.documentElement.classList.contains("dark").toString())
  }
}
