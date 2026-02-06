import { Controller } from "@hotwired/stimulus"

// 月収 → 時給の自動変換
// 計算式: 時給 = 月収 ÷ (勤務日数 × 勤務時間) = 月収 ÷ 176
const WORK_HOURS_PER_MONTH = 176  // 22日 × 8時間

export default class extends Controller {
  static targets = ["hourlyInput", "monthlyGroup", "hourlyGroup", "tabHourly", "tabMonthly", "computed"]

  connect() {
    // 初期状態：時給入力モード
    this.mode = "hourly"
    this.updateTabs()
  }

  // タブ切り替え：時給
  switchHourly(event) {
    event.preventDefault()
    this.mode = "hourly"
    this.updateTabs()
    // 月収の入力をクリア
    if (this.hasComputedTarget) {
      this.computedTarget.textContent = ""
    }
  }

  // タブ切り替え：月収
  switchMonthly(event) {
    event.preventDefault()
    this.mode = "monthly"
    this.updateTabs()
    // 時給入力をクリアして月収から算出に切り替え
    this.hourlyInputTarget.value = ""
  }

  // 月収が入力されたとき → 時給を算出
  calculate(event) {
    const monthly = parseInt(event.target.value, 10)

    if (monthly > 0) {
      const hourly = Math.round(monthly / WORK_HOURS_PER_MONTH)
      this.hourlyInputTarget.value = hourly
      this.computedTarget.textContent = `→ 時給 約¥${hourly.toLocaleString()}`
    } else {
      this.hourlyInputTarget.value = ""
      this.computedTarget.textContent = ""
    }
  }

  updateTabs() {
    const isHourly = this.mode === "hourly"

    // タブのアクティブ状態
    this.tabHourlyTarget.classList.toggle("wage-tab--active", isHourly)
    this.tabMonthlyTarget.classList.toggle("wage-tab--active", !isHourly)

    // 入力グループの表示切り替え
    this.hourlyGroupTarget.style.display = isHourly ? "" : "none"
    this.monthlyGroupTarget.style.display = isHourly ? "none" : ""
  }
}
