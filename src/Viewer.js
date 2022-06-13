const STORAGE_KEY = "hex-arch-viewer";

export default {
  start(app) {
    if (!app.ports?.viewerOutgoingMessage) return;
    app.ports.viewerOutgoingMessage.subscribe((val) => {
      if (val === null) {
        localStorage.removeItem(STORAGE_KEY);
      } else {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(val));
      }
    });
    // Whenever localStorage changes in another tab, report it if necessary.
    window.addEventListener(
      "storage",
      function (event) {
        if (event.storageArea === localStorage && event.key === STORAGE_KEY) {
          app.ports.viewerIncomingMessage.send(JSON.parse(event.newValue));
        }
      },
      false
    );
  },
  getLocalStorage() {
    return localStorage.getItem(STORAGE_KEY);
  },
};
