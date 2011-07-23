class CreatePriceRecords < ActiveRecord::Migration
  def self.up
    create_table :price_records do |t|
      t.integer :amount
      t.references :item

      t.timestamps
    end
  end

  def self.down
    drop_table :price_records
  end
end
