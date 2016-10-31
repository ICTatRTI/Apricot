#! /usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'capybara'
require 'capybara/dsl'
require 'capybara-screenshot'
require 'json'
require 'rest-client'
require 'trollop'
require 'capybara/poltergeist'
require 'couchrest'
require 'active_support/all'

$configuration = JSON.parse(IO.read(File.dirname(__FILE__) + "/configuration.json"))

$opts = Trollop::options do
  opt :url, "REQUIRED. Base URL, e.g. http://localhost:8095", :type => :string
end

Capybara.run_server = false
Capybara.current_driver = :poltergeist
Capybara.app_host = 'http://localhost:8095'
Capybara.default_wait_time = 60
Capybara::Screenshot.autosave_on_failure = false
Capybara.save_and_open_page_path = "/tmp"

def get_element_html(id)
  page.find_by_id(id)  #Makes sure capybara waits
  page.evaluate_script("$('##{id}').html()")
end

include Capybara::DSL

def send_email (recipients, html, attachmentFilePaths = [])
  RestClient.post "https://#{$configuration["mailgun_login"]}@api.mailgun.net/v2/coconut.mailgun.org/messages",
    :from => "mmckay@rti.org",
    :to => recipients.join(","),
    :subject => "Apricot Alerts",
    :text => "The non html version",
    :html => html,
    :attachment => attachmentFilePaths.map{|path| File.open(path)}
end

def send_alert(alert)
  visit alert["Page Route"]
  email_text = get_element_html alert["Element"]
  send_email(alert["Recipients"].split(' '),email_text)
  alert["Last Time Sent"] = DateTime.now.strftime("%Y-%m-%d %R")
  CouchRest.put($opts[:url] + "/apricot/#{alert['_id']}", alert)
end

CouchRest.get($opts[:url] + '/apricot/_all_docs?startkey="alert"&endkey="\ufff0"&include_docs=true')['rows'].each{ |alert|
  alert =  alert['doc']
  puts alert
  if alert["Last Time Sent"].nil?
    send_alert(alert)
  else
    last_time_sent = DateTime.strptime(alert["Last Time Sent"], "%Y-%m-%d %R")
    puts alert["Frequency"]
     period_in_minutes = case alert["Frequency"]
       when "Monthly" then 4 * 7 * 60 * 24 # Note this isn't really monthly
       when "Weekly" then 7 * 60 * 24
       when "Daily" then 60 * 24
       when "Hourly" then 60
       when "Minutely" then 1
     end

    if last_time_sent + period_in_minutes.minutes < DateTime.now
      puts "Sending"
      send_alert(alert)
    else
      puts "Not sending"
    end
  end
}


