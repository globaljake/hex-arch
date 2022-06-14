export default {
  start(app) {
    if (app.ports?.relaySendMessage && app.ports?.relayMessageReceiver)
      app.ports.relaySendMessage.subscribe(app.ports.relayMessageReceiver.send);
  },
};
