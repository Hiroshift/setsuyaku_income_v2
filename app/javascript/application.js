// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// ── Service Worker 登録 ──
if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker
      .register("/serviceworker.js", { scope: "/" })
      .then((reg) => {
        console.log("[SW] 登録成功:", reg.scope);
      })
      .catch((err) => {
        console.warn("[SW] 登録失敗:", err);
      });
  });
}

document.addEventListener("turbo:load", () => {
  const deleteAccountBtn = document.getElementById("delete-account-btn");
  const deleteConfirmModal = document.getElementById("delete-confirm-modal");
  const cancelBtn = document.querySelector("#delete-confirm-modal .btn-secondary");

  if (deleteAccountBtn && deleteConfirmModal) {
    deleteAccountBtn.addEventListener("click", () => {
      deleteConfirmModal.style.display = "block";
    });

    if (cancelBtn) {
      cancelBtn.addEventListener("click", () => {
        deleteConfirmModal.style.display = "none";
      });
    }

    window.addEventListener("click", (event) => {
      if (event.target === deleteConfirmModal) {
        deleteConfirmModal.style.display = "none";
      }
    });
  }
});


