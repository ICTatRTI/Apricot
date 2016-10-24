global.$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$  = $
BackbonePouch = require 'backbone-pouch'
global._ = require 'underscore'
PouchDB = require 'pouchdb'

global.Apricot = {
  database: new PouchDB("http://localhost:5984/apricot")
}

Router = require './Router'

Apricot.router = new Router()

Backbone.sync = BackbonePouch.sync
  db: Apricot.database
  fetch: 'query'
Backbone.Model.prototype.idAttribute = '_id'

Backbone.history.start()
