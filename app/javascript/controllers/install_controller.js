import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["banner", "iosGuide", "androidBtn"]

  connect() {
    // すでにPWAとして起動中なら何も表示しない
    if (window.matchMedia("(display-mode: standalone)").matches) return;
    if (window.navigator.standalone === true) return; // iOS Safari

    // 一度閉じた場合は表示しない
    if (localStorage.getItem("install-dismissed")) return;

    // 2回目以降の訪問で表示（初回は体験してもらう）
    const visitCount = parseInt(localStorage.getItem("visit-count") || "0", 10) + 1;
    localStorage.setItem("visit-count", String(visitCount));
    if (visitCount < 2) return;

    // プラットフォーム判定
    this.isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
    this.isAndroid = /Android/.test(navigator.userAgent);

    // Android: beforeinstallprompt イベントをキャッチ
    if (this.isAndroid || (!this.isIOS && !this.isAndroid)) {
      window.addEventListener("beforeinstallprompt", (e) => {
        e.preventDefault();
        this.deferredPrompt = e;
        this.showBanner("android");
      });
    }

    // iOS: 手動ガイドを表示
    if (this.isIOS) {
      this.showBanner("ios");
    }
  }

  showBanner(type) {
    if (this.hasBannerTarget) {
      this.bannerTarget.classList.add("install-banner--visible");

      if (type === "ios" && this.hasIosGuideTarget) {
        this.iosGuideTarget.style.display = "block";
      }
      if (type === "android" && this.hasAndroidBtnTarget) {
        this.androidBtnTarget.style.display = "block";
      }
    }
  }

  // Android: ネイティブインストールダイアログを呼び出す
  installAndroid() {
    if (this.deferredPrompt) {
      this.deferredPrompt.prompt();
      this.deferredPrompt.userChoice.then((choice) => {
        if (choice.outcome === "accepted") {
          this.dismiss();
        }
        this.deferredPrompt = null;
      });
    }
  }

  // バナーを閉じる
  dismiss() {
    localStorage.setItem("install-dismissed", "true");
    if (this.hasBannerTarget) {
      this.bannerTarget.classList.remove("install-banner--visible");
    }
  }
}
