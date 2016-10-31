_ = require 'underscore'
$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$  = $
BackbonePouch = require 'backbone-pouch'
moment = require 'moment'

class Alert extends Backbone.Model
  defaults:
    type: "Alert"
    _id: "alert_#{moment().format("YYYYMMDDHHmmssSS")}"

  validate: (attributes, options) =>
    errors = _(Alert.fields).map (field) ->
      return "#{field} is required. " unless (attributes[field] and attributes[field] isnt "")
    .join("")
    if errors isnt "" then errors else null

Alert.fields = [
  "Page Route"
  "Element"
  "Recipients"
  "Frequency"
]

Alert.booleans = [
  "Enabled"
]

module.exports = Alert
