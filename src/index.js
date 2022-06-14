import "./index.css";

import { Elm } from "./Main.elm";

import Viewer from "./Viewer";
import Relay from "./Relay";

const flags = { viewer: Viewer.getLocalStorage() };

const app = Elm.Main.init({
  node: document.querySelector("main"),
  flags: flags,
});

Viewer.start(app);
Relay.start(app);
