require 'open-uri'
require 'json'
require 'date'

class GreenMillController < ActionController::API
  def index
		puts "serving: Green Mill info"
    fileLoc = "#{Rails.root}/public/greenmill.json"
    if !File.exists?(fileLoc)
		  result = build_json_from_html
			File.open(fileLoc, "w+") do |f|
				f.write(result.to_json)
			end
    else
    	timeDiff = ((Time.now.to_f - File.ctime(fileLoc).to_f) / 3600.0)
			puts "Time difference: #{timeDiff}"
      if timeDiff > 3 || timeDiff < 0.5
        puts "Reloaded cache"
				File.delete(fileLoc)
		  	result = build_json_from_html
				File.open(fileLoc, "w+") do |f|
        	f.write(result.to_json)
      	end
      else
        puts "Served cached file"
        result = File.read(fileLoc)
      end
    end
    render json: result
  end

  def build_json_from_html
		year = Date.today.strftime("%Y")
 		month = Date.today.strftime("%m")
 		page = Nokogiri::HTML(open("http://greenmilljazz.com/calendar/?ajaxCalendar=1&mo=#{month}&yr=#{year}"))
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
      details = paragraphs[1..-1].map { |p| p.content.strip }.join("\n")
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
    keywords = ["", " jazz", " green mill", " live", " chicago"]
    keywords.each do |keyword|
      videos = Yt::Collections::Videos.new
      videos.where(q: "#{group}#{keyword}")
      if videos.first != nil
        video_id = videos.first.id
        break
      end
    end
    video_id
  end
end
