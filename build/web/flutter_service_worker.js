'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"main.dart.js": "f66f844c8211c08dd712eb8081f3da66",
"manifest.json": "ff14d838185111d60239341af72179a5",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"index.html": "0588dd2c20050c9608384db0e84dacb6",
"/": "0588dd2c20050c9608384db0e84dacb6",
"flutter_bootstrap.js": "d06816520cab5369b53a28738b54ee64",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "3b0e88ce6008dff55e378acfb0faa946",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "1dec37ae6f66ff59b6c6529e15cfbe68",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "4769f3245a24c1fa9965f113ea85ec2a",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.json": "6b9e9aa67c22e88c3e5aff38e7856122",
"assets/FontManifest.json": "9147dff57ceb0803bb4f288a4c040890",
"assets/NOTICES": "fb367ae405fc8c31b166089f74ef5171",
"assets/fonts/MaterialIcons-Regular.otf": "5547e936a14dc1a6b186c70ea4a99399",
"assets/AssetManifest.bin": "7cb54f053842c402644ef64fcc398b7c",
"assets/assets/svg/DrawKit%2520Vector%2520Illustration%2520Love%2520&%2520Dating%2520(5).svg": "3f1a1f8c0f6abbfeb3fa5d493876566c",
"assets/assets/svg/DrawKit%2520Vector%2520Illustration%2520Love%2520&%2520Dating%2520(10).svg": "1eebbf97599464a9fdc002a277f6031b",
"assets/assets/svg/DrawKit%2520Vector%2520Illustration%2520Love%2520&%2520Dating%2520(9).svg": "ce17109f76646ab830ae5029369ea364",
"assets/assets/svg/DrawKit%2520Vector%2520Illustration%2520Love%2520&%2520Dating%2520(7).svg": "53381fc9758feae0a6b56325b716cd61",
"assets/assets/svg/DrawKit%2520Vector%2520Illustration%2520Love%2520&%2520Dating%2520(2).svg": "bbf8f83fa010fe26c0d0449bc662ccbb",
"assets/assets/svg/DrawKit%2520Vector%2520Illustration%2520Love%2520&%2520Dating%2520(3).svg": "183e432682055c376a912929c496fd41",
"assets/assets/svg/DrawKit%2520Vector%2520Illustration%2520Love%2520&%2520Dating%2520(6).svg": "571fed626c7e820d0d76e9f6c42bcfee",
"assets/assets/svg/DrawKit%2520Vector%2520Illustration%2520Love%2520&%2520Dating%2520(1).svg": "a949ff70a77e0cfe2c30cc0fa2b55097",
"assets/assets/svg/DrawKit%2520Vector%2520Illustration%2520Love%2520&%2520Dating%2520(11).svg": "dabd213837a05ed837c8a978f92f6e9f",
"assets/assets/svg/DrawKit%2520Vector%2520Illustration%2520Love%2520&%2520Dating%2520(8).svg": "11be004aa12f4b8c1303cbc9a868c49a",
"assets/assets/svg/DrawKit%2520Vector%2520Illustration%2520Love%2520&%2520Dating%2520(12).svg": "4e8a95630d09e25068897660497fb5f6",
"assets/assets/svg/DrawKit%2520Vector%2520Illustration%2520Love%2520&%2520Dating%2520(4).svg": "b43db64a422f13655cbeb546d613e42e",
"assets/assets/fonts/Inter-Italic-VariableFont_opsz,wght.ttf": "6dce17792107f0321537c2f1e9f12866",
"assets/assets/fonts/Inter-VariableFont_opsz,wght.ttf": "0a77e23a8fdbe6caefd53cb04c26fabc",
"assets/AssetManifest.bin.json": "5133b5f5ff69b1ea38f723c5dd26b7b0",
"version.json": "77eda502af8534bcb51b252390f230bc",
"favicon.png": "5dcef449791fa27946b3d35ad8803796"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
