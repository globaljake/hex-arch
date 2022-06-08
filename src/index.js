import "./index.css";

import { Elm } from "./Main.elm";
import ModuleRequest from "./ModuleRequest";
import Session from "./Session";

const flags = { viewer: Session.getViewer() };

// var app = Elm.Main.init({ flags: flags });

// app.ports.storeCache.subscribe(function (val) {
//   if (val === null) {
//     localStorage.removeItem(storageKey);
//   } else {
//     localStorage.setItem(storageKey, JSON.stringify(val));
//   }

//   // Report that the new session was stored successfully.
//   setTimeout(function () {
//     app.ports.onStoreChange.send(val);
//   }, 0);
// });

// // Whenever localStorage changes in another tab, report it if necessary.
// window.addEventListener(
//   "storage",
//   function (event) {
//     if (event.storageArea === localStorage && event.key === storageKey) {
//       app.ports.onStoreChange.send(event.newValue);
//     }
//   },
//   false
// );

const app = Elm.Main.init({
  node: document.querySelector("main"),
  flags: flags,
});

ModuleRequest.relay(app, "sessionSendRequest", "sessionReceiveRequest");
ModuleRequest.relay(app, "modalSendInstruction", "modalReceiveInstruction");

Session.start(app);
