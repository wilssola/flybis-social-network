load();
function load() {
  loadJS("./firebase.js", true);

  window.onload = function () {
    loadJS("./AgoraRtcEngine.bundle.js", null, true);
    
    loadJS("./flybis.js", null, true);
    loadJS("./main.dart.js", null, true);
    loadJS("./worker.js", null, true);
  };
}

function loadJS(src, async, defer, integrity) {
  let script = document.createElement("script");
  if (
    async !== undefined &&
    async !== null &&
    (defer === null || defer === false)
  ) {
    script.async = async;
  }
  if (
    defer !== undefined &&
    defer !== null &&
    (async === null || async === false)
  ) {
    script.defer = defer;
  }
  script.src = src;
  script.type = "text/javascript";
  if (integrity !== undefined && integrity !== null) {
    script.integrity = integrity;
  }

  let s0 = document.getElementsByTagName("script")[0];
  s0.parentNode.insertBefore(script, s0);
}
