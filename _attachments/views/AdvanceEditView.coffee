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
            <div class='mdl-textfield mdl-js-textfield mdl-textfield--floating-label'>
              <input class='mdl-textfield__input' type='text' id='#{fieldId}'>
              <label class='mdl-textfield__label' for='#{fieldId}'>#{field}</label>
            </div>
          "
        .join("")
      }

      #{
        _(Advance.booleans).map (boolean) ->
          booleanId = dasherize(boolean)
          "
            <label class='mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect' for='#{booleanId}'>
              <input type='checkbox' id='#{booleanId}' class='mdl-checkbox__input'>
              <span class='mdl-checkbox__label'>#{boolean}</span>
            </label>
          "
        .join("")
      }

      <button id='save' type='button' class='mdl-button mdl-js-button mdl-button--fab mdl-button--colored'>
        <i class='material-icons'>save</i>
      </button>
    "
    componentHandler.upgradeAllRegistered()

    @loadAdvance() if @advance

    Apricot.database.query "phoneNumbersByName",
      reduce: true
      group_level: 1
    .catch (error) -> console.error error
    .then (result) =>
      allNames = _(result.rows).pluck "key"
      phoneNumbersByName = _.object(allNames, _(result.rows).pluck "value")

      frequencyAutocomplete = new Awesomplete $("#-name")[0],
        list: allNames
        minChars: 1
        filter: Awesomplete.FILTER_STARTSWITH

      $("#-name").on "awesomplete-selectcomplete", ->
        phoneNumberForName = phoneNumbersByName[$('#-name').val()]
        if phoneNumberForName
          $("#-phone-number").parent().addClass "is-dirty"
          $("#-phone-number").val(phoneNumberForName)

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
      @$("##{fieldId}").parent().addClass("is-dirty") if @advance.get(field)
    _(Advance.booleans).map (boolean) =>
      booleanId = dasherize(boolean)
      @$("##{booleanId}").prop("checked", @advance.get(boolean))

  getAdvance: =>
    @advance = new Advance() unless @advance
    _(Advance.fields).map (field) =>
      fieldId = dasherize(field)
      value = @$("##{fieldId}").val()
      value = value.replace(/ /g,"") if field is "Phone Number"
      @advance.set(field, value)
    _(Advance.booleans).map (boolean) =>
      booleanId = dasherize(boolean)
      value = @$("##{booleanId}").is(":checked")
      @advance.set(boolean, value)

module.exports = AdvanceEditView
