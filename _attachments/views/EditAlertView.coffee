$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$  = $
_ = require 'underscore'
dasherize = require("underscore.string/dasherize")
moment = require 'moment'

Alert = require '../models/Alert'
Awesomplete = require 'awesomplete'

class EditAlertView extends Backbone.View
  render: =>
    @$el.html "
      <style>
        #errors{
          color:red;
        }
      </style>
      <div id='messages'>
      </div>
      <div style='hide' id='alertEditForm'>

        #{
          _(Alert.fields).map (field) ->
            fieldId = dasherize(field)
            "
              <div class='mdl-textfield mdl-js-textfield mdl-textfield--floating-label'>
                <input class='mdl-textfield__input' type='text' id='#{fieldId}'>
                <label class='mdl-textfield__label' for='#{fieldId}'>#{field}</label>
              </div>
            "
          .join("")
        }
        #{
          _(Alert.booleans).map (boolean) ->
            booleanId = dasherize(boolean)
            "
              <label class='mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect' for='#{booleanId}'>
                <input type='checkbox' id='#{booleanId}' class='mdl-checkbox__input'>
                <span class='mdl-checkbox__label'>#{boolean}</span>
              </label>
            "
          .join("")
        }
        <select>
        </select>
      </div>



      <button id='save' type='button' class='mdl-button mdl-js-button mdl-button--fab mdl-button--colored'>
        <i class='material-icons'>save</i>
      </button>
    "

    componentHandler.upgradeAllRegistered()
    @loadAlert() if @alert

    frequencyAutocomplete = new Awesomplete $("#-frequency")[0],
      list: ["Monthly","Weekly","Daily", "Hourly", "Minutely"]
      autoFirst: true
      minChars: 0
      filter: Awesomplete.FILTER_STARTSWITH

    $('#-frequency').on 'focus', ->
        frequencyAutocomplete.evaluate()

  events:
    "click #save": "save"

  save: =>
    @getAlert()
    @alert.save null,
      error: (error) ->
        console.error error
      success: =>
        $("#messages").html("Saved")
    if @alert.validationError
      $("#messages").html "
        <span id='errors'>#{@alert.validationError}<span>
      "

  loadAlert: =>
    console.log @alert
    _(Alert.fields).map (field) =>
      fieldId = dasherize(field)
      @$("##{fieldId}").val(@alert.get(field))
      @$("##{fieldId}").parent().addClass("is-dirty") if @alert.get(field)
    _(Alert.booleans).map (boolean) =>
      booleanId = dasherize(boolean)
      @$("##{booleanId}").prop("checked", @alert.get(boolean))

  getAlert: =>
    @alert = new Alert() unless @alert
    _(Alert.fields).map (field) =>
      fieldId = dasherize(field)
      value = @$("##{fieldId}").val()
      value = value.replace(/ /g,"") if field is "Phone Number"
      @alert.set(field, value)
    _(Alert.booleans).map (boolean) =>
      booleanId = dasherize(boolean)
      value = @$("##{booleanId}").is(":checked")
      @alert.set(boolean, value)

module.exports = EditAlertView
