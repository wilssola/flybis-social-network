const domain = "flybis.net";

window.isDomain = location.hostname.indexOf(domain) >= 0;
window.isLocalHost = location.hostname.indexOf("localhost") >= 0;
window.isElectron = navigator.userAgent.toLowerCase().indexOf("electron") >= 0;
window.flutterWebRenderer = !window.isElectron ? "html" : "canvaskit";

redirect();
function redirect() {
  // Redirect to correct domain.
  if (!window.isDomain && !window.isLocalHost && !window.isElectron) {
    location.href = "https://" + domain + "/" + window.location.pathname;
  }
}

buildHead();
function buildHead() {
  let base = document.createElement("base");
  let csp = document.createElement("meta");

  if (window.isElectron) {
    base.setAttribute("href", "./");

    csp.setAttribute("http-equiv", "Content-Security-Policy");
    csp.setAttribute(
      "content",
      "default-src 'self' 'unsafe-inline' 'unsafe-hashes' 'unsafe-eval' blob: data: https: https://flybis.net; object-src 'none'; base-uri 'none'; form-action 'self'; font-src 'self'; manifest-src 'self'; worker-src 'self'; img-src https: blob: 'self' https://firebasestorage.googleapis.com; media-src https: blob: 'self' https://firebasestorage.googleapis.com;"
    );
  } else if (windows.isLocalHost) {
    base.setAttribute("href", "/");
  } else {
    base.setAttribute("href", window.location.pathname);
  }

  document.getElementsByTagName("head")[0].appendChild(base);
  document.getElementsByTagName("head")[0].appendChild(csp);
}
