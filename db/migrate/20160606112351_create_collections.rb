class CreateCollections < ActiveRecord::Migration
  def change
    create_table :collections do |t|
      t.string :name
    end
  end
end
