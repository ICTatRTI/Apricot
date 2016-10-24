$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$  = $
_ = require 'underscore'
moment = require 'moment'

Advance = require './models/Advance.coffee'
AdvanceEditView = require './views/AdvanceEditView.coffee'

class Router extends Backbone.Router
  routes:
    "": "dashboard"
    "new/advance": "newAdvance"
    "edit/advance/:advanceId": "editAdvance"
    '*invalidRoute' : 'showErrorPage'

  showErrorPage: () ->
    $("#content").html "No matching route"

  newAdvance: ->
    Apricot.advanceEditView = new AdvanceEditView() unless Apricot.advanceEditView
    Apricot.advanceEditView.advance = new Advance()
    Apricot.advanceEditView.setElement '#content'
    Apricot.advanceEditView.render()

  editAdvance: (advanceId) ->
    Apricot.advanceEditView = new AdvanceEditView() unless Apricot.advanceEditView
    Apricot.advanceEditView.setElement '#content'
    Apricot.advanceEditView.advance = new Advance(_id: advanceId)
    Apricot.advanceEditView.advance.fetch
      error: -> console.error "Couldn't load advance: #{advanceId}"
      success: ->
        Apricot.advanceEditView.render()


module.exports = Router
