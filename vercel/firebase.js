const admin = require("firebase-admin");

const serviceAccount = require('./flybis-firebase-adminsdk-4g9tx-a8b1fce99a.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://flybis.firebaseio.com",
});

module.exports = admin;