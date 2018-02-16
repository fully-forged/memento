window.onload = function() {
  var app = Elm.Main.fullscreen();
  var logFn = console.table ? console.table : console.log;

  app.ports.logStatus.subscribe(logFn);
};
