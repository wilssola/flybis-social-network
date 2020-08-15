console.log("flybis.js loaded");

// Set Firebase Configuration.
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

// Initialize Firebase.
firebase.initializeApp(firebaseConfig);
// Initialize Firebase Analytics.
firebase.analytics();
// Initialize Firebase Performance Monitoring.
firebase.performance();

// Enable Firestore Cache.
firebase.firestore().settings({
  cacheSizeBytes: firebase.firestore.CACHE_SIZE_UNLIMITED,
});
firebase
  .firestore()
  .enablePersistence()
  .catch(function (error) {
    if (error.code == "failed-precondition") {
      // Multiple tabs open, persistence can only be enabled in one tab at a a time.
      console.log("Persistence work only in one tab ", error);
    } else if (error.code == "unimplemented") {
      // The current browser does not support all of the features required to enable persistence.
      console.log("Browser not support persistence ", error);
    } else {
      console.log("Enable persistence results a error ", error);
    }
  });

// Firebase Auth vars.
var authUser;
var hasUser = false;

// Use Firebase Messaging for Browsers.
if (navigator.userAgent.toLowerCase().indexOf("electron") === -1) {
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
          if (currentToken) {
            window.messagingToken = currentToken;

            writeTokenFCM(window.messagingToken);

            console.log("FCM: " + currentToken);
          } else {
            console.log("No Instance FCM token available");
          }
        })
        .catch((error) => {
          console.log("An error occurred while retrieving token ", error);
        });
    })
    .catch((error) => {
      window.messagingToken = null;

      console.log("FCM Request Error ", error);
    });

  // Callback fired if Instance ID token is updated.
  firebase.messaging().onTokenRefresh(() => {
    firebase
      .messaging()
      .getToken()
      .then((refreshedToken) => {
        if (refreshedToken) {
          window.messagingToken = refreshedToken;

          writeTokenFCM(window.messagingToken);

          console.log("FCM Refreshed: " + refreshedToken);
        } else {
          console.log("No Instance FCM token available");
        }
      })
      .catch((error) => {
        console.log("Unable to retrieve refreshed token ", error);
      });
  });

  // Handle incoming messages. Called when:
  // - A message is received while the app has focus.
  // - The user clicks on an app notification created by a service worker `messaging.setBackgroundMessageHandler` handler.
  firebase.messaging().onMessage((payload) => {
    console.log("Message received ", payload);

    Toastify({
      avatar: "",
      text: payload.notification.body,
      duration: 5000,
      close: true,
      gravity: "bottom",
      position: "left",
      backgroundColor: "black",
      stopOnFocus: true,
      onClick: () => {},
    }).showToast();
  });
}

// Check Firebase Auth.
firebase.auth().onAuthStateChanged(function (user) {
  if (user) {
    hasUser = true;
    authUser = user;

    writeTokenFCM(window.messagingToken);

    console.log("UID: " + user.uid);
  } else {
    // Fix to Phoenix logout.
    if (hasUser) {
      document.location.reload();
    }

    authUser = user;
  }
});

// Keyboard navigation with TAB.
document.addEventListener("keydown", function (event) {
  if (event.code == "Tab") {
    event.preventDefault();
  }
});

function writeTokenFCM(messagingToken) {
  if (authUser && messagingToken != null) {
    firebase
      .firestore()
      .collection("users")
      .doc(authUser.uid)
      .collection("tokens")
      .doc("fcm")
      .get()
      .then((doc) => {
        if (doc.exists) {
          firebase
            .firestore()
            .collection("users")
            .doc(authUser.uid)
            .collection("tokens")
            .doc("fcm")
            .update({
              webToken: messagingToken,
            });
        } else {
          firebase
            .firestore()
            .collection("users")
            .doc(authUser.uid)
            .collection("tokens")
            .doc("fcm")
            .set({
              webToken: messagingToken,
            });
        }
      });
  }
}
