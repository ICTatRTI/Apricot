$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$  = $
_ = require 'underscore'
dasherize = require("underscore.string/dasherize")
moment = require 'moment'

Advance = require '../models/Advance'
AdvanceTableView = require './AdvanceTableView'

class NotReconciledView extends Backbone.View

  render: =>
    @$el.html "
    <h1>Advances Not Reconciled</h1>
    <div id='table'>
    </div>
    "

    Apricot.database.query "advancesNotReconciledByDate",
        include_docs: true
      .then (result) =>
        advanceTableView = new AdvanceTableView
          collection: _(result.rows).pluck "doc"
        advanceTableView.setElement "#table"
        advanceTableView.render()

module.exports = NotReconciledView
