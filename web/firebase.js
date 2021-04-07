console.log("firebase.js loaded");

function loadFirebase() {
  const firebaseVersion = "7.16.1";

  if (window.isDomain) {
    loadJS("/__/firebase/" + firebaseVersion + "/firebase-app.js", false);
    loadJS("/__/firebase/" + firebaseVersion + "/firebase-auth.js", true);
    loadJS("/__/firebase/" + firebaseVersion + "/firebase-firestore.js", true);
    loadJS("/__/firebase/" + firebaseVersion + "/firebase-functions.js", true);
    loadJS("/__/firebase/" + firebaseVersion + "/firebase-storage.js", true);
    loadJS(
      "/__/firebase/" + firebaseVersion + "/firebase-performance.js",
      true
    );
    loadJS("/__/firebase/" + firebaseVersion + "/firebase-database.js", true);
    loadJS("/__/firebase/" + firebaseVersion + "/firebase-analytics.js", true);
  }

  if (window.isLocalHost || window.isElectron) {
    loadJS(
      "https://www.gstatic.com/firebasejs/" +
        firebaseVersion +
        "/firebase-app.js",
      true
    );
    loadJS(
      "https://www.gstatic.com/firebasejs/" +
        firebaseVersion +
        "/firebase-auth.js",
      true
    );
    loadJS(
      "https://www.gstatic.com/firebasejs/" +
        firebaseVersion +
        "/firebase-firestore.js",
      true
    );
    loadJS(
      "https://www.gstatic.com/firebasejs/" +
        firebaseVersion +
        "/firebase-functions.js",
      true
    );
    loadJS(
      "https://www.gstatic.com/firebasejs/" +
        firebaseVersion +
        "/firebase-storage.js",
      true
    );
    loadJS(
      "https://www.gstatic.com/firebasejs/" +
        firebaseVersion +
        "/firebase-performance.js",
      true
    );
    loadJS(
      "https://www.gstatic.com/firebasejs/" +
        firebaseVersion +
        "/firebase-database.js",
      true
    );
    loadJS(
      "https://www.gstatic.com/firebasejs/" +
        firebaseVersion +
        "/firebase-analytics.js",
      true
    );
  }

  if (!window.isElectron) {
    if (window.isDomain) {
      loadJS(
        "/__/firebase/" + firebaseVersion + "/firebase-messaging.js",
        true
      );
    }

    if (window.isLocalHost) {
      loadJS(
        "https://www.gstatic.com/firebasejs/" +
          firebaseVersion +
          "/firebase-messaging.js",
        true
      );
    }
  } else {
    loadJS("./electron-firebase-messaging-sw.js", true);
  }
}

loadFirebase();
