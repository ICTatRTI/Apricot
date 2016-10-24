$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$  = $
_ = require 'underscore'
dasherize = require("underscore.string/dasherize")
moment = require 'moment'

Advance = require '../models/Advance'

class AdvanceEditView extends Backbone.View
  render: =>
    @$el.html "
      <style>
        #errors{
          color:red;
        }
      </style>
      <h1>Advance</h1>
      <div id='messages'>
      </div>
      #{
        _(Advance.fields).map (field) ->
          fieldId = dasherize(field)
          "
            <div class='mdl-textfield mdl-js-textfield'>
              <input class='mdl-textfield__input' type='text' id='#{fieldId}'>
              <label class='mdl-textfield__label' for='#{fieldId}'>#{field}</label>
            </div>
          "
        .join("")
      }
      <button id='save' type='button' class='mdl-button mdl-js-button mdl-button--fab mdl-button--colored'>
        <i class='material-icons'>save</i>
      </button>
    "

    @loadAdvance() if @advance

  events:
    "click #save": "save"

  save: =>
    @getAdvance()
    changeTimestamps = @advance.get("changeTimestamps")
    changeTimestamps.push(moment().format())
    @advance.set
      changeTimestamps: changeTimestamps
    @advance.save null,
      error: (error) ->
        console.error error
      success: =>
        $("#messages").html("Saved")
        Apricot.router.navigate "edit/advance/#{@advance.id}"
    if @advance.validationError
      $("#messages").html "
        <span id='errors'>#{@advance.validationError}<span>
      "

  loadAdvance: =>
    _(Advance.fields).map (field) =>
      fieldId = dasherize(field)
      @$("##{fieldId}").val(@advance.get(field))

  getAdvance: =>
    @advance = new Advance() unless @advance
    _(Advance.fields).map (field) =>
      fieldId = dasherize(field)
      @advance.set(field, @$("##{fieldId}").val())

module.exports = AdvanceEditView
