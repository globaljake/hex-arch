import "./index.css";

import { Elm } from "./Main.elm";
import Port from "./Port";
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

//  Instructions
Port.instruction(app, "session");
Port.instruction(app, "modal");
Port.instruction(app, "toast");

// Events
Port.event(app, "session");
Port.event(app, "editProfile");

Session.start(app);
