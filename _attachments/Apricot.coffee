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


$("#navigation-reports").append _(
    "#advances/not/reconciled": "Advances not Reconciled"
    "#advances/not/sent": "Advances not Sent"
    "#advances/30/days": "All Advances for past 30 days"
  ).map (text, target) ->
    "
      <a class='mdl-navigation__link' href='#{target}'>
        #{text}
      </a>
    "

Backbone.sync = BackbonePouch.sync
  db: Apricot.database
  fetch: 'query'
Backbone.Model.prototype.idAttribute = '_id'

Backbone.history.start()
