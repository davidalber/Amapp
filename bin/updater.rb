#!/usr/bin/ruby -w

require 'rubygems'
require 'rest-open-uri-postpatch'
require 'rexml/document'
require 'cgi'

include RestOpenUriPostpatch

# Remove forward slashes at the end of str.
def strip_trailing_slashes(str)
  str.gsub(/\A[\/]+|[\/]+\Z/, "")
end

# Get the list of items and return their IDs in an array.
def get_items(uri, username, password)
  response = open(uri, :http_basic_authentication => [username, password])
  xml = response.read
  document = REXML::Document.new(xml)

  # Extract each item ID.
  items = []
  REXML::XPath.each(document, '/items/item/id/[]') do |id|
    items += [id]
  end
  
  return items
end

# Get the hidden fields from an item's form to update prices, and return
# the information as form-encoded key-value pairs.
def get_post_body(uri, item, username, password)
  itemUri = uri + "/items/#{item}"
  response = open(itemUri, :http_basic_authentication => [username, password])
  xml = response.read
  document = REXML::Document.new(xml)

  encoded = []
  form = REXML::XPath.first(document, 'html/body/form')
  REXML::XPath.each(form, '*/input') do |input|
    encoded << CGI.escape(input.attributes['name']) + '=' +
      CGI.escape(input.attributes['value'])
  end

  return encoded.join('&')
end

def refresh_item_prices(uri, username, password)
  items = get_items(uri+"/items.xml", username, password)
  items.each do |item|
    # The form has hidden fields that need to be captured.
    postBody = get_post_body(uri, item, username, password)

    puts "Requesting price of Item #{item}..."
    refreshUri = uri + "/items/#{item}/price_records"
    open(refreshUri, :method => :post, :body => postBody,
         :content_type => 'x-www-form-urlencoded')
  end
end

uri = nil
username = nil
password = ''
  
uri, username, password = ARGV
unless uri
  puts "Usage: #{$0} [BaseURI] <username> <password>"
  exit
end

# Strip any trailing slashes off of the URI.
uri = strip_trailing_slashes(uri)

refresh_item_prices(uri, username, password)
