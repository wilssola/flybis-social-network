console.log("flybis.js loaded");

flutterWeb();
function flutterWeb() {
  // Keyboard navigation with TAB.
  document.addEventListener("keydown", function (event) {
    if (event.code == "Tab") {
      event.preventDefault();
    }
  });
}

initializeFirebase();
function initializeFirebase() {
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

  let authUser;
  let hasUser = false;

  // Initialize Firebase.
  firebase.initializeApp(firebaseConfig);
  // Initialize Firebase Analytics.
  firebase.analytics();
  // Initialize Firebase Performance Monitoring.
  firebase.performance();

  // Use Firebase Messaging for Browsers.
  if (!window.isElectron) {
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

              writeTokenFCM(authUser, window.messagingToken);

              console.log("FCM: " + currentToken);
            } else {
              console.log("No Instance FCM token available");
            }
          })
          .catch((error) => {
            console.log("An error occurred while retrieving token", error);
          });
      })
      .catch((error) => {
        window.messagingToken = null;

        console.log("FCM Request Error", error);
      });

    // Callback fired if Instance ID token is updated.
    firebase.messaging().onTokenRefresh(() => {
      firebase
        .messaging()
        .getToken()
        .then((refreshedToken) => {
          if (refreshedToken) {
            window.messagingToken = refreshedToken;

            writeTokenFCM(authUser, window.messagingToken);

            console.log("FCM Refreshed: " + refreshedToken);
          } else {
            console.log("No Instance FCM token available");
          }
        })
        .catch((error) => {
          console.log("Unable to retrieve refreshed token", error);
        });
    });

    // Handle incoming messages. Called when:
    // - A message is received while the app has focus.
    // - The user clicks on an app notification created by a service worker `messaging.setBackgroundMessageHandler` handler.
    firebase.messaging().onMessage((payload) => {
      console.log("Message received", payload);

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

      writeTokenFCM(authUser, window.messagingToken);

      console.log("UID: " + user.uid);
    } else {
      // Fix to Phoenix logout.
      if (hasUser) {
        console.log("Logout");

        document.location.reload();
      }

      authUser = user;
    }
  });

  // Enable Firestore Cache.
  const db = indexedDB.open("flybis");
  db.onsuccess = () => {
    firebase.firestore().settings({
      cacheSizeBytes: firebase.firestore.CACHE_SIZE_UNLIMITED,
    });
    firebase
      .firestore()
      .enablePersistence({
        experimentalTabSynchronization: true,
      })
      .then(() => {
        console.log("Persistence enabled");
      })
      .catch((error) => {
        if (error.code == "failed-precondition") {
          // Multiple tabs open, persistence can only be enabled in one tab at a a time.
          console.error("Persistence work only in one tab", error);
        } else if (error.code == "unimplemented") {
          // The current browser does not support all of the features required to enable persistence.
          console.error("Browser not support persistence", error);
        } else {
          console.error("Enable persistence results a error", error);
        }
      });
  };
  db.onerror = () => {
    console.log("Persistence dont enabled");
  };
}

function writeTokenFCM(user, messagingToken) {
  if (user && messagingToken != null) {
    firebase
      .firestore()
      .collection("users")
      .doc(user.uid)
      .collection("tokens")
      .doc("fcm")
      .get()
      .then((doc) => {
        let platformToken;

        if (!window.isElectron) {
          platformToken = { webToken: messagingToken };
        } else {
          platformToken = { electronToken: messagingToken };
        }

        if (doc.exists) {
          firebase
            .firestore()
            .collection("users")
            .doc(user.uid)
            .collection("tokens")
            .doc("fcm")
            .update(platformToken);
        } else {
          firebase
            .firestore()
            .collection("users")
            .doc(user.uid)
            .collection("tokens")
            .doc("fcm")
            .set(platformToken);
        }
      });
  }
}
