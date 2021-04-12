console.log("firebase.js loaded");

loadFirebase();
function loadFirebase() {
  const firebaseVersion = "7.18.0";
  const firebaseInternal = "/__/firebase/" + firebaseVersion;
  const firebaseExternal =
    "https://www.gstatic.com/firebasejs/" + firebaseVersion;

  if (window.isDomain) {
    loadJS(firebaseInternal + "/firebase-app.js", true);

    loadJS(firebaseInternal + "/firebase-auth.js", null, true);
    loadJS(firebaseInternal + "/firebase-firestore.js", null, true);
    loadJS(firebaseInternal + "/firebase-functions.js", null, true);
    loadJS(firebaseInternal + "/firebase-storage.js", null, true);
    loadJS(firebaseInternal + "/firebase-performance.js", null, true);
    loadJS(firebaseInternal + "/firebase-database.js", null, true);
    loadJS(firebaseInternal + "/firebase-analytics.js", null, true);
  }

  if (window.isLocalHost || window.isElectron) {
    loadJS(firebaseExternal + "/firebase-app.js", false);

    loadJS(firebaseExternal + "/firebase-auth.js", null, true);
    loadJS(firebaseExternal + "/firebase-firestore.js", null, true);
    loadJS(firebaseExternal + "/firebase-functions.js", null, true);
    loadJS(firebaseExternal + "/firebase-storage.js", null, true);
    loadJS(firebaseExternal + "/firebase-performance.js", null, true);
    loadJS(firebaseExternal + "/firebase-database.js", null, true);
    loadJS(firebaseExternal + "/firebase-analytics.js", null, true);
  }

  if (!window.isElectron) {
    if (window.isDomain) {
      loadJS(firebaseInternal + "/firebase-messaging.js", null, true);
    }

    if (window.isLocalHost) {
      loadJS(firebaseExternal + "/firebase-messaging.js", null, true);
    }
  } else {
    loadJS(firebaseExternal + "/firebase-messaging.js", null, true);

    loadJS("./electron-firebase-messaging-sw.js", null, true);
  }
}
