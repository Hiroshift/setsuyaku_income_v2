import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "hidden"]
  static values = { max: { type: Number, default: 99999 } }

  connect() {
    this.amount = ""
  }

  press(event) {
    event.preventDefault()
    const digit = event.currentTarget.dataset.key

    const next = this.amount + digit
    if (parseInt(next, 10) > this.maxValue) return

    this.amount = next
    this.render()
  }

  del(event) {
    event.preventDefault()
    this.amount = this.amount.slice(0, -1)
    this.render()
  }

  clear(event) {
    event.preventDefault()
    this.amount = ""
    this.render()
  }

  render() {
    const num = this.amount === "" ? 0 : parseInt(this.amount, 10)
    this.displayTarget.textContent = `¥${num.toLocaleString()}`
    this.hiddenTarget.value = num || ""
  }
}
