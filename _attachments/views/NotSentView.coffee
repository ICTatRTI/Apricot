$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$  = $
_ = require 'underscore'
dasherize = require("underscore.string/dasherize")
moment = require 'moment'

Advance = require '../models/Advance'
AdvanceTableView = require '../views/AdvanceTableView'
FileSaver = require 'file-saver'

class NotSentView extends Backbone.View


  render: =>
    @$el.html "
    <h1>Advances Not Yet Sent</h1>
    <button id='download' type='button' class='mdl-button mdl-js-button mdl-button--raised mdl-button--colored'>
      Download Safaricom Transfer XML For These Advances
    </button>
    <button id='upload' type='button' class='mdl-button mdl-js-button mdl-button--raised mdl-button--colored'>
      Upload Safaricom Bulk Report
    </button>
    <input style='display:none' type='file' id='file_upload'>
    <div style='margin-top:20px;' id='table'>
    </div>
    "

    Apricot.database.query "advancesNotSentByDate",
        include_docs: true
      .then (result) =>
        @advances = _(result.rows).pluck "doc"
        advanceTableView = new AdvanceTableView
          collection: @advances
        advanceTableView.setElement "#table"
        advanceTableView.render()

  events:
    "click #download": "download"
    "click #upload": "uploadClick"
    "change #file_upload": "upload"

  download: =>
    xml = "
      <?xml version='1.0' encoding='UTF-8'?>
      <BulkPaymentRequest>
        #{
          _(@advances).map (advance) -> "
            <Customer>
              <Identifier IdentifierType='MSISDN' IdentifierValue='#{advance["Phone Number"]}'/>
              <Amount Value='#{advance.Amount}'/>
            </Customer>
          "
          .join("")
        }
      </BulkPaymentRequest>
    "
    FileSaver.saveAs(new Blob([xml], {type: "text/xml;charset=utf-8"}), "apricot-transfer-#{moment().format("YYYY-MM-DD_HH:mm")}.xml")

  uploadClick: =>
    $('#file_upload').click()

  upload: (event) =>
    reader = new FileReader()
    reader.onload = (ev) =>

      parsedUpload = $($.parseXML(ev.target.result))
      bulkUploadData = _(parsedUpload.find("Records Record")).map (record) ->
        keys =  _($(record).find("Details DetailData Key")).map (data) ->
          $(data).text()
        values =  _($(record).find("Details DetailData Value")).map (data) ->
          $(data).text()

        result = _.object(keys,values)
        [ignore, result["Phone Number"], result["Name"]] = result.TransactionDetails.match(/(\d+) - (.+)/)
        result["Phone Number"] = result["Phone Number"].replace(/254/,"0")
        _([
          "BulkPlanID"
          "InitiatingOperator"
          "ApprovingOperator"
        ]).each (field) ->
          result[field] = parsedUpload.find(field).text()
        result["TransactionTimestamp"] = $(record).find("TransactionTimestamp").text()
        delete(result.TransactionDetails)
        result

      @processBulkUploadData(bulkUploadData)
    reader.readAsText(event.target.files[0])

  processBulkUploadData: (bulkUploadData) =>
    _(bulkUploadData).each (payment) =>
      matchingOutstandingAdvance = _(@advances).find (advance) ->
        advance.Number is payment.Number and
        advance.Amount is payment.Amount
      if matchingOutstandingAdvance
        advance = new Advance(matchingOutstandingAdvance)
        advance.set "Sent",true
        advance.set "PaymentDetails", payment
        advance.save()
      else
        console.error "Can't find outstanding advance for:"
        console.error payment
    # Hack
    _.delay( @render, 1000)


module.exports = NotSentView
