$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$  = $
_ = require 'underscore'
dasherize = require("underscore.string/dasherize")
moment = require 'moment'
tablesort = require 'tablesort'
FileSaver = require 'file-saver'

Advance = require '../models/Advance'

class AdvanceTableView extends Backbone.View

  render: =>
   
    @$el.html "
      <table class='advanceTableView'>
        <thead>
          <th>
            <button id='downloadTable' type='button' class='mdl-button mdl-js-button mdl-button--fab mdl-button--colored'>
              <i class='material-icons'>file_download</i>
            </button>
          </th>
          <th>Last Change</th>
          #{
            _(Advance.fields).map (field) => "
              <th>#{field}</th>
            "
            .join("")
          }
          #{
            _(Advance.booleans).map (boolean) -> "
              <th>#{boolean}</th>
            "
            .join("")
          }
        </thead>
        <tbody>
          #{
            _(@collection).map (advance) -> "
              <tr>
                <td>
                  <a href='#edit/advance/#{advance._id}'>
                    <button id='edit' type='button' class='mdl-button mdl-js-button mdl-button--fab mdl-button--colored'>
                      <i class='material-icons'>edit</i>
                    </button>
                  </a>
                </td>
                <td>#{advance["changeTimestamps"][0]}</td>
                
                #{
                  _(Advance.fields).map (field) -> "
                    <td>#{advance[field]}</td>
                  "
                  .join("")
                }
                #{
                  _(Advance.booleans).map (boolean) -> "
                    <td>#{if advance[boolean] then "Y" else "N"}</td>
                  "
                  .join("")
                }
              </tr>
            "
            .join("")
          }
        </tbody>
      </table>
    "

    tablesort(@$(".advanceTableView")[0])

  events:
    "click #downloadTable": "downloadTable"

  downloadTable: =>
    csv = "
      Changes,#{Advance.fields.join(",")},#{Advance.booleans.join(",")}\n
      #{
        _(@collection).map (advance) ->
          advance["changeTimestamps"].join(" ") + "," +
          _(Advance.fields).map((field) -> advance[field]).join(",") + "," +
          _(Advance.booleans).map((boolean) -> if advance[boolean] then "Y" else "N").join(",")
        .join("\n")
      }
    "
    FileSaver.saveAs(new Blob([csv], {type: "text/csv;charset=utf-8"}), "apricot-advances-#{moment().format("YYYY-MM-DD_HH:mm")}.csv")

module.exports = AdvanceTableView
