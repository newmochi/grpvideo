class CreateSavings < ActiveRecord::Migration
  def change
    create_table :savings do |t|
      t.date :recdate
      t.string :title
      t.string :owner
      t.text :note
      t.string :video

      t.timestamps null: false
    end
  end
end
