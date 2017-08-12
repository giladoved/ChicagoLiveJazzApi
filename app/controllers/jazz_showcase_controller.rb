require 'json'
require 'date'

class JazzShowcaseController < ActionController::API
  def index
		puts "serving: Jazz Showcase info"
    fileLoc = "#{Rails.root}/public/jazzshowcase.json"
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

	def	build_json_from_html
    page_url = "http://www.jazzshowcase.com/calendar/"
    user_agent = { "User-Agent" => "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C25 Safari/419.3" }
    page = Nokogiri::HTML(open(page_url, user_agent), nil, "UTF-8")
 		day = Date.today.strftime("%d").to_i
    calendar_list = page.css('.calendar-list')
    array_access = day * 2 - 1
    calendar_row = calendar_list.children[array_access]
    link = calendar_row.at_css('a')['href']
    page_details = Nokogiri::HTML(open(link))
    event = page_details.at_css('.content')
    headline = event.at_css('h1').text
    details = event.at_css('.grid.ten-tenths').css('h2').map { |h2| h2.text }.join("\n")
		info = event.at_css('p.info')
		price = info.children[4].text.strip
		video_search = headline.split(' ')[0..3].join(' ')
    video_id = get_video(video_search)

		eventsjson = []
		eventjson = {:headline => headline, :details => details, :price => price, :video => video_id}
		time = info.children[2].text.strip
		if time.split('/').count > 1
			eventsjson << time.split('/').map { |t| eventjson.merge({:time => t.strip}) }
		elsif time.split('&').count > 1
			eventsjson << time.split('&').map { |t| eventjson.merge({:time => t.strip}) }
		else
			eventjson.merge({:time => time})
		end
		result = {:events => eventsjson}
	end

	def get_video(group)
    Yt.configure do |config|
        config.api_key = 'AIzaSyCx9mqGFL7_6jEiAa9uJnSxhFLNb1c9Dig'
    end

    video_id = nil
    keywords = ["jazz", "showcase", "live", "chicago", ""]
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
