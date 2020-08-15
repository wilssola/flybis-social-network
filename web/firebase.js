var firebaseVersion = "7.16.1";

if (location.hostname.indexOf("flybis.tecwolf.com.br") >= 0) {
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

if (location.hostname.indexOf("localhost") >= 0) {
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

if (navigator.userAgent.toLowerCase().indexOf("electron") === -1) {
  if (location.hostname.indexOf("flybis.tecwolf.com.br") >= 0) {
    document.write(
      unescape(
        '%3Cscript src="/__/firebase/' +
          firebaseVersion +
          '/firebase-messaging.js"%3E %3C/script%3E'
      )
    );
  } else {
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
      '%3Cscript src="./electron-firebase-messaging-sw.js"%3E %3C/script%3E'
    )
  );
}
