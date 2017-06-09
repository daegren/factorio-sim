'use strict';

// require stylesheet
require('./Stylesheets.elm');

// import helper libs
const blueprint = require('./lib/blueprint')

// load app
var Elm = require('./Main.elm');
var mountNode = document.getElementById('app');

// .embed() can take an optional second argument. This would be an object describing the data we need to start a program, i.e. a userID or some token
var app = Elm.Main.embed(mountNode);


app.ports.getOffsetOfGrid.subscribe(() => {
  const grid = document.getElementById('Grid')
  const rect = grid.getBoundingClientRect()
  app.ports.receiveOffset.send([rect.left, rect.top])
})

app.ports.parseBlueprint.subscribe((blueprintString) => {
  blueprint.parse(blueprintString, (json) => {
    app.ports.loadBlueprint.send(json.blueprint.entities)
  })
})

app.ports.exportBlueprint.subscribe((json) => {
  blueprint.exportBlueprint(json, (str) => {
    prompt("Export String", str)
  })
})
