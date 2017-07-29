require 'pry'
require 'open-uri'

class GreenMillController < ActionController::API
  def index
    render json: parse_html_calendar
  end

  def parse_html_calendar
    page = Nokogiri::HTML(open("tmp/greenmillcalendar.htm"))
    today = page.css(".eventful-today")
    shows = today.css("li")
    links = shows.css('a')[0]
    hrefs = []
    shows.each do |show|
      a = show.css('a')[0]
      hrefs << "#{a['href']}"
    end

    eventjsons = []
    hrefs.each do |href|
      page = Nokogiri::HTML(open(href))
      event = page.at_css('.event')
      headline = event.at_css('.eventdate').content.tr("\n", '')
      price = event.at_css('.eventtime').content.tr("\n", '')
      details = ""
      paragraphs = event.css('p')
      time = paragraphs.shift.content
      details = paragraphs.last.content
      eventjson = {:headline => headline, :price => price, :time => time, :details => details }
      eventjsons << eventjson
    end
    result = {:events => eventjsons}
  end
end
