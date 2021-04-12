// This file is required by the index.html file and will be executed in the renderer process for that window.
// All of the Node.js APIs are available in this process.
console.log("electron-firebase-messaging-sw.js loaded");

loadMessaging();

function loadMessaging() {
  const { ipcRenderer } = require("electron");

  const {
    START_NOTIFICATION_SERVICE,
    NOTIFICATION_SERVICE_STARTED,
    NOTIFICATION_SERVICE_ERROR,
    NOTIFICATION_RECEIVED,
    TOKEN_UPDATED,
  } = require("electron-push-receiver/src/constants");

  const Toastify = require("toastify-js");

  // Listen for service successfully started.
  ipcRenderer.on(NOTIFICATION_SERVICE_STARTED, (_, token) => {
    window.messagingToken = token;

    console.log("FCM: " + token);
  });

  // Handle notification errors.
  ipcRenderer.on(NOTIFICATION_SERVICE_ERROR, (_, error) => {
    console.log("FCM Request Error", error);
  });

  // Send FCM token to backend.
  ipcRenderer.on(TOKEN_UPDATED, (_, refreshedToken) => {
    window.messagingToken = refreshedToken;

    console.log("FCM Refreshed: " + refreshedToken);
  });

  // Display notification.
  ipcRenderer.on(NOTIFICATION_RECEIVED, (_, payload) => {
    // Check to see if payload contains a body string, if it doesn't consider it a silent push.ssss
    if (payload.notification.body) {
      // Payload has a body, so show it to the user.
      console.log("Message Received", payload);

      let notification = new Notification(payload.notification.title, {
        body: payload.notification.body,
        image: payload.notification.image,
        icon: payload.notification.icon,
      });

      notification.onclick = () => {
        console.log("Notification Clicked");

        ipcRenderer.send("notification_clicked");
      };

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
    } else {
      // Payload has no body, so consider it silent (and just consider the data portion).
      console.log(
        "No body use the key/value pairs in the payload data",
        payload.data
      );
    }
  });

  // Start service.
  const senderId = "505131215378"; // FCM sender ID from FCM web admin under Settings -> Cloud Messaging.
  ipcRenderer.send(START_NOTIFICATION_SERVICE, senderId);
  console.log("FCM Request Success");
}
