class CreateWidgets < ActiveRecord::Migration[7.2]
  def change
    create_table :widgets do |t|
      t.string :name
      t.string :description
      t.string :sku
      t.string :color
      t.string :material
      t.boolean :available

      t.timestamps
    end
  end
end
