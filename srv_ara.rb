#!/usr/bin/env ruby

require 'webrick'
require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'rss'

include WEBrick

class AraCrawlServlet < HTTPServlet::AbstractServlet
	def crawl
		agent = Mechanize.new
		page = agent.get 'http://ara.kaist.ac.kr/all/?page_no=1'
		doc = Nokogiri::HTML(page.body)
		list_author = doc.xpath('//table[@class="articleList"]/tbody/tr/td[@class="author"]/a[@class="nickname"]').map do |elem|
			elem.content
		end
		list_updated = doc.xpath('//table[@class="articleList"]/tbody/tr/td[@class="date"]').map do |elem|
			elem.content
		end
		list_title = doc.xpath('//table[@class="articleList"]/tbody/tr/td[@class="title "]').map do |elem|
			elem.content.gsub(/(\[\d+\])/, '').strip
		end

		rss = RSS::Maker.make("atom") do |maker|
			maker.channel.author = 'kcd'
			maker.channel.updated = Time.now.to_s
			maker.channel.about = 'http://qwerty.kaist.ac.kr/'
			maker.channel.title = 'Ara News Feed'

			for i in 0..list_title.length-1
				maker.items.new_item do |item|
					item.link = 'http://ara.kaist.ac.kr/'
					item.author = list_author[i]
					item.updated = list_updated[i]
					item.title = list_title[i]
				end
			end
		end
		rss.to_s
	end

	def do_GET(req, resp)
		resp.body = crawl
		raise HTTPStatus::OK
	end

	alias :do_POST :do_GET
end

server = HTTPServer.new(:Port => 8080)
yield server if block_given?
['INT', 'TERM'].each {|signal|
	trap(signal) {server.shutdown}
}
server.mount('/ara', AraCrawlServlet)
server.start

# Added to learn git.
## git branch experimental
