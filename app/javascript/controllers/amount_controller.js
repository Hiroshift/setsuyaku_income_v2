import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "hidden", "dateHidden", "dateBtn"]
  static values = { max: { type: Number, default: 99999 } }

  connect() {
    this.amount = ""
    // デフォルトは今日
    this.selectedDate = this.todayStr()
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

  selectDate(event) {
    event.preventDefault()
    this.selectedDate = event.currentTarget.dataset.date
    this.dateHiddenTarget.value = this.selectedDate

    // アクティブ状態を更新
    this.dateBtnTargets.forEach(btn => {
      btn.classList.toggle("date-chip--active", btn.dataset.date === this.selectedDate)
    })
  }

  render() {
    const num = this.amount === "" ? 0 : parseInt(this.amount, 10)
    this.displayTarget.textContent = `¥${num.toLocaleString()}`
    this.hiddenTarget.value = num || ""
  }

  // ヘルパー
  todayStr() {
    const d = new Date()
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
  }
}
