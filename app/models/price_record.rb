require 'rubygems'
require 'amazon/aws/search'
include Amazon::AWS

class PriceRecord < ActiveRecord::Base
  belongs_to :item

  after_validation :set_item_price

private
  # Make an item lookup request using Amazon's API with the ASIN. Exceoptions
  # are not caught in this method.
  def get_item(rg)
    il = ItemLookup.new( 'ASIN', { 'ItemId' => self.item.asin,
                           'MerchantId' => 'Amazon' } )
    il.response_group = rg
    req = Search::Request.new()

    return req.search(il)
  end

  # Check if the ASIN is a valid Amazon item and set title if it is.
  def set_item_price
    rg = ResponseGroup.new('Offers')
    begin
      resp = get_item(rg)
      item = resp.item_lookup_response[0].items[0].item
      self.amount = item.offers.offer.offer_listing.price.amount
    rescue Error::InvalidParameterValue
      errors.add(:asin, "Invalid ASIN")
    end
  end
end
