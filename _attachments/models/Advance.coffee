_ = require 'underscore'
$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$  = $
BackbonePouch = require 'backbone-pouch'
moment = require 'moment'

class Advance extends Backbone.Model
  defaults:
    type: "Advance"
    changeTimestamps: []

  validate: (attributes, options) =>
    errors = _(Advance.fields).map (field) ->
      return "" if field is "Comments"
      return "#{field} is required. " unless (attributes[field] and attributes[field] isnt "")
    .join("")

    console.log errors
    if errors isnt "" then errors else null

Advance.fields = [
  "Name"
  "Phone Number"
  "Comments"
  "Amount"
]


module.exports = Advance
