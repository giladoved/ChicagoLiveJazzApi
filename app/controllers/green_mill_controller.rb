require 'open-uri'
require 'json'

class GreenMillController < ActionController::API
  def index
    fileLoc = "#{Rails.root}/public/greenmill.json"
    if !File.exists?(fileLoc)
      generated_json = build_json_from_html
      File.open(fileLoc, "w+") do |f|
        f.write(generated_json.to_json)
      end
      render json: generated_json
    else
      timeDiff = ((Time.now.to_f - File.ctime(fileLoc).to_f) / 3600.0)
      if timeDiff > 6
        puts "Reloaded cache"
        File.delete(fileLoc)
        index
      else
        puts "Served cached file"
        render json: File.read(fileLoc)
      end
    end
  end

  def build_json_from_html
    page = Nokogiri::HTML(open("http://greenmilljazz.com/calendar/"))
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
      headline = event.at_css('.eventdate').content.tr("\n", '').gsub(/\(.+\)/, "").strip
      price = event.at_css('.eventtime').content.tr("\n", '').strip
      details = ""
      paragraphs = event.css('p')
      time = paragraphs.shift.content.strip
      details = paragraphs.last.content.strip
      video_id = get_video(headline)
      eventjson = {:headline => headline, :price => price, :time => time, :video => video_id, :details => details }
      eventjsons << eventjson
    end
    result = {:events => eventjsons}
  end

  def get_video(group)
    Yt.configure do |config|
        config.api_key = 'AIzaSyCx9mqGFL7_6jEiAa9uJnSxhFLNb1c9Dig'
    end

    video_id = nil
    keywords = ["green mill", "live", "chicago", ""]
    keywords.each do |keyword|
      videos = Yt::Collections::Videos.new
      videos.where(q: "#{group} #{keyword}")
      if videos.size > 1
        video_id = videos.first.id
        break
      end
    end
    video_id
  end
end
