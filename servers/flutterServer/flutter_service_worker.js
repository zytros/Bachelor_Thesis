'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "assets/AssetManifest.json": "ca443f6b64b936ca2b3d3ea7614afb4a",
"assets/assets/black.png": "e4cf4d4d55995a04261267408ef1ce54",
"assets/assets/breast_indices/leftBreastIdx.txt": "2b1123cd2fdbe762721b24ab1bb4966c",
"assets/assets/breast_indices/leftBreastIdxLargeArea.txt": "cd2c02c5bc447a79787dee01b0beedaa",
"assets/assets/breast_indices/leftBreastIdxLargeAreaOutline.txt": "f89fb36ef9cfd763c915e34320006634",
"assets/assets/breast_indices/rightBreastIdx.txt": "372b1aa58386de81a4fa9f3058d63136",
"assets/assets/breast_indices/rightBreastIdxLargeArea.txt": "a6333da28043341543095a3f6ec0682f",
"assets/assets/breast_indices/rightBreastIdxLargeAreaOutline.txt": "23077fb8aba26ed36aefba217af7bb87",
"assets/assets/eigVecs.csv": "3c79256710edb06606df3430f300afae",
"assets/assets/img.jpg": "80b28aef4cbedfb33310aeda3f529bce",
"assets/assets/img.png": "f46838c7efb4d20374ba21383c0b9e3b",
"assets/assets/mean.txt": "a8386e074b6a52be7169c757990b68ca",
"assets/assets/model2/fitModel_Ctutc.mtl": "6f03cc6f21861d709d0c6557ec79b47b",
"assets/assets/model2/fitModel_Ctutc.obj": "a20cce49ffeabd19223570cccea0b909",
"assets/assets/model2/increasedModel_Ctutc.mtl": "6f03cc6f21861d709d0c6557ec79b47b",
"assets/assets/model2/increasedModel_Ctutc.obj": "243baeebd3ad0c12a07d3aef8d10e979",
"assets/assets/model2/texture_Ctutc.png": "7cf4d633e6b25a03c538aba29984f7b1",
"assets/assets/models/fitModel_Demo_Augmentation.mtl": "f5335b2b422d2b49a8a567aabd4dbff0",
"assets/assets/models/fitModel_Demo_Augmentation.obj": "f5583e64976f9165661bee833333ff82",
"assets/assets/models/increasedModel_Demo_Augmentation.mtl": "f5335b2b422d2b49a8a567aabd4dbff0",
"assets/assets/models/increasedModel_Demo_Augmentation.obj": "89ea6009304c10f3b46266ecb2a5c21d",
"assets/assets/models/texture_Demo_Augmentation.png": "17869efe2ba4ea9dd5ee013cb0245936",
"assets/assets/mountain.png": "5ecb41b654f4e8878f59445b948ede50",
"assets/assets/objModel.obj": "43ab0ef3313666ec0f833f239b4073da",
"assets/assets/test.obj": "54aa605baeeae75cb8033411a5203643",
"assets/assets/white.png": "2257e315286ccb4257648bcb36e8899e",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "e7069dfd19b331be16bed984668fe080",
"assets/NOTICES": "4e22c8f2d569d28ed42cca791aaed9ae",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/resources/models/hgcut/fitModel_Hgcutc.mtl": "5f636977a0711fa519b9241bc8b60af6",
"assets/resources/models/hgcut/fitModel_Hgcutc.obj": "70f6af70ba985659f3a2f3f94a1e7ed2",
"assets/resources/models/hgcut/texture_Hgcutc.png": "7ab96e55ada1256549f5ab519212b7f8",
"canvaskit/canvaskit.js": "97937cb4c2c2073c968525a3e08c86a3",
"canvaskit/canvaskit.wasm": "3de12d898ec208a5f31362cc00f09b9e",
"canvaskit/profiling/canvaskit.js": "c21852696bc1cc82e8894d851c01921a",
"canvaskit/profiling/canvaskit.wasm": "371bc4e204443b0d5e774d64a046eb99",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "1cfe996e845b3a8a33f57607e8b09ee4",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "15a2a14a489995f222c3161dd1d31efb",
"/": "15a2a14a489995f222c3161dd1d31efb",
"main.dart.js": "dc52586d12d061362686b6aec79e32ce",
"manifest.json": "4137147246a11ba2148318bc696c4202",
"version.json": "7cd6a41407e3ce7ca7e1a9f156efa75f"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "main.dart.js",
"index.html",
"assets/AssetManifest.json",
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
