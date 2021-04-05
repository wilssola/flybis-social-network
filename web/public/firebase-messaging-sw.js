console.log("firebase-messaging-sw.js loaded");

// Give the service worker access to Firebase Messaging. Note that you can only use Firebase Messaging here, other Firebase libraries are not available in the service worker.
importScripts("https://www.gstatic.com/firebasejs/7.17.1/firebase-app.js");
importScripts(
  "https://www.gstatic.com/firebasejs/7.17.1/firebase-messaging.js"
);

// Initialize the Firebase app in the service worker by passing in your app's Firebase config object.
firebase.initializeApp({
  apiKey: "AIzaSyDVPjDNuRCFqq7UmbdNM0EOPqSC_pUgDMc",
  authDomain: "flybis.firebaseapp.com",
  databaseURL: "https://flybis.firebaseio.com",
  projectId: "flybis",
  storageBucket: "flybis.appspot.com",
  messagingSenderId: "505131215378",
  appId: "1:505131215378:web:e06f953492488ed38d06cb",
  measurementId: "G-FCENZTTDYN",
});

// If you would like to customize notifications that are received in the background (Web app is closed or not in browser focus) then you should implement this optional method.
firebase.messaging().setBackgroundMessageHandler((payload) => {
  console.log("Message received", payload);
  // Customize notification here.
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "./icon.png",
  };

  return self.registration.showNotification(
    notificationTitle,
    notificationOptions
  );
});
