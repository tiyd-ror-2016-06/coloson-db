class CreateNumbers < ActiveRecord::Migration
  def change
    create_table :numbers do |t|
      t.integer :collection_id
      t.integer :value
      t.integer :who_added_id
      t.datetime :created_at
    end
  end
end
