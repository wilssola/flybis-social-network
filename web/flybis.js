// Set Firebase Configuration
const firebaseConfig = {
  apiKey: "AIzaSyDVPjDNuRCFqq7UmbdNM0EOPqSC_pUgDMc",
  authDomain: "flybis.firebaseapp.com",
  databaseURL: "https://flybis.firebaseio.com",
  projectId: "flybis",
  storageBucket: "flybis.appspot.com",
  messagingSenderId: "505131215378",
  appId: "1:505131215378:web:e06f953492488ed38d06cb",
  measurementId: "G-FCENZTTDYN",
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
firebase.analytics();
// Initialize Performance Monitoring
firebase.performance();

// Enable Firestore Cache
firebase.firestore().settings({
  cacheSizeBytes: firebase.firestore.CACHE_SIZE_UNLIMITED,
});
firebase
  .firestore()
  .enablePersistence()
  .catch(function (error) {
    if (error.code == "failed-precondition") {
      // Multiple tabs open, persistence can only be enabled in one tab at a a time
      console.log("Persistence work only in one tab", error);
    } else if (error.code == "unimplemented") {
      // The current browser does not support all of the features required to enable persistence
      console.log("Browser not support persistence", error);
    } else {
      console.log("Enable persistence results a error", error);
    }
  });

// Get Firebase Messaging
var messagingToken;
firebase
  .messaging()
  .usePublicVapidKey(
    "BO3GVEHUf9LIgu0tyOlyDvPX91D3LQOd0JsDh4881BkDwR4uhdIiB8bI9gdpoyynOLGwyNi49tpgUFOIyZPXf78"
  );
firebase
  .messaging()
  .requestPermission()
  .then(() => {
    console.log("FCM Request Success");

    firebase
      .messaging()
      .getToken()
      .then((currentToken) => {
        messagingToken = currentToken;

        console.log("FCM: " + currentToken);
      });
  })
  .catch((error) => {
    messagingToken = null;

    console.log("FCM Request Error", error);
  });

// Check Firebase Auth
var hasUser = false;
firebase.auth().onAuthStateChanged(function (user) {
  if (user) {
    if (messagingToken != null) {
      firebase
        .firestore()
        .collection("users")
        .doc(user.uid)
        .collection("tokens")
        .doc("fcm")
        .get()
        .then((doc) => {
          if (doc.exists) {
            firebase
              .firestore()
              .collection("users")
              .doc(user.uid)
              .collection("tokens")
              .doc("fcm")
              .update({
                webToken: messagingToken,
              });
          } else {
            firebase
              .firestore()
              .collection("users")
              .doc(user.uid)
              .collection("tokens")
              .doc("fcm")
              .set({
                webToken: messagingToken,
              });
          }
        });
    }

    hasUser = true;

    console.log("UID: " + user.uid);
  } else {
    // Fix to Phoenix logout
    if (hasUser) {
      document.location.reload();
    }
  }
});

// Keyboard navigation with TAB
document.addEventListener("keydown", function (event) {
  if (event.code == "Tab") {
    event.preventDefault();
  }
});
