require 'rubygems'
require 'amazon/aws/search'
include Amazon::AWS

class Item < ActiveRecord::Base
  attr_protected :title

  validates_uniqueness_of :asin
  validate :is_valid_asin

  after_validation :set_title

  def set_title
    il = ItemLookup.new( 'ASIN', { 'ItemId' => asin,
                           'MerchantId' => 'Amazon' } )
    req = Search::Request.new()

    begin
      resp = req.search(il)
      item = resp.item_lookup_response[0].items[0].item
      self.title = item.item_attributes.title.to_s
    rescue Error::InvalidParameterValue
      errors.add(:asin, "Invalid ASIN")
    end
  end

  def is_valid_asin
    il = ItemLookup.new( 'ASIN', { 'ItemId' => self.asin,
                           'MerchantId' => 'Amazon' } )
    il.response_group = :Small

    req = Search::Request.new()

    begin
      resp = req.search(il)
    rescue Error::InvalidParameterValue
      errors.add(:asin, "Invalid ASIN")
    end
  end
end
