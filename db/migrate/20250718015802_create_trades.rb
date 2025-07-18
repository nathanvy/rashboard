class CreateTrades < ActiveRecord::Migration[8.0]
  def change
    create_table :trades do |t|
      t.timestamptz :dtg
      t.text :symbol
      t.timestamptz :expiry
      t.text :side
      t.text :effect
      t.decimal :strike
      t.decimal :price
      t.integer :qty
      t.decimal :delta
      t.decimal :theta
      t.decimal :gamma
      t.decimal :vega
      t.decimal :spot
      t.decimal :iv
    end
  end
end
