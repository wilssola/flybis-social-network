function loadJS(src, async) {
  let script = document.createElement("script");
  script.async = async;
  script.src = src;
  script.type = "text/javascript";

  let s0 = document.getElementsByTagName("script")[0];
  s0.parentNode.insertBefore(script, s0);
}

loadJS("./head.js", false);
loadJS("./dark.js", false);
loadJS("./firebase.js", false);

window.onload = function () {
  loadJS("./flybis.js", true);
  loadJS("./main.dart.js", true);
  loadJS("./worker.js", true);
};
