class PriceRecordsController < ApplicationController
  def create
    @item = Item.find(params[:item_id])
    @price_record = @item.price_records.create(params[:price_record])
    redirect_to item_path(@item)
  end
end
