class CreateGraphs < ActiveRecord::Migration
  def change
    create_table :graphs do |t|
      t.string :src_tag
      t.string :dest_tag
      t.integer :upvotes
      t.timestamps null: false
    end

    add_index :graphs, [:src_tag, :dest_tag], unique: true

  end
end
