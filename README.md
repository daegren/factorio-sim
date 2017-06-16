# Factorio Blueprint Maker

This is a simple app that helps view blueprints and also allows you to export blueprints that you make using the grid into [Factorio][factorio-homepage] through the new 0.15 blueprint strings.

**N.B.** This app is still under heavy development, most of the various entities need to be added still.


## Features

 * Allow the importing of blueprint strings and loading them into the grid
 * Export a blueprint string from the entities currently on the grid


## To Implement

 * All Entities, currently only transport belts, chests and assembling machines are supported, plans are to support all entities in the near future.
 * Full blueprint support, icons are hardcoded.
 * Drag and drop functionality for entities

## Future considerations

 * Calculate the throughput of belts, to allow maximization of factories.

[factorio-homepage]: https://www.factorio.com/


## Running the App locally

### Requirements

 * Node 6
 * NPM / Yarn
 * Elm (http://elm-lang.org)

To run the app locally follow these instructions:

1. Clone the repo from github
2. Navigate to the local project in your terminal
3. Install the prerequisites for the project
```bash
$ npm/yarn install
```
4. Install the required elm packages
```bash
$ elm package install
```
5. Run the app in development mode
```bash
$ npm/yarn run dev
```
6. App should be running at http://localhost:8080/
