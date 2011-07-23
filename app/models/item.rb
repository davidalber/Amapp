require 'rubygems'
require 'amazon/aws/search'
include Amazon::AWS

class Item < ActiveRecord::Base
  attr_protected :title

  validates_uniqueness_of :asin
  validate :is_valid_asin

private
  # Make an item lookup request using Amazon's API with the ASIN. Exceoptions
  # are not caught in this method.
  def get_item(rg)
    il = ItemLookup.new( 'ASIN', { 'ItemId' => self.asin,
                           'MerchantId' => 'Amazon' } )
    il.response_group = rg
    req = Search::Request.new()

    return req.search(il)
  end

  # Check if the ASIN is a valid Amazon item and set title if it is.
  def is_valid_asin
    rg = ResponseGroup.new(:Small)
    begin
      resp = get_item(rg)
      item = resp.item_lookup_response[0].items[0].item
      self.title = item.item_attributes.title.to_s
    rescue Error::InvalidParameterValue
      errors.add(:asin, "Invalid ASIN")
      return false
    end
    return true
  end
end
