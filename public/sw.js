// REDLINE Service Worker
// Provides offline capability and asset caching for PWA

const CACHE_NAME = "redline-v1"
const STATIC_ASSETS = [
  "/",
  "/manifest.json"
]

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(STATIC_ASSETS))
  )
  self.skipWaiting()
})

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key))
      )
    )
  )
  self.clients.claim()
})

self.addEventListener("fetch", (event) => {
  // Only cache GET requests; pass through everything else
  if (event.request.method !== "GET") return

  // Skip ActionCable WebSocket connections
  const url = new URL(event.request.url)
  if (url.pathname.startsWith("/cable")) return

  event.respondWith(
    fetch(event.request)
      .then((response) => {
        // Cache successful responses for static assets
        if (response.ok && event.request.url.includes("/assets/")) {
          const clone = response.clone()
          caches.open(CACHE_NAME).then((cache) => cache.put(event.request, clone))
        }
        return response
      })
      .catch(() => caches.match(event.request))
  )
})
