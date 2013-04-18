class CreateFillers < ActiveRecord::Migration
  def change
    create_table :fillers do |t|
      t.integer :uid
      t.string :description

      t.timestamps
    end
  end
end
