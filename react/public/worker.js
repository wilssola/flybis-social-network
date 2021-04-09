if ("serviceWorker" in navigator) {
  window.addEventListener("load", function () {
    navigator.serviceWorker.register(
      "https://flybis.net/app/flutter_service_worker.js"
    );
  });
}
