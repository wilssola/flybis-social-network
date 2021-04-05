console.log("firebase.js loaded");

const domain = "flybis.net";

const isDomain = location.hostname.indexOf(domain) >= 0;
const isLocalHost = location.hostname.indexOf("localhost") >= 0;
const isElectron = navigator.userAgent.toLowerCase().indexOf("electron") >= 0;

if (!isDomain && !isLocalHost && !isElectron) {
  location.href = "https://" + domain + "/app/#" + window.location.pathname;
}

const firebaseVersion = "7.16.1";

if (isDomain) {
  document.write(
    unescape(
      '%3Cscript src="/__/firebase/' +
        firebaseVersion +
        '/firebase-app.js"%3E %3C/script%3E' +
        '%3Cscript src="/__/firebase/' +
        firebaseVersion +
        '/firebase-auth.js"%3E %3C/script%3E' +
        '%3Cscript src="/__/firebase/' +
        firebaseVersion +
        '/firebase-firestore.js"%3E %3C/script%3E' +
        '%3Cscript src="/__/firebase/' +
        firebaseVersion +
        '/firebase-functions.js"%3E %3C/script%3E' +
        '%3Cscript src="/__/firebase/' +
        firebaseVersion +
        '/firebase-storage.js"%3E %3C/script%3E' +
        '%3Cscript src="/__/firebase/' +
        firebaseVersion +
        '/firebase-performance.js"%3E %3C/script%3E' +
        '%3Cscript src="/__/firebase/' +
        firebaseVersion +
        '/firebase-database.js"%3E %3C/script%3E' +
        '%3Cscript src="/__/firebase/' +
        firebaseVersion +
        '/firebase-analytics.js"%3E %3C/script%3E'
    )
  );
}

if (isLocalHost || isElectron) {
  document.write(
    unescape(
      '%3Cscript src="https://www.gstatic.com/firebasejs/' +
        firebaseVersion +
        '/firebase-app.js"%3E %3C/script%3E' +
        '%3Cscript src="https://www.gstatic.com/firebasejs/' +
        firebaseVersion +
        '/firebase-auth.js"%3E %3C/script%3E' +
        '%3Cscript src="https://www.gstatic.com/firebasejs/' +
        firebaseVersion +
        '/firebase-firestore.js"%3E %3C/script%3E' +
        '%3Cscript src="https://www.gstatic.com/firebasejs/' +
        firebaseVersion +
        '/firebase-functions.js"%3E %3C/script%3E' +
        '%3Cscript src="https://www.gstatic.com/firebasejs/' +
        firebaseVersion +
        '/firebase-storage.js"%3E %3C/script%3E' +
        '%3Cscript src="https://www.gstatic.com/firebasejs/' +
        firebaseVersion +
        '/firebase-performance.js"%3E %3C/script%3E' +
        '%3Cscript src="https://www.gstatic.com/firebasejs/' +
        firebaseVersion +
        '/firebase-database.js"%3E %3C/script%3E' +
        '%3Cscript src="https://www.gstatic.com/firebasejs/' +
        firebaseVersion +
        '/firebase-analytics.js"%3E %3C/script%3E'
    )
  );
}

if (!isElectron) {
  if (isDomain) {
    document.write(
      unescape(
        '%3Cscript src="/__/firebase/' +
          firebaseVersion +
          '/firebase-messaging.js"%3E %3C/script%3E'
      )
    );
  }

  if (isLocalHost) {
    document.write(
      unescape(
        '%3Cscript src="https://www.gstatic.com/firebasejs/' +
          firebaseVersion +
          '/firebase-messaging.js"%3E %3C/script%3E'
      )
    );
  }
} else {
  document.write(
    unescape(
      '%3Cscript src="https://www.gstatic.com/firebasejs/' +
        firebaseVersion +
        '/firebase-messaging.js"%3E %3C/script%3E'
    )
  );
  document.write(
    unescape(
      '%3Cscript src="./electron-firebase-messaging-sw.js"%3E %3C/script%3E'
    )
  );
}
