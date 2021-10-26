console.log("firebase.js loaded");

loadFirebase();
function loadFirebase() {
  const firebaseVersion = "8.9.0";
  const firebaseInternal = "/__/firebase/" + firebaseVersion;
  const firebaseExternal = "https://cdn.jsdelivr.net/npm/firebase@latest";

  if (window.isDomain) {
    loadJS(firebaseInternal + "/firebase-app.js", true);

    loadJS(firebaseInternal + "/firebase-app-check.js", false, true);
    
    loadJS(firebaseInternal + "/firebase-auth.js", false, true);
    loadJS(firebaseInternal + "/firebase-firestore.js", false, true);
    loadJS(firebaseInternal + "/firebase-functions.js", false, true);
    loadJS(firebaseInternal + "/firebase-storage.js", false, true);
    loadJS(firebaseInternal + "/firebase-performance.js", false, true);
    loadJS(firebaseInternal + "/firebase-database.js", false, true);
    loadJS(firebaseInternal + "/firebase-analytics.js", false, true);   
    loadJS(firebaseInternal + "/firebase-messaging.js", false, true);
  }

  if (window.isLocalHost || window.isElectron) {
    loadJS(firebaseExternal + "/firebase-app.js", true);

    self.FIREBASE_APPCHECK_DEBUG_TOKEN = true;
    loadJS(firebaseExternal + "/firebase-app-check.js", false, true);

    loadJS(firebaseExternal + "/firebase-auth.js", false, true);
    loadJS(firebaseExternal + "/firebase-firestore.js", false, true);
    loadJS(firebaseExternal + "/firebase-functions.js", false, true);
    loadJS(firebaseExternal + "/firebase-storage.js", false, true);
    loadJS(firebaseExternal + "/firebase-performance.js", false, true);
    loadJS(firebaseExternal + "/firebase-database.js", false, true);
    loadJS(firebaseExternal + "/firebase-analytics.js", false, true);    
    loadJS(firebaseExternal + "/firebase-messaging.js", false, true);

    if(window.isElectron) {
      loadJS("./electron-firebase-messaging-sw.js", false, true);
    }
  }
}
