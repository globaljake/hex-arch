function relay(app, fromElmCmd, toElmSub) {
  if (app.ports?.[fromElmCmd] && app.ports?.[toElmSub])
    app.ports[fromElmCmd].subscribe(app.ports[toElmSub].send);
}

export default {
  primary(app, moduleName) {
    if (!moduleName) return;
    const fromElmCmd = `primary${moduleName}AdapterSendMessage`;
    const toElmSub = `primary${moduleName}AdapterMessageReceiver`;
    relay(app, fromElmCmd, toElmSub);
  },
  secondary(app, moduleName) {
    if (!moduleName) return;
    const fromElmCmd = `secondary${moduleName}AdapterSendMessage`;
    const toElmSub = `secondary${moduleName}AdapterMessageReceiver`;
    relay(app, fromElmCmd, toElmSub);
  },
};
