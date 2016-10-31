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
      return "Not a valid phone number. " if field is "Phone Number" and attributes[field] and isNaN(attributes[field]) # Make sure it's a number, allows +
    .join("")
    
    errors +=  "Can't have a reconciled advance that was never sent. " if attributes.Sent is false and attributes.Reconciled is true

    console.log errors
    if errors isnt "" then errors else null

Advance.fields = [
  "Name"
  "Phone Number"
  "Comments"
  "Amount"
]

Advance.booleans = [
  "Sent"
  "Reconciled"
]


module.exports = Advance
