console.log("flybis.js loaded");const firebaseConfig={apiKey:"AIzaSyDVPjDNuRCFqq7UmbdNM0EOPqSC_pUgDMc",authDomain:"flybis.firebaseapp.com",databaseURL:"https://flybis.firebaseio.com",projectId:"flybis",storageBucket:"flybis.appspot.com",messagingSenderId:"505131215378",appId:"1:505131215378:web:e06f953492488ed38d06cb",measurementId:"G-FCENZTTDYN"};initializeFirebase();function initializeFirebase(){let authUser;let hasUser=false;firebase.initializeApp(firebaseConfig);firebase.analytics();firebase.performance();if(!isElectron){firebase.messaging().usePublicVapidKey("BO3GVEHUf9LIgu0tyOlyDvPX91D3LQOd0JsDh4881BkDwR4uhdIiB8bI9gdpoyynOLGwyNi49tpgUFOIyZPXf78");firebase.messaging().requestPermission().then((()=>{console.log("FCM Request Success");firebase.messaging().getToken().then((currentToken=>{if(currentToken){window.messagingToken=currentToken;writeTokenFCM(window.messagingToken);console.log("FCM: "+currentToken)}else{console.log("No Instance FCM token available")}})).catch((error=>{console.log("An error occurred while retrieving token",error)}))})).catch((error=>{window.messagingToken=null;console.log("FCM Request Error",error)}));firebase.messaging().onTokenRefresh((()=>{firebase.messaging().getToken().then((refreshedToken=>{if(refreshedToken){window.messagingToken=refreshedToken;writeTokenFCM(window.messagingToken);console.log("FCM Refreshed: "+refreshedToken)}else{console.log("No Instance FCM token available")}})).catch((error=>{console.log("Unable to retrieve refreshed token",error)}))}));firebase.messaging().onMessage((payload=>{console.log("Message received",payload);Toastify({avatar:"",text:payload.notification.body,duration:5e3,close:true,gravity:"bottom",position:"left",backgroundColor:"black",stopOnFocus:true,onClick:()=>{}}).showToast()}))}firebase.auth().onAuthStateChanged((function(user){if(user){hasUser=true;authUser=user;writeTokenFCM(window.messagingToken);console.log("UID: "+user.uid)}else{if(hasUser){console.log("Logout");document.location.reload()}authUser=user}}));const db=indexedDB.open("flybis");db.onsuccess=()=>{firebase.firestore().settings({cacheSizeBytes:firebase.firestore.CACHE_SIZE_UNLIMITED});firebase.firestore().enablePersistence().then((()=>{console.log("Persistence enabled")})).catch((error=>{if(error.code=="failed-precondition"){console.error("Persistence work only in one tab",error)}else if(error.code=="unimplemented"){console.error("Browser not support persistence",error)}else{console.error("Enable persistence results a error",error)}}))};db.onerror=()=>{console.log("Persistence dont enabled")};function writeTokenFCM(messagingToken){if(authUser&&messagingToken!=null){firebase.firestore().collection("users").doc(authUser.uid).collection("tokens").doc("fcm").get().then((doc=>{let platformToken;if(!isElectron){platformToken={webToken:messagingToken}}else{platformToken={electronToken:messagingToken}}if(doc.exists){firebase.firestore().collection("users").doc(authUser.uid).collection("tokens").doc("fcm").update(platformToken)}else{firebase.firestore().collection("users").doc(authUser.uid).collection("tokens").doc("fcm").set(platformToken)}}))}}}document.addEventListener("keydown",(function(event){if(event.code=="Tab"){event.preventDefault()}}));