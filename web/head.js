window.isElectron = navigator.userAgent.toLowerCase().indexOf("electron") >= 0;

document.write(window.isElectron ? '<base href="./">' : '<base href="/app/">');

document.write(
  window.isElectron
    ? "<meta http-equiv=\"Content-Security-Policy\" content=\"default-src 'self' 'unsafe-inline' 'unsafe-hashes' 'unsafe-eval' data: https: https://flybis.net; object-src 'none'; base-uri 'none'; form-action 'self'; frame-ancestors 'self'; font-src 'self'; manifest-src 'self'; worker-src 'self'; img-src https: blob: 'self' https://firebasestorage.googleapis.com; media-src https: blob: 'self' https://firebasestorage.googleapis.com;\">"
    : ""
);
