import "./index.css";

import { Elm } from "./Main.elm";
import Adapter from "./Adapter";
import Viewer from "./Viewer";

const flags = { viewer: Viewer.getLocalStorage() };

const app = Elm.Main.init({
  node: document.querySelector("main"),
  flags: flags,
});

// Primary Adapters
Adapter.primary(app, "Session");
Adapter.primary(app, "Modal");
Adapter.primary(app, "Toast");

// Secondary Adapters
Adapter.secondary(app, "Session");
Adapter.secondary(app, "ThingForm");

// Modules
Viewer.start(app);
