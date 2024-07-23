importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyDBxEFlI93wyTcGek3NtItaRA6KB0PZaDU",
  authDomain: "chit-chat-19491.firebaseapp.com",
//   databaseURL: "...",
  projectId: "chit-chat-19491",
  storageBucket: "chit-chat-19491.appspot.com",
  messagingSenderId: "789734382133",
  appId: "1:789734382133:web:896184c5ced9f462a36f7c",
});

const messaging = firebase.messaging();
