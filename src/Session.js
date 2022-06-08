const STORAGE_KEY = "hex-arch-viewer";
export default {
  start(app) {
    if (!app.ports?.sessionPublish) return;
    app.ports.sessionPublish.subscribe((event) => {
      console.log(event);
      ({
        UpdatedViewer: () => {
          localStorage.setItem(STORAGE_KEY, JSON.stringify(event.payload));
        },
        ClearedSession: () => {
          localStorage.removeItem(STORAGE_KEY);
        },
      }[event.constructor]());
      if (!app.ports?.sessionSubscribe) return;
      app.ports.sessionSubscribe.send(event);
    });
  },
  getViewer() {
    return localStorage.getItem(STORAGE_KEY);
  },
};
