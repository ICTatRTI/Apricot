$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$  = $
_ = require 'underscore'
dasherize = require("underscore.string/dasherize")
moment = require 'moment'

Alert = require '../models/Alert'
EditAlertView = require './EditAlertView'

class ManageAlertsView extends Backbone.View
  render: =>
    @$el.html "
      <h1>Manage Alerts</h1>

      <div style='hide' id='alertEditForm'></div>

      <button id='new' type='button' class='mdl-button mdl-js-button mdl-button--fab mdl-button--colored'>
        <i class='material-icons'>add</i>
      </button>

      <table>
        <thead>
          <th/>
        #{
          _(Alert.fields).map (field) ->
            "<th>#{field}</th>"
          .join("")
        }
        #{
          _(Alert.booleans).map (boolean) ->
            "<th>#{boolean}</th>"
          .join("")
        }
        <th>Last Sent</th>
        </thead>
        <tbody>
        </tbody>
      </table>
    "

    Apricot.database.allDocs
      startkey: "alert"
      endkey: "alert\ufff0"
      include_docs: true
    .then (result) =>
      @alerts = _(result.rows).pluck "doc"
      @$("table tbody").append(
        index = 0
        _(result.rows).map (row) ->
          "
            <tr>
              <td>
                <button class='edit' id='alert-#{index++}' type='button' class='mdl-button mdl-js-button mdl-button--fab mdl-button--colored'>
                  <i class='material-icons'>edit</i>
                </button>
              </td>
              #{
                _(Alert.fields).map (field) ->
                  "<td>#{row.doc[field]}</td>"
                .join("") +
                _(Alert.booleans).map (boolean) ->
                  "<td>#{row.doc[boolean]}</td>"
                .join("")
              }
              <td>#{row.doc["Last Sent"] or ""}</td>
            </tr>
          "
        .join("")
      )

  events:
    "click #new": "new"
    "click .edit": "edit"

  edit: (event) =>
    id = $(event.target).parent().attr("id").replace(/alert-/,"")
    @editAlertView = new EditAlertView() unless @editAlertView
    @editAlertView.setElement @$("#alertEditForm")
    @editAlertView.alert = new Alert(@alerts[id])
    @editAlertView.loadAlert()
    @editAlertView.render()

  new: ->
    @editAlertView = new EditAlertView() unless @editAlertView
    @editAlertView.setElement @$("#alertEditForm")
    @editAlertView.alert = new Alert()
    @editAlertView.render()

module.exports = ManageAlertsView
