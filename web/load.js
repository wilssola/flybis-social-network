load();
function load() {
  loadJS("./firebase.js", true);

  window.onload = function () {
    loadJS("./flybis.js", false, true);
    loadJS("./main.dart.js", false, true);
    loadJS("./worker.js", false, true);
  };
}

function loadJS(src, async, defer, integrity) {
  let script = document.createElement("script");

  if (async == true) {
    script.async = async;
  }
  if (defer == true) {
    script.defer = defer;
  }

  script.src = src;
  script.type = "text/javascript";

  if (integrity !== undefined && integrity !== null) {
    script.integrity = integrity;
  }

  let script0 = document.getElementsByTagName("script")[0];
  script0.parentNode.insertBefore(script, script0);
}
