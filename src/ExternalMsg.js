export default {
  start(app) {
    if (app.ports?.extSendMessage && app.ports?.extMessageReceiver)
      app.ports.extSendMessage.subscribe(app.ports.extMessageReceiver.send);
  },
};
