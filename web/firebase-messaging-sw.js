// Provide an empty service worker to allow Firebase Cloud Messaging to register properly on web.
// This resolves the "unsupported MIME type ('text/html')" error when getting the FCM token.
self.addEventListener('push', function(event) {
  console.log('[Service Worker] Push Received.');
  console.log(`[Service Worker] Push had this data: "${event.data.text()}"`);
});
