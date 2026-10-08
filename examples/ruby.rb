#!/usr/bin/env ruby
# IP geolocation from Ruby — standard library only.
#
#   ruby ruby.rb [ip-or-domain]

require 'json'
require 'net/http'
require 'uri'

BASE = 'https://bgp.cx'

# Look up an IP or domain; an empty target queries the caller's own address.
def lookup(target = '', lang = 'en')
  url = if target.empty?
          "#{BASE}/api/ip?lang=#{lang}"
        else
          "#{BASE}/api/ip/#{URI.encode_www_form_component(target)}?lang=#{lang}"
        end

  uri = URI(url)
  req = Net::HTTP::Get.new(uri)
  key = ENV['IPLOOKUP_KEY']
  req['Authorization'] = "Bearer #{key}" if key && !key.empty?

  res = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 10) do |http|
    http.request(req)
  end
  raise "lookup failed: HTTP #{res.code}" unless res.code == '200'

  JSON.parse(res.body)
end

# Fetch a single field as plain text.
def field(target, name)
  uri = URI("#{BASE}/ip/#{URI.encode_www_form_component(target)}/#{URI.encode_www_form_component(name)}")
  res = Net::HTTP.get_response(uri)
  raise "field lookup failed: HTTP #{res.code}" unless res.code == '200'

  res.body.strip
end

# ASN details with announced prefixes.
def asn(number, family: nil, limit: 100)
  params = { limit: limit }
  params[:family] = family if family
  uri = URI("#{BASE}/api/asn/#{URI.encode_www_form_component(number.to_s)}?#{URI.encode_www_form(params)}")
  res = Net::HTTP.get_response(uri)
  raise "asn lookup failed: HTTP #{res.code}" unless res.code == '200'

  JSON.parse(res.body)
end

target = ARGV[0].to_s
info = lookup(target)
puts JSON.pretty_generate(info)

if info['ip']
  puts
  puts "country : #{field(info['ip'], 'country')}"
  puts "location: #{field(info['ip'], 'location')}"
  puts "coords  : #{field(info['ip'], 'loc')}"
end

if info['asn']
  detail = asn(info['asn'], family: 4, limit: 5)
  puts
  puts "AS#{detail['asn']} #{detail['name']} — #{detail['ipv4_prefixes']} IPv4 prefixes"
  Array(detail['prefixes']).first(5).each { |p| puts "  #{p}" }
end
