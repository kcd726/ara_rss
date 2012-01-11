#!/usr/bin/env ruby

$: << Dir.pwd
require 'webrick'
require 'crawler'

include WEBrick

class Servlet < HTTPServlet::AbstractServlet
	def do_GET(req, resp)
		crawler = Crawler::Crawler.new
		resp.body = crawler.get_rss.to_s
		raise HTTPStatus::OK
	end

	alias :do_POST :do_GET
end

server = HTTPServer.new(:Port => 8080)
yield server if block_given?
['INT', 'TERM'].each {|signal|
	trap(signal) {server.shutdown}
}
server.mount('/ara', Servlet)
server.start
