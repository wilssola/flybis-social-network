import firebase from "firebase/app";
import 'firebase/analytics';
import 'firebase/performance';

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

export const firebaseInit = firebase.initializeApp(firebaseConfig);
export const firebaseAnalytics = firebase.analytics();
export const firebasePerfomance = firebase.performance();
