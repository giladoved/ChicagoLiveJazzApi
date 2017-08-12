require 'json'
require 'date'

class JazzShowcaseController < ActionController::API
  def index
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
		time = info.children[2].text.strip
		price = info.children[4].text.strip
		eventjson = {:headline => headline, :details => details, :time => time, :price => price}
    render json: eventjson
  end
end
