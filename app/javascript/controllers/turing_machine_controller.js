import { Controller } from "@hotwired/stimulus"

const INITIAL_TAPE = [ "0", "1", "0", "1", "□" ]
const BLANK = "□"

export default class extends Controller {
  static targets = [ "tape", "state", "rule", "startButton", "stepButton" ]
  static values = {
    initialMessage: String,
    readZero: String,
    readOne: String,
    haltedMessage: String
  }

  connect() {
    this.reset()
  }

  disconnect() {
    this.pause()
  }

  start() {
    if (this.halted) this.reset()
    if (this.timer) return

    this.timer = window.setInterval(() => this.step(), 900)
  }

  pause() {
    if (!this.timer) return

    window.clearInterval(this.timer)
    this.timer = null
  }

  step() {
    if (this.halted) return

    const symbol = this.tape[this.position]
    if (symbol === BLANK) {
      this.halted = true
      this.ruleTarget.textContent = this.haltedMessageValue
      this.pause()
    } else {
      const replacement = symbol === "0" ? "1" : "0"
      this.tape[this.position] = replacement
      this.ruleTarget.textContent = symbol === "0" ? this.readZeroValue : this.readOneValue
      this.position += 1
    }

    this.render()
  }

  reset() {
    this.pause()
    this.tape = [ ...INITIAL_TAPE ]
    this.position = 0
    this.halted = false
    this.ruleTarget.textContent = this.initialMessageValue
    this.render()
  }

  render() {
    this.stateTarget.textContent = this.halted ? "qH" : "q0"
    this.tapeTarget.replaceChildren()

    this.tape.forEach((symbol, index) => {
      const cell = document.createElement("div")
      cell.className = "relative flex h-16 w-16 items-center justify-center border text-2xl font-bold"
      if (index === this.position && !this.halted) {
        cell.classList.add("border-accent", "bg-accent/10", "text-accent")
      } else {
        cell.classList.add("border-bg3", "bg-bg1", "text-tx0")
      }
      cell.textContent = symbol

      if (index === this.position && !this.halted) {
        const head = document.createElement("span")
        head.className = "absolute -top-7 text-xs font-extrabold tracking-[0.1em] text-accent uppercase"
        head.textContent = "↓"
        head.setAttribute("aria-hidden", "true")
        cell.append(head)
      }

      this.tapeTarget.append(cell)
    })

    this.stepButtonTarget.disabled = this.halted
  }
}
