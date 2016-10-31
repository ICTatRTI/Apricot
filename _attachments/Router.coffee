$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$  = $
_ = require 'underscore'
moment = require 'moment'

Advance = require './models/Advance.coffee'
AdvanceEditView = require './views/AdvanceEditView.coffee'
AllView = require './views/AllView.coffee'
AdvanceTableView = require './views/AdvanceTableView.coffee'
NotSentView = require './views/NotSentView.coffee'
NotReconciledView = require './views/NotReconciledView.coffee'
global.ManageAlertsView = require './views/ManageAlertsView.coffee'

class Router extends Backbone.Router
  routes:
    "": "dashboard"
    "new/advance": "newAdvance"
    "edit/advance/:advanceId": "editAdvance"
    "advances/not/reconciled": "notReconciled"
    "advances/not/sent": "notSent"
    "advances/:quantity/:periodType": "all"
    "manage/alerts": "manageAlerts"
    '*invalidRoute' : 'showErrorPage'

  genericRender: (className) ->
    instanceName = className.charAt(0).toLowerCase() + className.slice(1)
    Apricot[instanceName] = new window[className]() unless Apricot[instanceName]
    Apricot[instanceName].setElement '#content'
    Apricot[instanceName].render()

  manageAlerts: () =>
    @genericRender("ManageAlertsView")

  notSent: () ->
    Apricot.notSentView = new NotSentView() unless Apricot.notSentView
    Apricot.notSentView.setElement '#content'
    Apricot.notSentView.render()

  notReconciled: () ->
    Apricot.notReconciledView = new NotReconciledView() unless Apricot.notReconciledView
    Apricot.notReconciledView.setElement '#content'
    Apricot.notReconciledView.render()

  all: () ->
    Apricot.allView = new AllView() unless Apricot.allView
    Apricot.allView.setElement '#content'
    Apricot.allView.render()

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
