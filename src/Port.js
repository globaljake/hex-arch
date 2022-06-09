function relay(app, fromElmCmd, toElmSub) {
  if (app.ports?.[fromElmCmd] && app.ports?.[toElmSub])
    app.ports[fromElmCmd].subscribe(app.ports[toElmSub].send);
}

export default {
  instruction(app, moduleName) {
    if (!moduleName) return;
    const fromElmCmd = `${moduleName}SendInstruction`;
    const toElmSub = `${moduleName}ReceiveInstruction`;
    relay(app, fromElmCmd, toElmSub);
  },
  event(app, moduleName) {
    if (!moduleName) return;
    const fromElmCmd = `${moduleName}EventPublish`;
    const toElmSub = `${moduleName}EventSubscribe`;
    relay(app, fromElmCmd, toElmSub);
  },
};
