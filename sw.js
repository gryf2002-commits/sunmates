// SunMates — service worker (PWA)
// Met en cache la "coquille" de l'app pour un démarrage rapide et un
// fonctionnement de base hors-ligne. Les appels Supabase/CDN passent
// toujours par le réseau (non mis en cache).
const CACHE = "sunmates-v1";
const SHELL = ["./", "./index.html", "./manifest.json", "./icon.svg"];

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(SHELL)).catch(() => {}));
  self.skipWaiting();
});

self.addEventListener("activate", (e) => {
  e.waitUntil(caches.keys().then((keys) =>
    Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)))));
  self.clients.claim();
});

self.addEventListener("fetch", (e) => {
  const req = e.request;
  if (req.method !== "GET") return; // ne touche pas aux écritures Supabase
  // Navigation : réseau d'abord, repli sur la coquille en cache (hors-ligne)
  if (req.mode === "navigate") {
    e.respondWith(fetch(req).catch(() => caches.match("./index.html")));
    return;
  }
  // Autres GET de même origine : cache d'abord, sinon réseau
  const url = new URL(req.url);
  if (url.origin === self.location.origin) {
    e.respondWith(caches.match(req).then((c) => c || fetch(req)));
  }
});
