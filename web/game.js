
var Module;

if (typeof Module === 'undefined') Module = eval('(function() { try { return Module || {} } catch(e) { return {} } })()');

if (!Module.expectedDataFileDownloads) {
  Module.expectedDataFileDownloads = 0;
  Module.finishedDataFileDownloads = 0;
}
Module.expectedDataFileDownloads++;
(function() {
 var loadPackage = function(metadata) {

  var PACKAGE_PATH;
  if (typeof window === 'object') {
    PACKAGE_PATH = window['encodeURIComponent'](window.location.pathname.toString().substring(0, window.location.pathname.toString().lastIndexOf('/')) + '/');
  } else if (typeof location !== 'undefined') {
      // worker
      PACKAGE_PATH = encodeURIComponent(location.pathname.toString().substring(0, location.pathname.toString().lastIndexOf('/')) + '/');
    } else {
      throw 'using preloaded data can only be done on a web page or in a web worker';
    }
    var PACKAGE_NAME = 'game.data';
    var REMOTE_PACKAGE_BASE = 'game.data';
    if (typeof Module['locateFilePackage'] === 'function' && !Module['locateFile']) {
      Module['locateFile'] = Module['locateFilePackage'];
      Module.printErr('warning: you defined Module.locateFilePackage, that has been renamed to Module.locateFile (using your locateFilePackage for now)');
    }
    var REMOTE_PACKAGE_NAME = typeof Module['locateFile'] === 'function' ?
    Module['locateFile'](REMOTE_PACKAGE_BASE) :
    ((Module['filePackagePrefixURL'] || '') + REMOTE_PACKAGE_BASE);

    var REMOTE_PACKAGE_SIZE = metadata.remote_package_size;
    var PACKAGE_UUID = metadata.package_uuid;

    function fetchRemotePackage(packageName, packageSize, callback, errback) {
      var xhr = new XMLHttpRequest();
      xhr.open('GET', packageName, true);
      xhr.responseType = 'arraybuffer';
      xhr.onprogress = function(event) {
        var url = packageName;
        var size = packageSize;
        if (event.total) size = event.total;
        if (event.loaded) {
          if (!xhr.addedTotal) {
            xhr.addedTotal = true;
            if (!Module.dataFileDownloads) Module.dataFileDownloads = {};
            Module.dataFileDownloads[url] = {
              loaded: event.loaded,
              total: size
            };
          } else {
            Module.dataFileDownloads[url].loaded = event.loaded;
          }
          var total = 0;
          var loaded = 0;
          var num = 0;
          for (var download in Module.dataFileDownloads) {
            var data = Module.dataFileDownloads[download];
            total += data.total;
            loaded += data.loaded;
            num++;
          }
          total = Math.ceil(total * Module.expectedDataFileDownloads/num);
          if (Module['setStatus']) Module['setStatus']('Downloading data... (' + loaded + '/' + total + ')');
        } else if (!Module.dataFileDownloads) {
          if (Module['setStatus']) Module['setStatus']('Downloading data...');
        }
      };
      xhr.onerror = function(event) {
        throw new Error("NetworkError for: " + packageName);
      }
      xhr.onload = function(event) {
        if (xhr.status == 200 || xhr.status == 304 || xhr.status == 206 || (xhr.status == 0 && xhr.response)) { // file URLs can return 0
          var packageData = xhr.response;
          callback(packageData);
        } else {
          throw new Error(xhr.statusText + " : " + xhr.responseURL);
        }
      };
      xhr.send(null);
    };

    function handleError(error) {
      console.error('package error:', error);
    };

    function runWithFS() {

      function assert(check, msg) {
        if (!check) throw msg + new Error().stack;
      }
      Module['FS_createPath']('/', 'fonts', true, true);
      Module['FS_createPath']('/', 'items', true, true);
      Module['FS_createPath']('/items', 'bobskey', true, true);
      Module['FS_createPath']('/', 'maps', true, true);
      Module['FS_createPath']('/maps', 'Asgarour', true, true);
      Module['FS_createPath']('/maps', 'Asgarourhouse1', true, true);
      Module['FS_createPath']('/maps', 'Asgarourhouse2', true, true);
      Module['FS_createPath']('/maps', 'Asgarourhouse3', true, true);
      Module['FS_createPath']('/maps', 'Asgarourhouse4', true, true);
      Module['FS_createPath']('/maps', 'route1', true, true);
      Module['FS_createPath']('/', 'mobs', true, true);
      Module['FS_createPath']('/mobs', 'Skeleton', true, true);
      Module['FS_createPath']('/', 'npcs', true, true);
      Module['FS_createPath']('/npcs', 'Alice', true, true);
      Module['FS_createPath']('/npcs', 'Bob', true, true);
      Module['FS_createPath']('/npcs', 'Dog', true, true);
      Module['FS_createPath']('/npcs', 'Eddy', true, true);
      Module['FS_createPath']('/npcs', 'Jayne', true, true);
      Module['FS_createPath']('/npcs', 'Sam', true, true);
      Module['FS_createPath']('/', 'objectives', true, true);
      Module['FS_createPath']('/', 'pictures', true, true);
      Module['FS_createPath']('/pictures', 'battle', true, true);
      Module['FS_createPath']('/pictures', 'chat', true, true);
      Module['FS_createPath']('/pictures', 'intro', true, true);
      Module['FS_createPath']('/pictures', 'inventory', true, true);
      Module['FS_createPath']('/pictures', 'menu', true, true);
      Module['FS_createPath']('/pictures', 'msg', true, true);
      Module['FS_createPath']('/pictures', 'sprites', true, true);
      Module['FS_createPath']('/', 'sound', true, true);

      function DataRequest(start, end, crunched, audio) {
        this.start = start;
        this.end = end;
        this.crunched = crunched;
        this.audio = audio;
      }
      DataRequest.prototype = {
        requests: {},
        open: function(mode, name) {
          this.name = name;
          this.requests[name] = this;
          Module['addRunDependency']('fp ' + this.name);
        },
        send: function() {},
        onload: function() {
          var byteArray = this.byteArray.subarray(this.start, this.end);

          this.finish(byteArray);

        },
        finish: function(byteArray) {
          var that = this;

        Module['FS_createDataFile'](this.name, null, byteArray, true, true, true); // canOwn this data in the filesystem, it is a slide into the heap that will never change
        Module['removeRunDependency']('fp ' + that.name);

        this.requests[this.name] = null;
      }
    };

    var files = metadata.files;
    for (i = 0; i < files.length; ++i) {
      new DataRequest(files[i].start, files[i].end, files[i].crunched, files[i].audio).open('GET', files[i].filename);
    }


    var indexedDB = window.indexedDB || window.mozIndexedDB || window.webkitIndexedDB || window.msIndexedDB;
    var IDB_RO = "readonly";
    var IDB_RW = "readwrite";
    var DB_NAME = "EM_PRELOAD_CACHE";
    var DB_VERSION = 1;
    var METADATA_STORE_NAME = 'METADATA';
    var PACKAGE_STORE_NAME = 'PACKAGES';
    function openDatabase(callback, errback) {
      try {
        var openRequest = indexedDB.open(DB_NAME, DB_VERSION);
      } catch (e) {
        return errback(e);
      }
      openRequest.onupgradeneeded = function(event) {
        var db = event.target.result;

        if(db.objectStoreNames.contains(PACKAGE_STORE_NAME)) {
          db.deleteObjectStore(PACKAGE_STORE_NAME);
        }
        var packages = db.createObjectStore(PACKAGE_STORE_NAME);

        if(db.objectStoreNames.contains(METADATA_STORE_NAME)) {
          db.deleteObjectStore(METADATA_STORE_NAME);
        }
        var metadata = db.createObjectStore(METADATA_STORE_NAME);
      };
      openRequest.onsuccess = function(event) {
        var db = event.target.result;
        callback(db);
      };
      openRequest.onerror = function(error) {
        errback(error);
      };
    };

    /* Check if there's a cached package, and if so whether it's the latest available */
    function checkCachedPackage(db, packageName, callback, errback) {
      var transaction = db.transaction([METADATA_STORE_NAME], IDB_RO);
      var metadata = transaction.objectStore(METADATA_STORE_NAME);

      var getRequest = metadata.get("metadata/" + packageName);
      getRequest.onsuccess = function(event) {
        var result = event.target.result;
        if (!result) {
          return callback(false);
        } else {
          return callback(PACKAGE_UUID === result.uuid);
        }
      };
      getRequest.onerror = function(error) {
        errback(error);
      };
    };

    function fetchCachedPackage(db, packageName, callback, errback) {
      var transaction = db.transaction([PACKAGE_STORE_NAME], IDB_RO);
      var packages = transaction.objectStore(PACKAGE_STORE_NAME);

      var getRequest = packages.get("package/" + packageName);
      getRequest.onsuccess = function(event) {
        var result = event.target.result;
        callback(result);
      };
      getRequest.onerror = function(error) {
        errback(error);
      };
    };

    function cacheRemotePackage(db, packageName, packageData, packageMeta, callback, errback) {
      var transaction_packages = db.transaction([PACKAGE_STORE_NAME], IDB_RW);
      var packages = transaction_packages.objectStore(PACKAGE_STORE_NAME);

      var putPackageRequest = packages.put(packageData, "package/" + packageName);
      putPackageRequest.onsuccess = function(event) {
        var transaction_metadata = db.transaction([METADATA_STORE_NAME], IDB_RW);
        var metadata = transaction_metadata.objectStore(METADATA_STORE_NAME);
        var putMetadataRequest = metadata.put(packageMeta, "metadata/" + packageName);
        putMetadataRequest.onsuccess = function(event) {
          callback(packageData);
        };
        putMetadataRequest.onerror = function(error) {
          errback(error);
        };
      };
      putPackageRequest.onerror = function(error) {
        errback(error);
      };
    };

    function processPackageData(arrayBuffer) {
      Module.finishedDataFileDownloads++;
      assert(arrayBuffer, 'Loading data file failed.');
      assert(arrayBuffer instanceof ArrayBuffer, 'bad input to processPackageData');
      var byteArray = new Uint8Array(arrayBuffer);
      var curr;

        // copy the entire loaded file into a spot in the heap. Files will refer to slices in that. They cannot be freed though
        // (we may be allocating before malloc is ready, during startup).
        if (Module['SPLIT_MEMORY']) Module.printErr('warning: you should run the file packager with --no-heap-copy when SPLIT_MEMORY is used, otherwise copying into the heap may fail due to the splitting');
        var ptr = Module['getMemory'](byteArray.length);
        Module['HEAPU8'].set(byteArray, ptr);
        DataRequest.prototype.byteArray = Module['HEAPU8'].subarray(ptr, ptr+byteArray.length);

        var files = metadata.files;
        for (i = 0; i < files.length; ++i) {
          DataRequest.prototype.requests[files[i].filename].onload();
        }
        Module['removeRunDependency']('datafile_game.data');

      };
      Module['addRunDependency']('datafile_game.data');

      if (!Module.preloadResults) Module.preloadResults = {};

      function preloadFallback(error) {
        console.error(error);
        console.error('falling back to default preload behavior');
        fetchRemotePackage(REMOTE_PACKAGE_NAME, REMOTE_PACKAGE_SIZE, processPackageData, handleError);
      };

      openDatabase(
        function(db) {
          checkCachedPackage(db, PACKAGE_PATH + PACKAGE_NAME,
            function(useCached) {
              Module.preloadResults[PACKAGE_NAME] = {fromCache: useCached};
              if (useCached) {
                console.info('loading ' + PACKAGE_NAME + ' from cache');
                fetchCachedPackage(db, PACKAGE_PATH + PACKAGE_NAME, processPackageData, preloadFallback);
              } else {
                console.info('loading ' + PACKAGE_NAME + ' from remote');
                fetchRemotePackage(REMOTE_PACKAGE_NAME, REMOTE_PACKAGE_SIZE,
                  function(packageData) {
                    cacheRemotePackage(db, PACKAGE_PATH + PACKAGE_NAME, packageData, {uuid:PACKAGE_UUID}, processPackageData,
                      function(error) {
                        console.error(error);
                        processPackageData(packageData);
                      });
                  }
                  , preloadFallback);
              }
            }
            , preloadFallback);
        }
        , preloadFallback);

      if (Module['setStatus']) Module['setStatus']('Downloading...');

    }
    if (Module['calledRun']) {
      runWithFS();
    } else {
      if (!Module['preRun']) Module['preRun'] = [];
      Module["preRun"].push(runWithFS); // FS is not initialized yet, wait for it
    }

  }
  loadPackage({"package_uuid":"3865fcdc-a2ce-44ba-842e-4eb2b0e10a9c","remote_package_size":8374449,"files":[{"filename":"\\AnAL.lua","crunched":0,"start":0,"end":5569,"audio":false},{"filename":"\\conf.lua","crunched":0,"start":5569,"end":5718,"audio":false},{"filename":"\\fonts\\pixelfont.png","crunched":0,"start":5718,"end":11454,"audio":false},{"filename":"\\fonts\\pixelfontlarge.png","crunched":0,"start":11454,"end":26338,"audio":false},{"filename":"\\fonts\\pixelfontlargew.png","crunched":0,"start":26338,"end":34282,"audio":false},{"filename":"\\fonts\\TwoTrees.ttf","crunched":0,"start":34282,"end":278410,"audio":false},{"filename":"\\fonts\\verdana.ttf","crunched":0,"start":278410,"end":469754,"audio":false},{"filename":"\\items\\bobskey\\image.png","crunched":0,"start":469754,"end":471629,"audio":false},{"filename":"\\items\\bobskey\\sprite.png","crunched":0,"start":471629,"end":471886,"audio":false},{"filename":"\\items\\bobskey\\stats.lua","crunched":0,"start":471886,"end":472065,"audio":false},{"filename":"\\main.lua","crunched":0,"start":472065,"end":510599,"audio":false},{"filename":"\\main_mobile.lua","crunched":0,"start":510599,"end":546535,"audio":false},{"filename":"\\maps\\Asgarour\\background.png","crunched":0,"start":546535,"end":1497305,"audio":false},{"filename":"\\maps\\Asgarour\\collision.png","crunched":0,"start":1497305,"end":1648137,"audio":false},{"filename":"\\maps\\Asgarour\\lights.png","crunched":0,"start":1648137,"end":1735891,"audio":false},{"filename":"\\maps\\Asgarour\\map.lua","crunched":0,"start":1735891,"end":1736215,"audio":false},{"filename":"\\maps\\Asgarour\\overlay.png","crunched":0,"start":1736215,"end":1778122,"audio":false},{"filename":"\\maps\\Asgarourhouse1\\background.png","crunched":0,"start":1778122,"end":1953718,"audio":false},{"filename":"\\maps\\Asgarourhouse1\\collision.png","crunched":0,"start":1953718,"end":1985981,"audio":false},{"filename":"\\maps\\Asgarourhouse1\\map.lua","crunched":0,"start":1985981,"end":1986273,"audio":false},{"filename":"\\maps\\Asgarourhouse1\\overlay.png","crunched":0,"start":1986273,"end":1997201,"audio":false},{"filename":"\\maps\\Asgarourhouse2\\background.png","crunched":0,"start":1997201,"end":2157612,"audio":false},{"filename":"\\maps\\Asgarourhouse2\\collision.png","crunched":0,"start":2157612,"end":2193317,"audio":false},{"filename":"\\maps\\Asgarourhouse2\\map.lua","crunched":0,"start":2193317,"end":2193568,"audio":false},{"filename":"\\maps\\Asgarourhouse2\\overlay.png","crunched":0,"start":2193568,"end":2209721,"audio":false},{"filename":"\\maps\\Asgarourhouse3\\background.png","crunched":0,"start":2209721,"end":2370463,"audio":false},{"filename":"\\maps\\Asgarourhouse3\\collision.png","crunched":0,"start":2370463,"end":2405029,"audio":false},{"filename":"\\maps\\Asgarourhouse3\\map.lua","crunched":0,"start":2405029,"end":2405293,"audio":false},{"filename":"\\maps\\Asgarourhouse3\\overlay.png","crunched":0,"start":2405293,"end":2412288,"audio":false},{"filename":"\\maps\\Asgarourhouse4\\background.png","crunched":0,"start":2412288,"end":2569477,"audio":false},{"filename":"\\maps\\Asgarourhouse4\\collision.png","crunched":0,"start":2569477,"end":2608067,"audio":false},{"filename":"\\maps\\Asgarourhouse4\\map.lua","crunched":0,"start":2608067,"end":2608331,"audio":false},{"filename":"\\maps\\Asgarourhouse4\\overlay.png","crunched":0,"start":2608331,"end":2621311,"audio":false},{"filename":"\\maps\\route1\\background.png","crunched":0,"start":2621311,"end":2743391,"audio":false},{"filename":"\\maps\\route1\\collision.png","crunched":0,"start":2743391,"end":2784818,"audio":false},{"filename":"\\maps\\route1\\lights.png","crunched":0,"start":2784818,"end":2785221,"audio":false},{"filename":"\\maps\\route1\\map.lua","crunched":0,"start":2785221,"end":2785581,"audio":false},{"filename":"\\maps\\route1\\overlay.png","crunched":0,"start":2785581,"end":2802655,"audio":false},{"filename":"\\mobs\\Skeleton\\sprite.png","crunched":0,"start":2802655,"end":2808910,"audio":false},{"filename":"\\mobs\\Skeleton\\stats.lua","crunched":0,"start":2808910,"end":2809105,"audio":false},{"filename":"\\mobs\\spritee.png","crunched":0,"start":2809105,"end":2815367,"audio":false},{"filename":"\\mobs\\spriten.png","crunched":0,"start":2815367,"end":2822376,"audio":false},{"filename":"\\mobs\\sprites.png","crunched":0,"start":2822376,"end":2830227,"audio":false},{"filename":"\\mobs\\spritew.png","crunched":0,"start":2830227,"end":2836468,"audio":false},{"filename":"\\movement.lua","crunched":0,"start":2836468,"end":2845188,"audio":false},{"filename":"\\npcs\\Alice\\picture.png","crunched":0,"start":2845188,"end":2879387,"audio":false},{"filename":"\\npcs\\Alice\\script.lua","crunched":0,"start":2879387,"end":2879485,"audio":false},{"filename":"\\npcs\\Alice\\sprite.png","crunched":0,"start":2879485,"end":2916849,"audio":false},{"filename":"\\npcs\\Bob\\picture.png","crunched":0,"start":2916849,"end":2960908,"audio":false},{"filename":"\\npcs\\Bob\\script.lua","crunched":0,"start":2960908,"end":2961367,"audio":false},{"filename":"\\npcs\\Bob\\sprite.png","crunched":0,"start":2961367,"end":2968173,"audio":false},{"filename":"\\npcs\\Dog\\picture.png","crunched":0,"start":2968173,"end":2972764,"audio":false},{"filename":"\\npcs\\Dog\\script.lua","crunched":0,"start":2972764,"end":2972794,"audio":false},{"filename":"\\npcs\\Dog\\sprite.png","crunched":0,"start":2972794,"end":2978636,"audio":false},{"filename":"\\npcs\\Eddy\\picture.png","crunched":0,"start":2978636,"end":2983227,"audio":false},{"filename":"\\npcs\\Eddy\\script.lua","crunched":0,"start":2983227,"end":2983301,"audio":false},{"filename":"\\npcs\\Eddy\\sprite.png","crunched":0,"start":2983301,"end":3009777,"audio":false},{"filename":"\\npcs\\Jayne\\picture.png","crunched":0,"start":3009777,"end":3014368,"audio":false},{"filename":"\\npcs\\Jayne\\script.lua","crunched":0,"start":3014368,"end":3014426,"audio":false},{"filename":"\\npcs\\Jayne\\sprite.png","crunched":0,"start":3014426,"end":3042802,"audio":false},{"filename":"\\npcs\\Sam\\picture.png","crunched":0,"start":3042802,"end":3047393,"audio":false},{"filename":"\\npcs\\Sam\\script.lua","crunched":0,"start":3047393,"end":3047477,"audio":false},{"filename":"\\npcs\\Sam\\sprite.png","crunched":0,"start":3047477,"end":3072550,"audio":false},{"filename":"\\objectives\\001.lua","crunched":0,"start":3072550,"end":3072807,"audio":false},{"filename":"\\objectives\\001.png","crunched":0,"start":3072807,"end":3123173,"audio":false},{"filename":"\\objectives\\002.lua","crunched":0,"start":3123173,"end":3123472,"audio":false},{"filename":"\\objectives\\002.png","crunched":0,"start":3123472,"end":3125434,"audio":false},{"filename":"\\objectives\\003.lua","crunched":0,"start":3125434,"end":3125647,"audio":false},{"filename":"\\objectives\\003.png","crunched":0,"start":3125647,"end":3127526,"audio":false},{"filename":"\\objectives\\999.lua","crunched":0,"start":3127526,"end":3127735,"audio":false},{"filename":"\\objectives\\999.png","crunched":0,"start":3127735,"end":3128770,"audio":false},{"filename":"\\pictures\\battle\\battlebackground.png","crunched":0,"start":3128770,"end":3429198,"audio":false},{"filename":"\\pictures\\battle\\death.png","crunched":0,"start":3429198,"end":3437174,"audio":false},{"filename":"\\pictures\\battle\\levelup.png","crunched":0,"start":3437174,"end":3445017,"audio":false},{"filename":"\\pictures\\battle\\rbg.png","crunched":0,"start":3445017,"end":3577041,"audio":false},{"filename":"\\pictures\\battle\\targetprompt.png","crunched":0,"start":3577041,"end":3580185,"audio":false},{"filename":"\\pictures\\chat\\chatoverlay.png","crunched":0,"start":3580185,"end":3583986,"audio":false},{"filename":"\\pictures\\intro\\1.png","crunched":0,"start":3583986,"end":3587130,"audio":false},{"filename":"\\pictures\\intro\\10.png","crunched":0,"start":3587130,"end":3589893,"audio":false},{"filename":"\\pictures\\intro\\11.png","crunched":0,"start":3589893,"end":3592613,"audio":false},{"filename":"\\pictures\\intro\\12.png","crunched":0,"start":3592613,"end":3595285,"audio":false},{"filename":"\\pictures\\intro\\13.png","crunched":0,"start":3595285,"end":3597955,"audio":false},{"filename":"\\pictures\\intro\\14.png","crunched":0,"start":3597955,"end":3600591,"audio":false},{"filename":"\\pictures\\intro\\15.png","crunched":0,"start":3600591,"end":3604857,"audio":false},{"filename":"\\pictures\\intro\\16.png","crunched":0,"start":3604857,"end":3611654,"audio":false},{"filename":"\\pictures\\intro\\17.png","crunched":0,"start":3611654,"end":3624043,"audio":false},{"filename":"\\pictures\\intro\\18.png","crunched":0,"start":3624043,"end":3642010,"audio":false},{"filename":"\\pictures\\intro\\19.png","crunched":0,"start":3642010,"end":3663912,"audio":false},{"filename":"\\pictures\\intro\\2.png","crunched":0,"start":3663912,"end":3666776,"audio":false},{"filename":"\\pictures\\intro\\20.png","crunched":0,"start":3666776,"end":3688678,"audio":false},{"filename":"\\pictures\\intro\\21.png","crunched":0,"start":3688678,"end":3710580,"audio":false},{"filename":"\\pictures\\intro\\22.png","crunched":0,"start":3710580,"end":3732482,"audio":false},{"filename":"\\pictures\\intro\\23.png","crunched":0,"start":3732482,"end":3897085,"audio":false},{"filename":"\\pictures\\intro\\24.png","crunched":0,"start":3897085,"end":4061914,"audio":false},{"filename":"\\pictures\\intro\\25.png","crunched":0,"start":4061914,"end":4226729,"audio":false},{"filename":"\\pictures\\intro\\26.png","crunched":0,"start":4226729,"end":4391558,"audio":false},{"filename":"\\pictures\\intro\\27.png","crunched":0,"start":4391558,"end":4554709,"audio":false},{"filename":"\\pictures\\intro\\3.png","crunched":0,"start":4554709,"end":4557573,"audio":false},{"filename":"\\pictures\\intro\\4.png","crunched":0,"start":4557573,"end":4560437,"audio":false},{"filename":"\\pictures\\intro\\5.png","crunched":0,"start":4560437,"end":4563297,"audio":false},{"filename":"\\pictures\\intro\\6.png","crunched":0,"start":4563297,"end":4566119,"audio":false},{"filename":"\\pictures\\intro\\7.png","crunched":0,"start":4566119,"end":4568930,"audio":false},{"filename":"\\pictures\\intro\\8.png","crunched":0,"start":4568930,"end":4571698,"audio":false},{"filename":"\\pictures\\intro\\9.png","crunched":0,"start":4571698,"end":4574470,"audio":false},{"filename":"\\pictures\\inventory\\inventoryoverlay.png","crunched":0,"start":4574470,"end":4580260,"audio":false},{"filename":"\\pictures\\menu\\bg.jpg","crunched":0,"start":4580260,"end":4641677,"audio":false},{"filename":"\\pictures\\menu\\bg.png","crunched":0,"start":4641677,"end":4693197,"audio":false},{"filename":"\\pictures\\menu\\controls.png","crunched":0,"start":4693197,"end":4723284,"audio":false},{"filename":"\\pictures\\msg\\msgoverlay.png","crunched":0,"start":4723284,"end":4727039,"audio":false},{"filename":"\\pictures\\splash.png","crunched":0,"start":4727039,"end":7712615,"audio":false},{"filename":"\\pictures\\sprites\\battle.png","crunched":0,"start":7712615,"end":7729386,"audio":false},{"filename":"\\pictures\\sprites\\picture.png","crunched":0,"start":7729386,"end":7730821,"audio":false},{"filename":"\\pictures\\sprites\\prompt.png","crunched":0,"start":7730821,"end":7733718,"audio":false},{"filename":"\\pictures\\sprites\\protagss.png","crunched":0,"start":7733718,"end":7767947,"audio":false},{"filename":"\\res.lua","crunched":0,"start":7767947,"end":7770150,"audio":false},{"filename":"\\sound\\fotd.ogg","crunched":0,"start":7770150,"end":8365930,"audio":true},{"filename":"\\sound\\menumove.ogg","crunched":0,"start":8365930,"end":8374449,"audio":true}]});

})();
