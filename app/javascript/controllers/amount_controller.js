import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "chip"]

  select(event) {
    event.preventDefault()
    const value = event.currentTarget.dataset.amount
    this.inputTarget.value = value
    this.inputTarget.focus()
    this.highlightChip(event.currentTarget)
  }

  // 手動入力したらチップの選択状態をクリア
  typed() {
    this.chipTargets.forEach(chip => chip.classList.remove("is-selected"))
  }

  highlightChip(selected) {
    this.chipTargets.forEach(chip => chip.classList.remove("is-selected"))
    selected.classList.add("is-selected")
  }
}
