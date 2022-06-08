export default {
  relay(app, fromElmCmd, toElmSub) {
    if (app.ports?.[fromElmCmd] && app.ports?.[toElmSub])
      app.ports[fromElmCmd].subscribe(app.ports[toElmSub].send);
  },
};
