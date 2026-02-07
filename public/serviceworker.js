// 節約は収入 — Service Worker
const CACHE_NAME = "setsuyaku-v1";
const STATIC_ASSETS = [
  "/",
  "/assets/application.css",
  "/icon-192.png",
  "/icon-512.png",
  "/offline.html"
];

// インストール時：静的アセットをキャッシュ
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(STATIC_ASSETS).catch((err) => {
        console.warn("[SW] 一部のアセットのキャッシュに失敗:", err);
      });
    })
  );
  self.skipWaiting();
});

// アクティベート時：古いキャッシュを削除
self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys
          .filter((key) => key !== CACHE_NAME)
          .map((key) => caches.delete(key))
      );
    })
  );
  self.clients.claim();
});

// フェッチ時：Network First + キャッシュフォールバック
self.addEventListener("fetch", (event) => {
  const { request } = event;

  // POST や API リクエストはキャッシュしない
  if (request.method !== "GET") return;

  // ナビゲーション（HTML）リクエスト
  if (request.mode === "navigate") {
    event.respondWith(
      fetch(request)
        .then((response) => {
          // 成功した応答をキャッシュに保存
          const clone = response.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(request, clone));
          return response;
        })
        .catch(() => {
          // オフライン時はキャッシュから返す
          return caches.match(request).then((cached) => {
            return cached || caches.match("/offline.html");
          });
        })
    );
    return;
  }

  // 静的アセット（CSS, JS, 画像）：Cache First
  if (
    request.url.match(/\.(css|js|png|jpg|jpeg|svg|ico|woff2?)(\?|$)/)
  ) {
    event.respondWith(
      caches.match(request).then((cached) => {
        const fetchPromise = fetch(request).then((response) => {
          const clone = response.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(request, clone));
          return response;
        });
        return cached || fetchPromise;
      })
    );
    return;
  }
});
